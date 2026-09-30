// BackupDrive: app de barra de menús para macOS 10.14+ (x86_64).
//
// No sincroniza por sí misma: muestra el estado que escribe scripts/backupdrive-sync.sh en
// ~/Library/Application Support/BackupDrive/status.json, lanza ese script a petición y activa o
// desactiva el LaunchAgent que lo ejecuta cada hora. Sin nib ni Xcode: ver build-app.sh.
//
// Licencia: MIT (ver ../LICENSE).

#import <Cocoa/Cocoa.h>

static NSString *const kAgentLabel = @"net.lamosquita.backupdrive";
static NSString *const kSyncScript = @"/usr/local/bin/backupdrive-sync.sh";
static const NSTimeInterval kPollSeconds = 2.0;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
@property(strong) NSStatusItem *statusItem;
@property(strong) NSTimer *timer;
@property(copy) NSDate *statusDate;  // mtime de status.json ya leído
@property(copy) NSDictionary *status;
@property(strong) NSTask *manualRun;
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
        [r isEqualToString:@"needs-resync"])
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
  if (![NSFileManager.defaultManager isExecutableFileAtPath:kSyncScript]) {
    [self alert:@"No encuentro el motor de BackupDrive"
           info:[NSString stringWithFormat:@"Falta %@ (ver BackupDrive/README.md).", kSyncScript]];
    return;
  }
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = kSyncScript;
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
  NSString *folder = item.representedObject;
  __weak AppDelegate *weakSelf = self;
  [self runEngine:@[ @"--resync", @"--dry-run", @"--profile", folder ]
             then:^(int status) {
               [NSApp activateIgnoringOtherApps:YES];
               NSAlert *alert = [[NSAlert alloc] init];
               alert.messageText = status == 0 ? @"Simulación terminada"
                                               : @"La simulación ha fallado";
               alert.informativeText = @"No se ha copiado ni borrado nada. En el registro "
                                       @"están los cambios que haría la primera sincronización.";
               [alert addButtonWithTitle:@"Ver registro"];
               [alert addButtonWithTitle:@"Cerrar"];
               if ([alert runModal] == NSAlertFirstButtonReturn) [weakSelf openLog:nil];
             }];
}

- (void)firstSync:(NSMenuItem *)item {
  NSString *folder = item.representedObject;
  [NSApp activateIgnoringOtherApps:YES];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = [NSString stringWithFormat:@"Primera sincronización de «%@»",
                                                 folder.lastPathComponent];
  alert.informativeText =
      @"Se juntan los dos lados: lo que solo está en uno se copia al otro y, si un fichero es "
      @"distinto en los dos, gana el más reciente (el otro se sobrescribe, sin copia). "
      @"Conviene hacer antes la simulación y revisar el registro.";
  [alert addButtonWithTitle:@"Sincronizar"];
  [alert addButtonWithTitle:@"Cancelar"];
  if ([alert runModal] != NSAlertFirstButtonReturn) return;
  [self runEngine:@[ @"--resync", @"--profile", folder ] then:nil];
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
  if ([result isEqualToString:@"error"] || [result isEqualToString:@"skipped"]) {
    [self addItem:@"Ver registro" action:@selector(openLog:) to:sub];
  }
  item.submenu = sub;
  item.toolTip = local;
  return item;
}

// Se reconstruye cada vez que se abre: así siempre muestra el estado actual.
- (void)menuNeedsUpdate:(NSMenu *)menu {
  [self reloadStatusForce:YES];
  [menu removeAllItems];

  [self addItem:self.summaryLine action:NULL to:menu];

  NSArray *profiles = self.status[@"profiles"];
  if ([profiles isKindOfClass:NSArray.class] && profiles.count) {
    for (NSDictionary *p in profiles) {
      if (![p isKindOfClass:NSDictionary.class]) continue;
      [menu addItem:[self itemForProfile:p]];
    }
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

  [menu addItem:NSMenuItem.separatorItem];
  [self addItem:@"Acerca de BackupDrive" action:@selector(about:) to:menu];
  NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Salir de BackupDrive"
                                                action:@selector(terminate:)
                                         keyEquivalent:@"q"];
  quit.target = NSApp;
  [menu addItem:quit];
}

@end

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSApplication *app = NSApplication.sharedApplication;
    AppDelegate *delegate = [[AppDelegate alloc] init];
    app.delegate = delegate;
    app.activationPolicy = NSApplicationActivationPolicyAccessory;  // sin icono en el Dock
    [app run];
  }
  return 0;
}
