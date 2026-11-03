// BackupDrive: ver BDSetup.h.
// Licencia: MIT (ver ../LICENSE).

#import "BDSetup.h"

#import "BDRunner.h"

static NSString *const kGuideURL =
    @"https://github.com/lamosquita-net/softmac/blob/main/BackupDrive/docs/clave-google.md";
static NSString *const kAccount = @"gdrive";

@interface BDSetup ()
@property(copy) void (^changed)(void);
@property(copy) void (^simulate)(NSString *folder);
@property(readwrite) BOOL busy;
@property(strong) NSPanel *panel;
@property(strong) NSTask *task;
@end

@implementation BDSetup

- (instancetype)initWithChanged:(void (^)(void))changed simulate:(void (^)(NSString *folder))simulate {
  if ((self = [super init])) {
    _changed = [changed copy];
    _simulate = [simulate copy];
  }
  return self;
}

- (BOOL)hasAccountIn:(NSString *)appSupportDir {
  NSString *conf = [appSupportDir stringByAppendingPathComponent:@"backupdrive.conf"];
  NSString *text = [NSString stringWithContentsOfFile:conf encoding:NSUTF8StringEncoding error:nil];
  NSString *section = [NSString stringWithFormat:@"[%@]", kAccount];
  for (NSString *line in [text componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet]) {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if ([trimmed isEqualToString:section]) return YES;
  }
  return NO;
}

#pragma mark - Utilidades

- (NSModalResponse)alert:(NSString *)message info:(NSString *)info buttons:(NSArray<NSString *> *)buttons {
  [NSApp activateIgnoringOtherApps:YES];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = message;
  alert.informativeText = info ?: @"";
  for (NSString *title in buttons) [alert addButtonWithTitle:title];
  return [alert runModal];
}

- (void)alert:(NSString *)message info:(NSString *)info {
  [self alert:message info:info buttons:@[]];
}

- (NSString *)trim:(NSString *)s {
  return [s stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] ?: @"";
}

- (NSTextField *)label:(NSString *)text frame:(NSRect)frame {
  NSTextField *label = [NSTextField labelWithString:text];
  label.frame = frame;
  label.alignment = NSTextAlignmentRight;
  return label;
}

#pragma mark - Conectar

- (void)connect {
  if (self.busy) return;
  NSString *clientId = @"";
  while (YES) {
    [NSApp activateIgnoringOtherApps:YES];
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Conectar con Google Drive";
    alert.informativeText =
        @"BackupDrive usa tu propia clave de Google: el ID de cliente y el secreto que creaste en "
        @"Google Cloud. Si aún no la tienes, «Cómo conseguirla» abre la guía (se hace una sola vez).";
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, 66)];
    [view addSubview:[self label:@"ID de cliente:" frame:NSMakeRect(0, 42, 104, 18)]];
    NSTextField *idField = [[NSTextField alloc] initWithFrame:NSMakeRect(110, 38, 290, 24)];
    idField.placeholderString = @"….apps.googleusercontent.com";
    idField.stringValue = clientId;
    [view addSubview:idField];
    [view addSubview:[self label:@"Secreto:" frame:NSMakeRect(0, 6, 104, 18)]];
    NSSecureTextField *secretField = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(110, 2, 290, 24)];
    [view addSubview:secretField];
    idField.nextKeyView = secretField;
    alert.accessoryView = view;
    [alert addButtonWithTitle:@"Conectar"];
    [alert addButtonWithTitle:@"Cancelar"];
    [alert addButtonWithTitle:@"Cómo conseguirla"];
    [alert layout];
    alert.window.initialFirstResponder = idField;
    NSModalResponse response = [alert runModal];
    if (response == NSAlertThirdButtonReturn) {
      [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:kGuideURL]];
      return;
    }
    if (response != NSAlertFirstButtonReturn) return;
    clientId = [self trim:idField.stringValue];
    NSString *secret = [self trim:secretField.stringValue];
    if (![clientId hasSuffix:@".apps.googleusercontent.com"] || secret.length == 0) {
      [self alert:@"Falta algo"
             info:@"El ID de cliente termina en .apps.googleusercontent.com y el secreto no puede "
                  @"estar vacío. Cópialos tal cual de Google Cloud."];
      continue;
    }
    [self runConnect:clientId secret:secret];
    return;
  }
}

- (void)runConnect:(NSString *)clientId secret:(NSString *)secret {
  NSPanel *panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 440, 140)
                                              styleMask:NSWindowStyleMaskTitled
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
  panel.title = @"Conectar con Google Drive";
  panel.releasedWhenClosed = NO;
  NSTextField *text = [NSTextField
      wrappingLabelWithString:@"Autoriza el acceso en el navegador que se acaba de abrir. Elige la cuenta "
                              @"de Google de tu Drive. Si dice «Google no ha verificado esta app», pulsa "
                              @"«Configuración avanzada» y después «Ir a BackupDrive»."];
  text.frame = NSMakeRect(20, 52, 400, 72);
  NSProgressIndicator *spinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(20, 20, 16, 16)];
  spinner.style = NSProgressIndicatorStyleSpinning;
  spinner.controlSize = NSControlSizeSmall;
  [spinner startAnimation:nil];
  NSButton *cancel = [NSButton buttonWithTitle:@"Cancelar" target:self action:@selector(cancelConnect:)];
  cancel.frame = NSMakeRect(330, 12, 96, 32);
  [panel.contentView addSubview:text];
  [panel.contentView addSubview:spinner];
  [panel.contentView addSubview:cancel];
  [panel center];
  [NSApp activateIgnoringOtherApps:YES];
  [panel makeKeyAndOrderFront:nil];
  self.panel = panel;
  self.busy = YES;

  // El secreto va por el entorno, no como argumento (se vería en la lista de procesos).
  self.task = [BDRunner run:BDRunner.ctlScript
                       args:@[ @"connect", @"--client-id", clientId ]
                        env:@{@"BACKUPDRIVE_CLIENT_SECRET" : secret}
                       done:^(int status, NSString *out, NSString *err) {
                         [self.panel orderOut:nil];
                         self.panel = nil;
                         self.task = nil;
                         self.busy = NO;
                         if (self.changed) self.changed();
                         if (status == 130) return;  // cancelado: la cuenta anterior sigue igual
                         if (status != 0) {
                           [self alert:@"No se pudo conectar con Google Drive"
                                  info:err.length ? err : @"No se ha cambiado nada."];
                           return;
                         }
                         NSModalResponse r = [self
                             alert:@"Conectado con Google Drive"
                              info:@"Ahora elige qué carpeta del Mac quieres sincronizar con tu Drive."
                           buttons:@[ @"Añadir carpeta…", @"Más tarde" ]];
                         if (r == NSAlertFirstButtonReturn) [self addFolder];
                       }];
}

- (void)cancelConnect:(id)sender {
  [self.task terminate];  // backupdrive-ctl.sh para a rclone y deja la cuenta como estaba
}

#pragma mark - Carpetas

- (NSArray<NSString *> *)folderNames:(NSString *)json {
  NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
  id list = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
  NSMutableArray<NSString *> *names = [NSMutableArray array];
  if ([list isKindOfClass:NSArray.class]) {
    for (id entry in list) {
      if (![entry isKindOfClass:NSDictionary.class]) continue;
      id name = entry[@"Name"];
      if ([name isKindOfClass:NSString.class] && ![name hasSuffix:@" (versiones)"]) [names addObject:name];
    }
  }
  return [names sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
}

- (void)addFolder {
  if (self.busy) return;
  [NSApp activateIgnoringOtherApps:YES];
  NSOpenPanel *open = [NSOpenPanel openPanel];
  open.canChooseDirectories = YES;
  open.canChooseFiles = NO;
  open.canCreateDirectories = YES;
  open.allowsMultipleSelection = NO;
  open.prompt = @"Elegir";
  open.message = @"Elige la carpeta del Mac que quieres sincronizar con Google Drive.";
  if ([open runModal] != NSModalResponseOK || !open.URL.path.length) return;
  NSString *local = open.URL.path;
  self.busy = YES;
  [BDRunner run:BDRunner.ctlScript
           args:@[ @"folders", [kAccount stringByAppendingString:@":"] ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             self.busy = NO;
             if (status != 0) {
               [self alert:@"No se puede leer tu Google Drive"
                      info:err.length ? err : @"Comprueba la conexión a Internet."];
               return;
             }
             [self askDriveFolderFor:local names:[self folderNames:out] typed:local.lastPathComponent];
           }];
}

- (void)askDriveFolderFor:(NSString *)local names:(NSArray<NSString *> *)names typed:(NSString *)typed {
  [NSApp activateIgnoringOtherApps:YES];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = [NSString
      stringWithFormat:@"¿Con qué carpeta de Google Drive se sincroniza «%@»?", local.lastPathComponent];
  alert.informativeText =
      @"Elige una carpeta de tu Drive o escribe un nombre nuevo (se creará). Para una subcarpeta, "
      @"escribe la ruta: Trabajo/Clientes. No puede ser todo el Drive: las versiones se guardan en "
      @"una carpeta a su lado.";
  NSComboBox *combo = [[NSComboBox alloc] initWithFrame:NSMakeRect(0, 0, 320, 26)];
  [combo addItemsWithObjectValues:names];
  combo.completes = YES;
  combo.stringValue = typed;
  alert.accessoryView = combo;
  [alert addButtonWithTitle:@"Añadir"];
  [alert addButtonWithTitle:@"Cancelar"];
  [alert layout];
  alert.window.initialFirstResponder = combo;
  if ([alert runModal] != NSAlertFirstButtonReturn) return;

  NSCharacterSet *strip = [NSCharacterSet characterSetWithCharactersInString:@"/ \t\n"];
  NSString *path = [combo.stringValue stringByTrimmingCharactersInSet:strip];
  if (!path.length) {
    [self alert:@"Falta la carpeta de Drive" info:@"Escribe o elige una carpeta; no puede ser todo el Drive."];
    [self askDriveFolderFor:local names:names typed:typed];
    return;
  }
  NSString *remote = [NSString stringWithFormat:@"%@:%@", kAccount, path];
  NSString *ctl = BDRunner.ctlScript;
  self.busy = YES;
  // Primero el perfil (valida solapes y rutas sin tocar Drive); después se crea la carpeta en Drive si no existe.
  [BDRunner run:ctl
           args:@[ @"profile", @"add", local, remote ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             if (status != 0) {
               self.busy = NO;
               [self alert:@"No se pudo añadir la carpeta" info:err];
               return;
             }
             [BDRunner run:ctl
                      args:@[ @"mkdir", remote ]
                       env:nil
                      done:^(int mkStatus, NSString *mkOut, NSString *mkErr) {
                        if (mkStatus != 0) {
                          [BDRunner run:ctl
                                   args:@[ @"profile", @"remove", local ]
                                    env:nil
                                   done:^(int s, NSString *o, NSString *e) {
                                     self.busy = NO;
                                     if (self.changed) self.changed();
                                   }];
                          [self alert:@"No se pudo crear la carpeta en Google Drive"
                                 info:mkErr.length ? mkErr : @"Comprueba la conexión a Internet."];
                          return;
                        }
                        self.busy = NO;
                        if (self.changed) self.changed();
                        NSString *info = [NSString
                            stringWithFormat:@"«%@» se sincronizará con «%@» de tu Drive. Antes de la "
                                             @"primera sincronización, BackupDrive la simula para que veas "
                                             @"qué haría; la simulación no cambia nada.",
                                             local.lastPathComponent, path];
                        NSModalResponse r = [self alert:@"Carpeta añadida"
                                                   info:info
                                                buttons:@[ @"Simular ahora", @"Más tarde" ]];
                        if (r == NSAlertFirstButtonReturn && self.simulate) self.simulate(local);
                      }];
           }];
}

#pragma mark - Conflictos

- (void)resolveConflictsIn:(NSString *)folder {
  if (self.busy || !folder.length) return;
  self.busy = YES;
  [BDRunner run:BDRunner.ctlScript
           args:@[ @"conflicts", @"list", folder ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             self.busy = NO;
             if (status != 0) {
               [self alert:@"No se pueden leer los conflictos" info:err];
               return;
             }
             id rows = [NSJSONSerialization JSONObjectWithData:[out dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:0
                                                         error:nil];
             NSMutableArray<NSString *> *order = [NSMutableArray array];
             NSMutableDictionary<NSString *, NSMutableArray *> *byOriginal = [NSMutableDictionary dictionary];
             if ([rows isKindOfClass:NSArray.class]) {
               for (id row in rows) {
                 if (![row isKindOfClass:NSDictionary.class]) continue;
                 NSString *original = row[@"original"];
                 if (![original isKindOfClass:NSString.class]) continue;
                 if (!byOriginal[original]) {
                   byOriginal[original] = [NSMutableArray array];
                   [order addObject:original];
                 }
                 [byOriginal[original] addObject:row];
               }
             }
             if (!order.count) {
               [self alert:@"No hay conflictos" info:@"Ya no queda ningún fichero con dos copias."];
               if (self.changed) self.changed();
               return;
             }
             [self resolve:order index:0 copies:byOriginal folder:folder];
           }];
}

- (NSString *)describeCopy:(NSDictionary *)copy {
  NSString *side = copy[@"side"];
  if ([side isEqual:@"mac"]) return @"la del Mac";
  if ([side isEqual:@"drive"]) return @"la de Drive";
  return [NSString stringWithFormat:@"«%@»", [copy[@"path"] lastPathComponent]];
}

- (void)resolve:(NSArray<NSString *> *)order
          index:(NSUInteger)index
         copies:(NSDictionary<NSString *, NSArray *> *)byOriginal
         folder:(NSString *)folder {
  if (index >= order.count) {
    if (self.changed) self.changed();
    return;
  }
  NSString *original = order[index];
  NSArray *copies = byOriginal[original];
  NSUInteger choosable = MIN(copies.count, (NSUInteger)3);
  [NSApp activateIgnoringOtherApps:YES];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = [NSString stringWithFormat:@"«%@» se cambió en el Mac y en Google Drive (%lu de %lu)",
                                                 original.lastPathComponent, (unsigned long)(index + 1),
                                                 (unsigned long)order.count];
  NSMutableString *info = [NSMutableString
      stringWithString:@"BackupDrive guardó las dos copias para que elijas. La que no elijas irá a versiones: "
                       @"se puede recuperar.\n\n"];
  for (NSDictionary *copy in copies) {
    NSNumber *size = [copy[@"size"] isKindOfClass:NSNumber.class] ? copy[@"size"] : @0;
    NSString *date = [copy[@"date"] isKindOfClass:NSString.class] ? copy[@"date"] : @"";
    if (date.length >= 16) date = [[date substringToIndex:16] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    [info appendFormat:@"• %@: %@, modificada %@\n", [self describeCopy:copy],
                       [NSByteCountFormatter stringFromByteCount:size.longLongValue
                                                      countStyle:NSByteCountFormatterCountStyleFile],
                       date];
  }
  alert.informativeText = info;
  for (NSUInteger i = 0; i < choosable; i++) {
    [alert addButtonWithTitle:[NSString stringWithFormat:@"Quedarme con %@", [self describeCopy:copies[i]]]];
  }
  [alert addButtonWithTitle:@"Decidir luego"];
  [alert addButtonWithTitle:@"Mostrar en el Finder"];
  NSInteger choice = [alert runModal] - NSAlertFirstButtonReturn;

  if (choice >= 0 && (NSUInteger)choice < choosable) {
    self.busy = YES;
    [BDRunner run:BDRunner.ctlScript
             args:@[ @"conflicts", @"keep", folder, copies[choice][@"path"] ]
              env:nil
             done:^(int status, NSString *out, NSString *err) {
               self.busy = NO;
               if (status != 0) {
                 [self alert:@"No se pudo resolver el conflicto" info:err];
                 if (self.changed) self.changed();
                 return;
               }
               [self resolve:order index:index + 1 copies:byOriginal folder:folder];
             }];
  } else if ((NSUInteger)choice == choosable) {
    [self resolve:order index:index + 1 copies:byOriginal folder:folder];
  } else {
    NSMutableArray<NSURL *> *urls = [NSMutableArray array];
    for (NSDictionary *copy in copies) {
      [urls addObject:[NSURL fileURLWithPath:[folder stringByAppendingPathComponent:copy[@"path"]]]];
    }
    [NSWorkspace.sharedWorkspace activateFileViewerSelectingURLs:urls];
    if (self.changed) self.changed();
  }
}

- (void)removeFolder:(NSString *)folder {
  if (self.busy || !folder.length) return;
  NSModalResponse r = [self
        alert:[NSString stringWithFormat:@"¿Dejar de sincronizar «%@»?", folder.lastPathComponent]
         info:@"No se borra nada: los ficheros y sus versiones se quedan en el Mac y en Google Drive. "
              @"Solo deja de sincronizarse."
      buttons:@[ @"Dejar de sincronizar", @"Cancelar" ]];
  if (r != NSAlertFirstButtonReturn) return;
  self.busy = YES;
  [BDRunner run:BDRunner.ctlScript
           args:@[ @"profile", @"remove", folder ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             self.busy = NO;
             if (self.changed) self.changed();
             if (status != 0) [self alert:@"No se pudo quitar la carpeta" info:err];
           }];
}

@end
