// BackupDrive: ventana de actividad de una carpeta (H8). Una fila por pasada (hora, resultado, ficheros subidos y
// bajados) y, debajo, lo que se borró o se sobrescribió en esa pasada, con el lado y la copia que quedó en versiones
// (backupdrive-ctl.sh activity). «Restaurar…» usa versions restore: lo que hubiera en esa ruta va antes a versiones.
// Licencia: MIT (ver ../LICENSE).

#import <Cocoa/Cocoa.h>

@interface BDActivityWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
// changed: tras restaurar.
- (instancetype)initWithFolder:(NSString *)folder changed:(void (^)(void))changed;
- (void)reload;
@end
