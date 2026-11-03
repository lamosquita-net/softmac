// BackupDrive: app de barra de menús para macOS 10.14+ (x86_64).
//
// No sincroniza por sí misma: muestra el estado que escribe scripts/backupdrive-sync.sh en
// ~/Library/Application Support/BackupDrive/status.json, lanza ese script a petición y activa o
// desactiva el LaunchAgent que lo ejecuta cada hora. Lo demás (conectar con Drive, carpetas) lo hace
// backupdrive-ctl.sh (BDSetup). Sin nib ni Xcode: ver build-app.sh.
//
// Licencia: MIT (ver ../LICENSE).

#import "AppDelegate.h"
#import "BDRunner.h"
#import "BDSetup.h"
#import "BDVersionsWindow.h"

static NSString *const kAgentLabel = @"net.lamosquita.backupdrive";
// Abrir la app al iniciar sesión: un LaunchAgent propio que hace «open» (sin la API de ítems de inicio, obsoleta desde
// 10.11, ni SMLoginItemSetEnabled, que exige una app auxiliar). Basta con que el fichero exista; launchd lo lee al entrar.
static NSString *const kLoginLabel = @"net.lamosquita.backupdrive.app";
static const NSTimeInterval kPollSeconds = 2.0;

@interface AppDelegate ()
@property(strong) NSStatusItem *statusItem;
@property(strong) NSTimer *timer;
@property(copy) NSDate *statusDate;  // mtime de status.json ya leído
@property(copy) NSDictionary *status;
@property(strong) NSTask *manualRun;
@property(strong) BDSetup *setup;
@property(copy) NSArray<NSDictionary *> *profiles;
@property(strong) NSMutableDictionary<NSString *, BDVersionsWindow *> *versionWindows;  // de backupdrive-ctl.sh profile list (nil: aún no)
@end

@implementation AppDelegate

#pragma mark - Rutas

- (NSString *)appSupportDir {
  NSString *override = NSProcessInfo.processInfo.environment[@"BACKUPDRIVE_DIR"];
  if (override.length) return override;
  return [NSHomeDirectory()
      stringByAppendingPathComponent:@"Library/Application Support/BackupDrive"];
}

- (NSString *)statusPath {
  return [self.appSupportDir stringByAppendingPathComponent:@"status.json"];
}

- (NSString *)logPath {
  NSString *log = self.status[@"log"];
  if ([log isKindOfClass:NSString.class] && log.length) return log;
  return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Logs/BackupDrive/backupdrive.log"];
}

- (NSString *)agentPlistPath {
  return [NSHomeDirectory()
      stringByAppendingPathComponent:
          [NSString stringWithFormat:@"Library/LaunchAgents/%@.plist", kAgentLabel]];
}

#pragma mark - Arranque

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
  self.statusItem.button.toolTip = @"BackupDrive";
  NSMenu *menu = [[NSMenu alloc] initWithTitle:@"BackupDrive"];
  menu.delegate = self;
  menu.autoenablesItems = NO;
  self.statusItem.menu = menu;

  [self reloadStatusForce:YES];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:kPollSeconds
                                                target:self
                                              selector:@selector(poll:)
                                              userInfo:nil
                                               repeats:YES];
  self.timer.tolerance = 0.5;

  __weak AppDelegate *weakSelf = self;
  self.setup = [[BDSetup alloc] initWithChanged:^{
    [weakSelf refreshProfiles];
  }
      simulate:^(NSString *folder) {
        [weakSelf simulateFolder:folder];
      }];
  [self refreshProfiles];
}

- (void)poll:(NSTimer *)timer {
  [self reloadStatusForce:NO];
}

#pragma mark - Estado

// Relee status.json si ha cambiado. El script lo escribe de forma atómica (mv), así que nunca se
// lee a medias.
- (void)reloadStatusForce:(BOOL)force {
  NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:self.statusPath
                                                                       error:nil];
  NSDate *mtime = attrs.fileModificationDate;
  if (!force && ((mtime == nil && self.statusDate == nil) ||
                 (mtime && [mtime isEqualToDate:self.statusDate]))) {
    return;
  }
  self.statusDate = mtime;
  NSDictionary *parsed = nil;
  NSData *data = mtime ? [NSData dataWithContentsOfFile:self.statusPath] : nil;
  if (data) {
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ([json isKindOfClass:NSDictionary.class]) parsed = json;
  }
  self.status = parsed;
  [self updateIcon];
  [self refreshProfiles];
}

// La lista de carpetas sale de backupdrive-ctl.sh (el fichero profiles), no de status.json: así una carpeta
// recién añadida o quitada se ve en el menú sin esperar a la siguiente sincronización.
- (void)refreshProfiles {
  __weak AppDelegate *weakSelf = self;
  [BDRunner run:BDRunner.ctlScript
           args:@[ @"profile", @"list" ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             if (status != 0) return;  // sin backupdrive-ctl.sh (instalación antigua): se usa status.json
             id list = [NSJSONSerialization JSONObjectWithData:[out dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:0
                                                         error:nil];
             if ([list isKindOfClass:NSArray.class]) weakSelf.profiles = list;
           }];
}

// Perfiles para el menú: los de backupdrive-ctl.sh con el código de salida de status.json, o los de status.json.
- (NSArray<NSDictionary *> *)menuProfiles {
  NSArray *fromStatus = self.status[@"profiles"];
  if (![fromStatus isKindOfClass:NSArray.class]) fromStatus = @[];
  if (!self.profiles) return fromStatus;
  NSMutableArray *merged = [NSMutableArray array];
  for (NSDictionary *p in self.profiles) {
    if (![p isKindOfClass:NSDictionary.class]) continue;
    NSMutableDictionary *m = [p mutableCopy];
    for (NSDictionary *q in fromStatus) {
      if ([q isKindOfClass:NSDictionary.class] && [q[@"local"] isEqual:p[@"local"]] && q[@"exit"])
        m[@"exit"] = q[@"exit"];
    }
    [merged addObject:m];
  }
  return merged;
}

- (NSString *)field:(NSString *)key of:(NSDictionary *)dict {
  id value = dict[key];
  return [value isKindOfClass:NSString.class] ? value : @"";
}

- (BOOL)isRunning {
  if (self.manualRun.isRunning) return YES;
  return [[self field:@"state" of:self.status] isEqualToString:@"running"];
}

// Algún perfil pide atención aunque la última ejecución fuera bien (p. ej. con --profile).
- (BOOL)anyProfileNeedsAttention {
  NSArray *profiles = self.status[@"profiles"];
  if (![profiles isKindOfClass:NSArray.class]) return NO;
  for (NSDictionary *p in profiles) {
    if (![p isKindOfClass:NSDictionary.class]) continue;
    NSString *r = [self field:@"result" of:p];
    if ([r isEqualToString:@"error"] || [r isEqualToString:@"skipped"] ||
        [r isEqualToString:@"needs-resync"] || [r isEqualToString:@"blocked"])
      return YES;
  }
  return NO;
}

- (void)updateIcon {
  NSString *name = @"menubar_BackupDriveTemplate";
  NSString *result = [self field:@"result" of:self.status];
  if (self.isRunning) {
    name = @"menubar_BackupDrive-syncTemplate";
  } else if ([result isEqualToString:@"error"] || [result isEqualToString:@"interrupted"] ||
             self.anyProfileNeedsAttention) {
    name = @"menubar_BackupDrive-errorTemplate";
  }
  NSImage *image = [NSImage imageNamed:name];
  image.template = YES;  // negro en modo claro, blanco en oscuro
  self.statusItem.button.image = image;
}

- (NSDate *)dateFromISO:(NSString *)iso {
  if (!iso.length) return nil;
  static NSISO8601DateFormatter *formatter;
  if (!formatter) formatter = [[NSISO8601DateFormatter alloc] init];
  return [formatter dateFromString:iso];
}

// "hace 5 min", "hoy 18:05", "29/09 18:05". NSRelativeDateTimeFormatter es de 10.15.
- (NSString *)describeDate:(NSDate *)date {
  if (!date) return @"—";
  NSTimeInterval ago = -date.timeIntervalSinceNow;
  if (ago < 60) return @"hace un momento";
  if (ago < 3600) return [NSString stringWithFormat:@"hace %d min", (int)(ago / 60)];
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  f.dateFormat = [NSCalendar.currentCalendar isDateInToday:date] ? @"'hoy' HH:mm" : @"dd/MM HH:mm";
  return [f stringFromDate:date];
}

- (NSString *)summaryLine {
  if (!self.status) {
    return [NSFileManager.defaultManager fileExistsAtPath:self.statusPath]
               ? @"Estado ilegible (status.json)"
               : @"Todavía no se ha sincronizado";
  }
  NSDate *started = [self dateFromISO:[self field:@"started" of:self.status]];
  NSDate *finished = [self dateFromISO:[self field:@"finished" of:self.status]];
  NSString *result = [self field:@"result" of:self.status];
  if (self.isRunning) {
    return [NSString stringWithFormat:@"Sincronizando… (empezó %@)", [self describeDate:started]];
  }
  NSString *what = @"terminada";
  if ([result isEqualToString:@"ok"]) what = @"correcta";
  else if ([result isEqualToString:@"error"]) what = @"con errores";
  else if ([result isEqualToString:@"interrupted"]) what = @"interrumpida";
  return [NSString stringWithFormat:@"Última sincronización %@: %@", what,
                                    [self describeDate:finished]];
}

#pragma mark - LaunchAgent

- (BOOL)agentLoaded {
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = @"/bin/launchctl";
  task.arguments = @[ @"list", kAgentLabel ];
  task.standardOutput = NSFileHandle.fileHandleWithNullDevice;
  task.standardError = NSFileHandle.fileHandleWithNullDevice;
  @try {
    [task launch];
    [task waitUntilExit];
  } @catch (NSException *e) {
    return NO;
  }
  return task.terminationStatus == 0;
}

- (void)toggleAgent:(NSMenuItem *)item {
  BOOL loaded = self.agentLoaded;
  if (!loaded && ![NSFileManager.defaultManager fileExistsAtPath:self.agentPlistPath]) {
    [self alert:@"No está instalado el LaunchAgent"
           info:[NSString stringWithFormat:@"Copia launchd/%@.plist a ~/Library/LaunchAgents/ "
                                           @"(ver BackupDrive/README.md).",
                                           kAgentLabel]];
    return;
  }
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = @"/bin/launchctl";
  task.arguments = @[ loaded ? @"unload" : @"load", @"-w", self.agentPlistPath ];
  [task launch];
  [task waitUntilExit];
}

#pragma mark - Acciones

// Lanza el motor. El script tiene su propio bloqueo: si launchd ya está sincronizando, sale sin hacer nada.
- (void)runEngine:(NSArray<NSString *> *)arguments then:(void (^)(int status))done {
  if (self.isRunning) return;
  if (![NSFileManager.defaultManager isExecutableFileAtPath:BDRunner.syncScript]) {
    [self alert:@"No encuentro el motor de BackupDrive"
           info:[NSString stringWithFormat:@"Falta %@ (ver BackupDrive/README.md).", BDRunner.syncScript]];
    return;
  }
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = BDRunner.syncScript;
  task.arguments = arguments;
  task.standardInput = NSFileHandle.fileHandleWithNullDevice;
  task.standardOutput = NSFileHandle.fileHandleWithNullDevice;
  task.standardError = NSFileHandle.fileHandleWithNullDevice;
  __weak AppDelegate *weakSelf = self;
  task.terminationHandler = ^(NSTask *t) {
    int status = t.terminationStatus;
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.manualRun = nil;
      [weakSelf reloadStatusForce:YES];
      if (done) done(status);
    });
  };
  self.manualRun = task;
  [task launch];
  [self updateIcon];
}

- (void)syncNow:(NSMenuItem *)item {
  [self runEngine:@[] then:nil];
}

- (void)simulateFirstSync:(NSMenuItem *)item {
  [self simulateFolder:item.representedObject];
}

- (void)simulateFolder:(NSString *)folder {
  [self reviewFolder:folder resync:YES];
}

- (void)reviewBlocked:(NSMenuItem *)item {
  [self reviewFolder:item.representedObject resync:NO];
}

// Simula la pasada (no cambia nada) y enseña el plan en lenguaje llano. Titín, 03-11: siempre «Ver qué cambia»
// antes de «Continuar de todos modos»; por eso continuar solo se ofrece desde aquí.
- (void)reviewFolder:(NSString *)folder resync:(BOOL)resync {
  if (!folder.length) return;
  NSArray *args = resync ? @[ @"--resync", @"--dry-run", @"--profile", folder ]
                         : @[ @"--dry-run", @"--profile", folder ];
  __weak AppDelegate *weakSelf = self;
  NSDate *launched = [NSDate dateWithTimeIntervalSinceNow:-2];
  [self runEngine:args
             then:^(int status) {
               [BDRunner run:BDRunner.ctlScript
                        args:@[ @"plan", folder ]
                         env:nil
                        done:^(int planStatus, NSString *out, NSString *err) {
                          NSDictionary *plan = nil;
                          if (planStatus == 0) {
                            id json = [NSJSONSerialization
                                JSONObjectWithData:[out dataUsingEncoding:NSUTF8StringEncoding]
                                           options:0
                                             error:nil];
                            if ([json isKindOfClass:NSDictionary.class]) plan = json;
                          }
                          // Si launchd ya estaba sincronizando, el motor sale sin simular: el plan sería el viejo.
                          NSDate *made = [weakSelf dateFromISO:[weakSelf field:@"date" of:plan]];
                          if (plan && made && [made compare:launched] == NSOrderedAscending) {
                            [weakSelf alert:@"BackupDrive estaba sincronizando"
                                       info:@"No se ha podido simular ahora. Vuelve a intentarlo cuando termine."];
                            return;
                          }
                          [weakSelf showPlan:plan folder:folder resync:resync failed:status != 0 && !plan];
                        }];
             }];
}

- (NSArray *)planList:(NSDictionary *)dict key:(NSString *)key {
  id list = [dict isKindOfClass:NSDictionary.class] ? dict[key] : nil;
  return [list isKindOfClass:NSArray.class] ? list : @[];
}

- (NSUInteger)appendSection:(NSString *)title items:(NSArray *)items to:(NSMutableString *)text {
  if (!items.count) return 0;
  [text appendFormat:@"%@ (%lu):\n", title, (unsigned long)items.count];
  NSUInteger shown = 0;
  for (id item in items) {
    if (shown == 100) {
      [text appendFormat:@"   … y %lu más (lista completa en el registro)\n", (unsigned long)(items.count - shown)];
      break;
    }
    [text appendFormat:@"   %@\n", item];
    shown++;
  }
  [text appendString:@"\n"];
  return items.count;
}

- (NSString *)describePlan:(NSDictionary *)plan resync:(BOOL)resync {
  NSMutableString *text = [NSMutableString string];
  id mac = plan[@"mac"];
  id drive = plan[@"drive"];
  NSArray *conflicts = [self planList:plan key:@"conflicts"];
  NSUInteger total = 0;
  if (resync) {
    [text appendString:@"Primera sincronización: se juntan los dos lados sin borrar nada. Si un fichero es distinto "
                       @"en los dos, gana el más reciente y el otro se guarda en versiones.\n\n"];
    total += [self appendSection:@"Del Mac a Google Drive" items:[self planList:mac key:@"new"] to:text];
    total += [self appendSection:@"De Google Drive al Mac" items:[self planList:drive key:@"new"] to:text];
  } else {
    total += [self appendSection:@"Borrados en el Mac: su copia de Drive irá a versiones"
                           items:[self planList:mac key:@"deleted"]
                              to:text];
    total += [self appendSection:@"Borrados en Drive: su copia del Mac irá a versiones"
                           items:[self planList:drive key:@"deleted"]
                              to:text];
    total += [self appendSection:@"Cambiados en el Mac: se subirán y la versión de Drive se guarda"
                           items:[self planList:mac key:@"changed"]
                              to:text];
    total += [self appendSection:@"Cambiados en Drive: se bajarán y la versión del Mac se guarda"
                           items:[self planList:drive key:@"changed"]
                              to:text];
    total += [self appendSection:@"Nuevos en el Mac: se subirán" items:[self planList:mac key:@"new"] to:text];
    total += [self appendSection:@"Nuevos en Drive: se bajarán" items:[self planList:drive key:@"new"] to:text];
    total += [self appendSection:@"Cambiados en los dos lados: se conservarán las dos copias"
                           items:conflicts
                              to:text];
  }
  if (!total) [text appendString:@"No hay nada que copiar ni borrar."];
  return text;
}

- (void)showPlan:(NSDictionary *)plan folder:(NSString *)folder resync:(BOOL)resync failed:(BOOL)failed {
  [NSApp activateIgnoringOtherApps:YES];
  NSAlert *alert = [[NSAlert alloc] init];
  NSString *name = folder.lastPathComponent;
  if (!plan) {
    alert.messageText = failed ? @"La simulación ha fallado" : @"Simulación terminada";
    alert.informativeText = @"No se ha copiado ni borrado nada. Los detalles están en el registro.";
    [alert addButtonWithTitle:@"Ver registro"];
    [alert addButtonWithTitle:@"Cerrar"];
    if ([alert runModal] == NSAlertFirstButtonReturn) [self openLog:nil];
    return;
  }
  if (resync) {
    alert.messageText = [NSString stringWithFormat:@"Qué haría la primera sincronización de «%@»", name];
    alert.informativeText = @"Esto es una simulación: no se ha copiado ni borrado nada.";
    [alert addButtonWithTitle:@"Primera sincronización…"];
  } else {
    alert.messageText = [NSString stringWithFormat:@"«%@» está detenida por seguridad", name];
    alert.informativeText =
        @"BackupDrive no ha tocado nada porque esta sincronización borraría o cambiaría muchos ficheros "
        @"a la vez. Puede ser lo que querías (has ordenado o vaciado la carpeta) o una señal de problema "
        @"(un disco que no está, un programa que cifra tus ficheros). Revisa la lista: lo que se borre o se "
        @"sobrescriba irá a versiones.";
    [alert addButtonWithTitle:@"Continuar de todos modos"];
  }
  [alert addButtonWithTitle:@"Cancelar"];
  [alert addButtonWithTitle:@"Ver registro"];

  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 500, 260)];
  scroll.hasVerticalScroller = YES;
  scroll.borderType = NSBezelBorder;
  NSTextView *view = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 500, 260)];
  view.editable = NO;
  view.font = [NSFont systemFontOfSize:12];
  view.string = [self describePlan:plan resync:resync];
  view.verticallyResizable = YES;
  view.autoresizingMask = NSViewWidthSizable;
  view.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);
  view.textContainer.widthTracksTextView = YES;
  scroll.documentView = view;
  alert.accessoryView = scroll;

  NSModalResponse response = [alert runModal];
  if (response == NSAlertThirdButtonReturn) {
    [self openLog:nil];
  } else if (response == NSAlertFirstButtonReturn) {
    if (resync) {
      [self firstSyncFolder:folder];
    } else {
      [self runEngine:@[ @"--force", @"--profile", folder ] then:nil];
    }
  }
}

- (void)firstSync:(NSMenuItem *)item {
  [self firstSyncFolder:item.representedObject];
}

- (void)firstSyncFolder:(NSString *)folder {
  if (!folder.length) return;
  [NSApp activateIgnoringOtherApps:YES];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = [NSString stringWithFormat:@"Primera sincronización de «%@»",
                                                 folder.lastPathComponent];
  alert.informativeText =
      @"Se juntan los dos lados sin borrar nada: lo que solo está en uno se copia al otro y, si un "
      @"fichero es distinto en los dos, gana el más reciente y la otra versión se guarda. Conviene "
      @"hacer antes la simulación.";
  [alert addButtonWithTitle:@"Sincronizar"];
  [alert addButtonWithTitle:@"Cancelar"];
  if ([alert runModal] != NSAlertFirstButtonReturn) return;
  [self runEngine:@[ @"--resync", @"--profile", folder ] then:nil];
}

- (void)connect:(NSMenuItem *)item {
  [self.setup connect];
}

- (void)addFolder:(NSMenuItem *)item {
  [self.setup addFolder];
}

#pragma mark - Ajustes

- (NSString *)loginPlistPath {
  return [NSHomeDirectory()
      stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/LaunchAgents/%@.plist", kLoginLabel]];
}

- (void)toggleLogin:(NSMenuItem *)item {
  NSString *path = self.loginPlistPath;
  NSFileManager *fm = NSFileManager.defaultManager;
  if ([fm fileExistsAtPath:path]) {
    [fm removeItemAtPath:path error:nil];
    return;
  }
  NSString *app = NSBundle.mainBundle.bundlePath;
  NSDictionary *plist = @{
    @"Label" : kLoginLabel,
    @"ProgramArguments" : @[ @"/usr/bin/open", app ],
    @"RunAtLoad" : @YES,
    @"LimitLoadToSessionType" : @"Aqua",
  };
  [fm createDirectoryAtPath:path.stringByDeletingLastPathComponent
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
  if (![plist writeToURL:[NSURL fileURLWithPath:path] error:nil]) {
    [self alert:@"No se pudo activar" info:path];
  }
}

- (NSTextField *)settingsField:(NSView *)view y:(CGFloat)y label:(NSString *)label value:(id)value {
  NSTextField *text = [NSTextField labelWithString:label];
  text.frame = NSMakeRect(0, y + 3, 300, 18);
  [view addSubview:text];
  NSTextField *field = [[NSTextField alloc] initWithFrame:NSMakeRect(306, y, 70, 24)];
  field.stringValue = [value isKindOfClass:NSNumber.class] ? [value stringValue] : @"";
  field.alignment = NSTextAlignmentRight;
  [view addSubview:field];
  return field;
}

- (void)folderSettings:(NSMenuItem *)item {
  NSDictionary *p = item.representedObject;
  NSString *local = [self field:@"local" of:p];
  if (!local.length) return;
  [NSApp activateIgnoringOtherApps:YES];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = [NSString stringWithFormat:@"Ajustes de «%@»", local.lastPathComponent];
  alert.informativeText =
      @"Versiones: cuántos días se guarda lo borrado o sobrescrito (0 = no caducan nunca). Freno: si en una "
      @"sincronización cambia el contenido de más de ese porcentaje de ficheros y de más de ese número, BackupDrive "
      @"se detiene sin tocar nada (protege de un programa que cifre tus ficheros).";
  NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 380, 96)];
  NSTextField *days = [self settingsField:view y:66 label:@"Guardar versiones (días):" value:p[@"days"]];
  NSTextField *pct = [self settingsField:view y:34 label:@"Freno: porcentaje de ficheros cambiados:" value:p[@"pct"]];
  NSTextField *count = [self settingsField:view y:2 label:@"Freno: y al menos este número de ficheros:" value:p[@"count"]];
  days.nextKeyView = pct;
  pct.nextKeyView = count;
  alert.accessoryView = view;
  [alert addButtonWithTitle:@"Guardar"];
  [alert addButtonWithTitle:@"Cancelar"];
  [alert layout];
  alert.window.initialFirstResponder = days;
  if ([alert runModal] != NSAlertFirstButtonReturn) return;

  NSCharacterSet *notDigits = NSCharacterSet.decimalDigitCharacterSet.invertedSet;
  NSArray<NSTextField *> *fields = @[ days, pct, count ];
  for (NSTextField *f in fields) {
    NSString *v = [f.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (!v.length || [v rangeOfCharacterFromSet:notDigits].location != NSNotFound) {
      [self alert:@"Solo números enteros" info:@"Escribe un número en cada casilla (0 o más)."];
      return;
    }
    f.stringValue = v;
  }
  __weak AppDelegate *weakSelf = self;
  [BDRunner run:BDRunner.ctlScript
           args:@[
             @"profile", @"set", local, @"--days", days.stringValue, @"--pct", pct.stringValue, @"--count",
             count.stringValue
           ]
            env:nil
           done:^(int status, NSString *out, NSString *err) {
             if (status != 0) [weakSelf alert:@"No se pudieron guardar los ajustes" info:err];
             [weakSelf refreshProfiles];
           }];
}

- (void)showVersions:(NSMenuItem *)item {
  NSDictionary *p = item.representedObject;
  NSString *local = [self field:@"local" of:p];
  if (!local.length) return;
  if (!self.versionWindows) self.versionWindows = [NSMutableDictionary dictionary];
  BDVersionsWindow *window = self.versionWindows[local];
  if (!window) {
    __weak AppDelegate *weakSelf = self;
    window = [[BDVersionsWindow alloc] initWithFolder:local
                                          versionsMac:[self field:@"versions_mac" of:p]
                                              changed:^{
                                                [weakSelf refreshProfiles];
                                              }];
    self.versionWindows[local] = window;
  }
  [NSApp activateIgnoringOtherApps:YES];
  [window showWindow:nil];
  [window reload];
}

- (void)resolveConflicts:(NSMenuItem *)item {
  [self.setup resolveConflictsIn:item.representedObject];
}

- (void)removeFolder:(NSMenuItem *)item {
  [self.setup removeFolder:item.representedObject];
}

- (void)openLog:(NSMenuItem *)item {
  NSString *log = self.logPath;
  if (![NSFileManager.defaultManager fileExistsAtPath:log]) {
    [self alert:@"Todavía no hay registro" info:log];
    return;
  }
  [NSWorkspace.sharedWorkspace openFile:log withApplication:@"Console"];
}

- (void)openConfigFolder:(NSMenuItem *)item {
  [NSFileManager.defaultManager createDirectoryAtPath:self.appSupportDir
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:nil];
  [NSWorkspace.sharedWorkspace openFile:self.appSupportDir];
}

- (void)openFolder:(NSMenuItem *)item {
  [NSWorkspace.sharedWorkspace openFile:item.representedObject];
}

- (void)about:(NSMenuItem *)item {
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp orderFrontStandardAboutPanel:nil];
}

- (void)alert:(NSString *)message info:(NSString *)info {
  [NSApp activateIgnoringOtherApps:YES];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = message;
  alert.informativeText = info ?: @"";
  [alert runModal];
}

#pragma mark - Menú

- (NSMenuItem *)addItem:(NSString *)title action:(SEL)action to:(NSMenu *)menu {
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
  item.target = self;
  item.enabled = action != NULL;
  [menu addItem:item];
  return item;
}

- (NSMenuItem *)itemForProfile:(NSDictionary *)p {
  NSString *result = [self field:@"result" of:p];
  NSString *local = [self field:@"local" of:p];
  NSString *remote = [self field:@"remote" of:p];
  NSDictionary *labels = @{
    @"ok" : @"✓",
    @"error" : @"✗",
    @"skipped" : @"✗",
    @"needs-resync" : @"⚠",
    @"blocked" : @"⚠",
    @"never" : @"○",
  };
  NSString *mark = labels[result] ?: @"?";
  NSMenuItem *item = [[NSMenuItem alloc]
      initWithTitle:[NSString stringWithFormat:@"%@ %@ ↔ %@", mark, local.lastPathComponent,
                                               remote]
             action:NULL
      keyEquivalent:@""];
  item.indentationLevel = 1;

  NSMenu *sub = [[NSMenu alloc] initWithTitle:local];
  sub.autoenablesItems = NO;
  NSString *detail = @"Sincronizado";
  if ([result isEqualToString:@"error"]) {
    id code = p[@"exit"];
    detail = [NSString stringWithFormat:@"Error en la última sincronización (código %@)",
                                        [code isKindOfClass:NSNumber.class] ? code : @"?"];
  } else if ([result isEqualToString:@"skipped"]) {
    detail = @"Omitido: no existe la carpeta local o la línea está incompleta";
  } else if ([result isEqualToString:@"blocked"]) {
    detail = @"Detenido por seguridad: borraría o cambiaría muchos ficheros a la vez (no se ha tocado nada)";
  } else if ([result isEqualToString:@"needs-resync"]) {
    detail = @"Falta la primera sincronización";
  } else if ([result isEqualToString:@"never"]) {
    detail = @"Todavía no se ha sincronizado";
  }
  [self addItem:detail action:NULL to:sub];
  NSDate *finished = [self dateFromISO:[self field:@"finished" of:p]];
  if (finished) {
    [self addItem:[NSString stringWithFormat:@"Última vez: %@", [self describeDate:finished]]
           action:NULL
               to:sub];
  }
  [sub addItem:NSMenuItem.separatorItem];
  NSMenuItem *open = [self addItem:@"Abrir la carpeta local" action:@selector(openFolder:) to:sub];
  open.representedObject = local;
  open.enabled = [NSFileManager.defaultManager fileExistsAtPath:local];
  NSMenuItem *versions = [self addItem:@"Versiones…" action:@selector(showVersions:) to:sub];
  versions.representedObject = p;
  NSMenuItem *settings = [self addItem:@"Ajustes de esta carpeta…" action:@selector(folderSettings:) to:sub];
  settings.representedObject = p;
  settings.enabled = !self.isRunning && !self.setup.busy && p[@"days"] != nil;
  if ([result isEqualToString:@"needs-resync"] || [result isEqualToString:@"never"]) {
    NSMenuItem *sim = [self addItem:@"Simular la primera sincronización"
                             action:@selector(simulateFirstSync:)
                                 to:sub];
    sim.representedObject = local;
    sim.enabled = !self.isRunning;
    NSMenuItem *first = [self addItem:@"Primera sincronización…"
                               action:@selector(firstSync:)
                                   to:sub];
    first.representedObject = local;
    first.enabled = !self.isRunning && open.enabled;
  }
  id conflicts = p[@"conflicts"];
  if ([conflicts isKindOfClass:NSNumber.class] && [conflicts integerValue] > 0) {
    NSMenuItem *resolve = [self
        addItem:[NSString stringWithFormat:@"Resolver conflictos (%ld)…", (long)[conflicts integerValue] / 2 ?: 1]
         action:@selector(resolveConflicts:)
             to:sub];
    resolve.representedObject = local;
    resolve.enabled = !self.isRunning && !self.setup.busy;
  }
  if ([result isEqualToString:@"blocked"]) {
    NSMenuItem *review = [self addItem:@"Ver qué cambia…" action:@selector(reviewBlocked:) to:sub];
    review.representedObject = local;
    review.enabled = !self.isRunning;
  }
  if ([result isEqualToString:@"error"] || [result isEqualToString:@"skipped"] ||
      [result isEqualToString:@"blocked"]) {
    [self addItem:@"Ver registro" action:@selector(openLog:) to:sub];
  }
  [sub addItem:NSMenuItem.separatorItem];
  NSMenuItem *remove = [self addItem:@"Dejar de sincronizar…" action:@selector(removeFolder:) to:sub];
  remove.representedObject = local;
  remove.enabled = !self.isRunning && !self.setup.busy;
  item.submenu = sub;
  item.toolTip = local;
  return item;
}

// Se reconstruye cada vez que se abre: así siempre muestra el estado actual.
- (void)menuNeedsUpdate:(NSMenu *)menu {
  [self reloadStatusForce:YES];
  [menu removeAllItems];

  [self addItem:self.summaryLine action:NULL to:menu];
  BOOL hasAccount = [self.setup hasAccountIn:self.appSupportDir];
  if (!hasAccount) {
    NSMenuItem *connect = [self addItem:@"Conectar con Google Drive…" action:@selector(connect:) to:menu];
    connect.enabled = !self.setup.busy;
  }

  NSArray *profiles = self.menuProfiles;
  if ([profiles isKindOfClass:NSArray.class] && profiles.count) {
    for (NSDictionary *p in profiles) {
      if (![p isKindOfClass:NSDictionary.class]) continue;
      [menu addItem:[self itemForProfile:p]];
    }
  }

  if (hasAccount) {
    NSMenuItem *add = [self addItem:@"Añadir carpeta…" action:@selector(addFolder:) to:menu];
    add.enabled = !self.setup.busy;
  }

  [menu addItem:NSMenuItem.separatorItem];
  NSMenuItem *sync = [self addItem:@"Sincronizar ahora" action:@selector(syncNow:) to:menu];
  sync.enabled = !self.isRunning;
  NSMenuItem *agent = [self addItem:@"Sincronizar cada hora"
                             action:@selector(toggleAgent:)
                                 to:menu];
  agent.state = self.agentLoaded ? NSControlStateValueOn : NSControlStateValueOff;

  [menu addItem:NSMenuItem.separatorItem];
  [self addItem:@"Ver registro" action:@selector(openLog:) to:menu];
  [self addItem:@"Abrir carpeta de configuración" action:@selector(openConfigFolder:) to:menu];
  NSMenuItem *login = [self addItem:@"Abrir al iniciar sesión" action:@selector(toggleLogin:) to:menu];
  login.state = [NSFileManager.defaultManager fileExistsAtPath:self.loginPlistPath] ? NSControlStateValueOn
                                                                                     : NSControlStateValueOff;
  if (hasAccount) {
    NSMenuItem *reconnect = [self addItem:@"Volver a conectar con Google Drive…"
                                   action:@selector(connect:)
                                       to:menu];
    reconnect.enabled = !self.setup.busy && !self.isRunning;
  }

  [menu addItem:NSMenuItem.separatorItem];
  [self addItem:@"Acerca de BackupDrive" action:@selector(about:) to:menu];
  NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Salir de BackupDrive"
                                                action:@selector(terminate:)
                                         keyEquivalent:@"q"];
  quit.target = NSApp;
  [menu addItem:quit];
}

@end

