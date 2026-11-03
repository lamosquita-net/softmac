// BackupDrive: conectar con Google Drive y dar de alta o quitar carpetas, sin terminal (B.6, hito H3).
// Todo pasa por backupdrive-ctl.sh; aquí solo están los diálogos.
// Licencia: MIT (ver ../LICENSE).

#import <Cocoa/Cocoa.h>

@interface BDSetup : NSObject
// changed: algo cambió (cuenta o carpetas): recargar el menú. simulate: lanzar la simulación de una carpeta.
- (instancetype)initWithChanged:(void (^)(void))changed simulate:(void (^)(NSString *folder))simulate;

@property(readonly) BOOL busy;  // hay un diálogo o una orden en marcha
// ¿Hay una cuenta «gdrive» en backupdrive.conf? (solo mira el fichero; no llama a Google)
- (BOOL)hasAccountIn:(NSString *)appSupportDir;

- (void)connect;                          // pide la clave propia y espera la autorización en el navegador
- (void)addFolder;                        // carpeta del Mac + carpeta de Drive → perfil; ofrece simular
- (void)removeFolder:(NSString *)folder;  // quita el perfil (no borra nada), con confirmación
@end
