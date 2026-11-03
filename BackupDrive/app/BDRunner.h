// BackupDrive: lanza los guiones del motor (backupdrive-sync.sh y backupdrive-ctl.sh) y recoge su salida.
// La app no hace nada más que esto y leer ficheros (decisión de COORDINACIÓN-24, 03-11).
// Licencia: MIT (ver ../LICENSE).

#import <Foundation/Foundation.h>

// status: código de salida (130 = cancelado; 127 = no se pudo lanzar). out/err: salida en UTF-8.
typedef void (^BDRunDone)(int status, NSString *out, NSString *err);

@interface BDRunner : NSObject
@property(class, readonly) NSString *syncScript;  // /usr/local/bin/backupdrive-sync.sh
@property(class, readonly) NSString *ctlScript;   // /usr/local/bin/backupdrive-ctl.sh

// Lanza path con args (y variables de entorno extra) en segundo plano; done llega en el hilo principal.
// Devuelve la tarea (para cancelarla con -terminate) o nil si no se pudo lanzar (done ya se ha llamado).
+ (NSTask *)run:(NSString *)path
           args:(NSArray<NSString *> *)args
            env:(NSDictionary<NSString *, NSString *> *)env
           done:(BDRunDone)done;
@end
