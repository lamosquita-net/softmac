// BackupDrive: ver BDVersionsWindow.h.
// Licencia: MIT (ver ../LICENSE).

#import "BDVersionsWindow.h"

#import "BDRunner.h"

@interface BDVersionsWindow ()
@property(copy) NSString *folder;
@property(copy) NSString *versionsMac;
@property(copy) void (^changed)(void);
@property(copy) NSArray<NSDictionary *> *all;
@property(copy) NSArray<NSDictionary *> *rows;
@property(strong) NSTableView *table;
@property(strong) NSSearchField *search;
@property(strong) NSTextField *status;
@property(strong) NSButton *restoreButton;
@property(strong) NSButton *finderButton;
@property BOOL busy;
@end

@implementation BDVersionsWindow

- (instancetype)initWithFolder:(NSString *)folder
                   versionsMac:(NSString *)versionsMac
                       changed:(void (^)(void))changed {
  NSWindow *window = [[NSWindow alloc]
      initWithContentRect:NSMakeRect(0, 0, 680, 440)
                styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable |
                          NSWindowStyleMaskMiniaturizable
                  backing:NSBackingStoreBuffered
                    defer:NO];
  if ((self = [super initWithWindow:window])) {
    _folder = [folder copy];
    _versionsMac = [versionsMac copy];
    _changed = [changed copy];
    _all = @[];
    _rows = @[];
    window.title = [NSString stringWithFormat:@"Versiones de «%@»", folder.lastPathComponent];
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

- (void)buildIn:(NSView *)content {
  NSView *v = content;
  self.search = [[NSSearchField alloc] initWithFrame:NSMakeRect(20, 400, 640, 24)];
  self.search.placeholderString = @"Buscar por nombre de fichero";
  self.search.delegate = self;
  self.search.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
  [v addSubview:self.search];

  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 60, 640, 330)];
  scroll.hasVerticalScroller = YES;
  scroll.borderType = NSBezelBorder;
  scroll.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  self.table = [[NSTableView alloc] initWithFrame:scroll.bounds];
  [self.table addTableColumn:[self column:@"original" title:@"Fichero" width:330]];
  [self.table addTableColumn:[self column:@"date" title:@"Guardada" width:130]];
  [self.table addTableColumn:[self column:@"side" title:@"Dónde" width:70]];
  [self.table addTableColumn:[self column:@"size" title:@"Tamaño" width:80]];
  self.table.dataSource = self;
  self.table.delegate = self;
  self.table.allowsMultipleSelection = NO;
  self.table.usesAlternatingRowBackgroundColors = YES;
  self.table.target = self;
  self.table.doubleAction = @selector(restore:);
  scroll.documentView = self.table;
  [v addSubview:scroll];

  self.status = [NSTextField labelWithString:@"Cargando…"];
  self.status.frame = NSMakeRect(20, 22, 300, 18);
  self.status.autoresizingMask = NSViewWidthSizable | NSViewMaxYMargin;
  self.status.textColor = NSColor.secondaryLabelColor;
  [v addSubview:self.status];

  self.restoreButton = [NSButton buttonWithTitle:@"Restaurar…" target:self action:@selector(restore:)];
  self.restoreButton.frame = NSMakeRect(550, 14, 110, 32);
  self.restoreButton.autoresizingMask = NSViewMinXMargin | NSViewMaxYMargin;
  [v addSubview:self.restoreButton];
  self.finderButton = [NSButton buttonWithTitle:@"Mostrar en el Finder" target:self action:@selector(showInFinder:)];
  self.finderButton.frame = NSMakeRect(380, 14, 170, 32);
  self.finderButton.autoresizingMask = NSViewMinXMargin | NSViewMaxYMargin;
  [v addSubview:self.finderButton];
  [self updateButtons];
}

#pragma mark - Datos

- (void)reload {
  self.status.stringValue = @"Cargando…";
  [BDRunner run:BDRunner.ctlScript
           args:@[ @"versions", @"list", self.folder ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             if (status != 0) {
               self.all = @[];
               [self applyFilter];
               self.status.stringValue = err.length ? err : @"No se pueden leer las versiones.";
               return;
             }
             id list = [NSJSONSerialization JSONObjectWithData:[out dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:0
                                                         error:nil];
             NSMutableArray *rows = [NSMutableArray array];
             if ([list isKindOfClass:NSArray.class]) {
               for (id row in list)
                 if ([row isKindOfClass:NSDictionary.class]) [rows addObject:row];
             }
             self.all = rows;
             [self applyFilter];
           }];
}

- (void)applyFilter {
  NSString *q = [self.search.stringValue
      stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
  if (!q.length) {
    self.rows = self.all;
  } else {
    NSMutableArray *rows = [NSMutableArray array];
    for (NSDictionary *row in self.all) {
      NSString *original = [row[@"original"] isKindOfClass:NSString.class] ? row[@"original"] : @"";
      if ([original rangeOfString:q options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location !=
          NSNotFound)
        [rows addObject:row];
    }
    self.rows = rows;
  }
  [self.table reloadData];
  self.status.stringValue =
      self.all.count ? [NSString stringWithFormat:@"%lu de %lu versiones", (unsigned long)self.rows.count,
                                                  (unsigned long)self.all.count]
                     : @"No hay versiones guardadas de esta carpeta.";
  [self updateButtons];
}

- (void)controlTextDidChange:(NSNotification *)notification {
  [self applyFilter];
}

- (NSDictionary *)selected {
  NSInteger row = self.table.selectedRow;
  return (row >= 0 && (NSUInteger)row < self.rows.count) ? self.rows[(NSUInteger)row] : nil;
}

- (void)updateButtons {
  NSDictionary *row = self.selected;
  self.restoreButton.enabled = row != nil && !self.busy;
  self.finderButton.enabled = row != nil && [row[@"side"] isEqual:@"mac"] && self.versionsMac.length;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  [self updateButtons];
}

- (NSString *)dateText:(NSString *)iso {
  // «2026-11-03T15:11:09» → «03/11/2026 15:11»
  if (![iso isKindOfClass:NSString.class] || iso.length < 16) return @"";
  return [NSString stringWithFormat:@"%@/%@/%@ %@", [iso substringWithRange:NSMakeRange(8, 2)],
                                    [iso substringWithRange:NSMakeRange(5, 2)], [iso substringToIndex:4],
                                    [iso substringWithRange:NSMakeRange(11, 5)]];
}

#pragma mark - Tabla

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return (NSInteger)self.rows.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row {
  if (row < 0 || (NSUInteger)row >= self.rows.count) return @"";
  NSDictionary *r = self.rows[(NSUInteger)row];
  NSString *key = column.identifier;
  if ([key isEqualToString:@"date"]) return [self dateText:r[@"date"]];
  if ([key isEqualToString:@"side"]) return [r[@"side"] isEqual:@"mac"] ? @"Mac" : @"Drive";
  if ([key isEqualToString:@"size"]) {
    NSNumber *size = [r[@"size"] isKindOfClass:NSNumber.class] ? r[@"size"] : @0;
    return [NSByteCountFormatter stringFromByteCount:size.longLongValue
                                          countStyle:NSByteCountFormatterCountStyleFile];
  }
  return r[@"original"] ?: @"";
}

#pragma mark - Acciones

- (void)restore:(id)sender {
  NSDictionary *row = self.selected;
  if (!row || self.busy) return;
  NSString *original = row[@"original"];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = [NSString stringWithFormat:@"¿Restaurar «%@» tal como estaba el %@?",
                                                 original.lastPathComponent, [self dateText:row[@"date"]]];
  alert.informativeText = [NSString
      stringWithFormat:@"Se pondrá en «%@» dentro de la carpeta. Si ahí hay un fichero, se guarda antes en "
                       @"versiones, así que no se pierde nada. La próxima sincronización lo llevará a Drive.",
                       original];
  [alert addButtonWithTitle:@"Restaurar"];
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
  self.status.stringValue = @"Restaurando…";
  [BDRunner run:BDRunner.ctlScript
           args:@[ @"versions", @"restore", self.folder, row[@"side"], row[@"path"] ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             self.busy = NO;
             NSAlert *alert = [[NSAlert alloc] init];
             alert.messageText = status == 0 ? @"Restaurado" : @"No se pudo restaurar";
             alert.informativeText = status == 0 ? out : (err.length ? err : @"");
             [alert beginSheetModalForWindow:self.window completionHandler:nil];
             if (self.changed) self.changed();
             [self reload];
           }];
}

- (void)showInFinder:(id)sender {
  NSDictionary *row = self.selected;
  if (!row || ![row[@"side"] isEqual:@"mac"] || !self.versionsMac.length) return;
  NSString *path = [self.versionsMac stringByAppendingPathComponent:row[@"path"]];
  [NSWorkspace.sharedWorkspace activateFileViewerSelectingURLs:@[ [NSURL fileURLWithPath:path] ]];
}

@end
