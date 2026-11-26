// BackupDrive: ver BDActivityWindow.h.
// Licencia: MIT (ver ../LICENSE).

#import "BDActivityWindow.h"

#import "BDRunner.h"

@interface BDActivityWindow ()
@property(copy) NSString *folder;
@property(copy) void (^changed)(void);
// Filas ya aplanadas: {"kind":"pass", …pasada} o {"kind":"item", …fichero, "date":fecha de su pasada}.
@property(copy) NSArray<NSDictionary *> *rows;
@property(strong) NSTableView *table;
@property(strong) NSTextField *status;
@property(strong) NSButton *restoreButton;
@property BOOL busy;
@end

@implementation BDActivityWindow

- (instancetype)initWithFolder:(NSString *)folder changed:(void (^)(void))changed {
  NSWindow *window = [[NSWindow alloc]
      initWithContentRect:NSMakeRect(0, 0, 700, 440)
                styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable |
                          NSWindowStyleMaskMiniaturizable
                  backing:NSBackingStoreBuffered
                    defer:NO];
  if ((self = [super initWithWindow:window])) {
    _folder = [folder copy];
    _changed = [changed copy];
    _rows = @[];
    window.title = [NSString stringWithFormat:@"Actividad de «%@»", folder.lastPathComponent];
    window.minSize = NSMakeSize(520, 300);
    window.releasedWhenClosed = NO;
    [self buildIn:window.contentView];
    [window center];
  }
  return self;
}

- (NSTableColumn *)column:(NSString *)identifier title:(NSString *)title width:(CGFloat)width {
  NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:identifier];
  column.title = title;
  column.width = width;
  column.editable = NO;
  return column;
}

- (void)buildIn:(NSView *)v {
  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 60, 660, 360)];
  scroll.hasVerticalScroller = YES;
  scroll.borderType = NSBezelBorder;
  scroll.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  self.table = [[NSTableView alloc] initWithFrame:scroll.bounds];
  [self.table addTableColumn:[self column:@"when" title:@"Cuándo" width:130]];
  [self.table addTableColumn:[self column:@"what" title:@"Qué pasó" width:200]];
  [self.table addTableColumn:[self column:@"file" title:@"Fichero" width:310]];
  self.table.dataSource = self;
  self.table.delegate = self;
  self.table.allowsMultipleSelection = NO;
  self.table.usesAlternatingRowBackgroundColors = YES;
  self.table.target = self;
  self.table.doubleAction = @selector(restore:);
  scroll.documentView = self.table;
  [v addSubview:scroll];

  self.status = [NSTextField labelWithString:@"Cargando…"];
  self.status.frame = NSMakeRect(20, 22, 420, 18);
  self.status.autoresizingMask = NSViewWidthSizable | NSViewMaxYMargin;
  self.status.textColor = NSColor.secondaryLabelColor;
  [v addSubview:self.status];

  self.restoreButton = [NSButton buttonWithTitle:@"Restaurar…" target:self action:@selector(restore:)];
  self.restoreButton.frame = NSMakeRect(570, 14, 110, 32);
  self.restoreButton.autoresizingMask = NSViewMinXMargin | NSViewMaxYMargin;
  [v addSubview:self.restoreButton];
  [self updateButtons];
}

#pragma mark - Datos

- (void)reload {
  self.status.stringValue = @"Cargando…";
  [BDRunner run:BDRunner.ctlScript
           args:@[ @"activity", self.folder, @"--limit", @"200" ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             if (status != 0) {
               self.rows = @[];
               [self.table reloadData];
               self.status.stringValue = err.length ? err : @"No se puede leer la actividad.";
               [self updateButtons];
               return;
             }
             id list = [NSJSONSerialization JSONObjectWithData:[out dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:0
                                                         error:nil];
             NSMutableArray *rows = [NSMutableArray array];
             NSUInteger passes = 0, items = 0;
             if ([list isKindOfClass:NSArray.class]) {
               for (id pass in list) {
                 if (![pass isKindOfClass:NSDictionary.class]) continue;
                 passes++;
                 NSMutableDictionary *p = [pass mutableCopy];
                 p[@"kind"] = @"pass";
                 [rows addObject:p];
                 id its = pass[@"items"];
                 if (![its isKindOfClass:NSArray.class]) continue;
                 for (id it in its) {
                   if (![it isKindOfClass:NSDictionary.class]) continue;
                   NSMutableDictionary *i = [it mutableCopy];
                   i[@"kind"] = @"item";
                   i[@"date"] = pass[@"date"] ?: @"";
                   [rows addObject:i];
                   items++;
                 }
                 NSNumber *more = [pass[@"more"] isKindOfClass:NSNumber.class] ? pass[@"more"] : @0;
                 if (more.integerValue > 0)
                   [rows addObject:@{@"kind" : @"more", @"more" : more}];
               }
             }
             self.rows = rows;
             [self.table reloadData];
             self.status.stringValue =
                 passes ? [NSString stringWithFormat:@"%lu pasadas; %lu ficheros borrados o sobrescritos",
                                                     (unsigned long)passes, (unsigned long)items]
                        : @"Aún no hay actividad: aparecerá después de la próxima sincronización.";
             [self updateButtons];
           }];
}

- (NSDictionary *)selected {
  NSInteger row = self.table.selectedRow;
  if (row < 0 || (NSUInteger)row >= self.rows.count) return nil;
  NSDictionary *r = self.rows[(NSUInteger)row];
  return [r[@"kind"] isEqual:@"item"] ? r : nil;
}

- (void)updateButtons {
  self.restoreButton.enabled = self.selected != nil && !self.busy;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  [self updateButtons];
}

// «2026-11-26T22:13:10Z» (UTC) → «26/11/2026 23:13» en la hora local.
- (NSString *)dateText:(NSString *)iso {
  if (![iso isKindOfClass:NSString.class]) return @"";
  NSDateFormatter *parser = [[NSDateFormatter alloc] init];
  parser.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  parser.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  parser.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
  NSDate *d = [parser dateFromString:iso];
  if (!d) return iso;
  NSDateFormatter *printer = [[NSDateFormatter alloc] init];
  printer.dateFormat = @"dd/MM/yyyy HH:mm";
  return [printer stringFromDate:d];
}

- (NSString *)sideText:(id)side {
  return [side isEqual:@"mac"] ? @"en el Mac" : @"en Drive";
}

#pragma mark - Tabla

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return (NSInteger)self.rows.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row {
  if (row < 0 || (NSUInteger)row >= self.rows.count) return @"";
  NSDictionary *r = self.rows[(NSUInteger)row];
  NSString *key = column.identifier;
  NSString *kind = r[@"kind"];
  if ([kind isEqual:@"pass"]) {
    if ([key isEqualToString:@"when"]) return [self dateText:r[@"date"]];
    if ([key isEqualToString:@"what"]) {
      NSString *res = r[@"result"];
      NSString *t = [res isEqual:@"ok"] ? @"Sincronizada"
                    : [res isEqual:@"blocked"] ? @"Detenida por seguridad"
                                                : @"Con errores";
      return [r[@"resync"] isEqual:@YES] ? [t stringByAppendingString:@" (primera)"] : t;
    }
    return [NSString stringWithFormat:@"↑ %@ a Drive · ↓ %@ al Mac", r[@"up"] ?: @0, r[@"down"] ?: @0];
  }
  if ([kind isEqual:@"more"]) {
    if ([key isEqualToString:@"what"]) return @"…";
    if ([key isEqualToString:@"file"])
      return [NSString stringWithFormat:@"y %@ ficheros más (ver el registro)", r[@"more"]];
    return @"";
  }
  if ([key isEqualToString:@"when"]) return @"";
  if ([key isEqualToString:@"what"])
    return [NSString stringWithFormat:@"   %@ %@", [r[@"what"] isEqual:@"deleted"] ? @"Borrado" : @"Sobrescrito",
                                      [self sideText:r[@"side"]]];
  return r[@"path"] ?: @"";
}

#pragma mark - Acciones

- (void)restore:(id)sender {
  NSDictionary *row = self.selected;
  if (!row || self.busy) return;
  NSString *path = row[@"path"];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = [NSString stringWithFormat:@"¿Recuperar «%@» tal como estaba antes del %@?",
                                                 path.lastPathComponent, [self dateText:row[@"date"]]];
  alert.informativeText = [NSString
      stringWithFormat:@"La copia que quedó en versiones (%@) se pondrá en «%@» dentro de la carpeta. Si ahí hay "
                       @"un fichero, se guarda antes en versiones, así que no se pierde nada. La próxima "
                       @"sincronización lo llevará al otro lado.",
                       [self sideText:row[@"side"]], path];
  [alert addButtonWithTitle:@"Recuperar"];
  [alert addButtonWithTitle:@"Cancelar"];
  [alert beginSheetModalForWindow:self.window
                completionHandler:^(NSModalResponse response) {
                  if (response != NSAlertFirstButtonReturn) return;
                  [self runRestore:row];
                }];
}

- (void)runRestore:(NSDictionary *)row {
  self.busy = YES;
  [self updateButtons];
  self.status.stringValue = @"Recuperando…";
  [BDRunner run:BDRunner.ctlScript
           args:@[ @"versions", @"restore", self.folder, row[@"side"], row[@"version"] ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             self.busy = NO;
             NSAlert *alert = [[NSAlert alloc] init];
             alert.messageText = status == 0 ? @"Recuperado" : @"No se pudo recuperar";
             alert.informativeText = status == 0 ? out : (err.length ? err : @"");
             [alert beginSheetModalForWindow:self.window completionHandler:nil];
             if (self.changed) self.changed();
             [self reload];
           }];
}

@end
