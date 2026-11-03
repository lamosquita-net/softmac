// BackupDrive: ventana de versiones de una carpeta (H6). Lista las versiones de los dos lados
// (backupdrive-ctl.sh versions list), busca por nombre y restaura (versions restore): lo que hubiera en esa ruta
// va antes a versiones, así que restaurar tampoco pierde nada.
// Licencia: MIT (ver ../LICENSE).

#import <Cocoa/Cocoa.h>

@interface BDVersionsWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate>
// versionsMac: carpeta de versiones del Mac (para «Mostrar en el Finder»). changed: tras restaurar.
- (instancetype)initWithFolder:(NSString *)folder
                   versionsMac:(NSString *)versionsMac
                       changed:(void (^)(void))changed;
- (void)reload;
@end
