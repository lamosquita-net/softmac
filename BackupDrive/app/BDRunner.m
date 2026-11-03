// BackupDrive: ver BDRunner.h.
// Licencia: MIT (ver ../LICENSE).

#import "BDRunner.h"

@implementation BDRunner

+ (NSString *)syncScript {
  return @"/usr/local/bin/backupdrive-sync.sh";
}

+ (NSString *)ctlScript {
  return @"/usr/local/bin/backupdrive-ctl.sh";
}

static NSString *BDString(NSData *data) {
  NSString *s = data.length ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
  return [s stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] ?: @"";
}

+ (NSTask *)run:(NSString *)path
           args:(NSArray<NSString *> *)args
            env:(NSDictionary<NSString *, NSString *> *)env
           done:(BDRunDone)done {
  if (![NSFileManager.defaultManager isExecutableFileAtPath:path]) {
    done(127, @"", [NSString stringWithFormat:@"Falta %@: vuelve a instalar BackupDrive.", path]);
    return nil;
  }
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = path;
  task.arguments = args;
  NSMutableDictionary *environment = [NSProcessInfo.processInfo.environment mutableCopy];
  if (env) [environment addEntriesFromDictionary:env];
  task.environment = environment;
  task.standardInput = NSFileHandle.fileHandleWithNullDevice;
  NSPipe *outPipe = [NSPipe pipe];
  NSPipe *errPipe = [NSPipe pipe];
  task.standardOutput = outPipe;
  task.standardError = errPipe;
  @try {
    [task launch];
  } @catch (NSException *e) {
    done(127, @"", e.reason ?: @"No se pudo lanzar el motor.");
    return nil;
  }
  // Las dos tuberías se leen a la vez: si una se llena mientras se espera a la otra, el proceso se bloquearía.
  dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
  dispatch_async(queue, ^{
    __block NSData *errData = nil;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
      errData = [errPipe.fileHandleForReading readDataToEndOfFile];
    });
    NSData *outData = [outPipe.fileHandleForReading readDataToEndOfFile];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    [task waitUntilExit];
    int status = task.terminationStatus;
    if (task.terminationReason == NSTaskTerminationReasonUncaughtSignal) status = 130;
    NSString *out = BDString(outData);
    NSString *err = BDString(errData);
    dispatch_async(dispatch_get_main_queue(), ^{
      done(status, out, err);
    });
  });
  return task;
}

@end
