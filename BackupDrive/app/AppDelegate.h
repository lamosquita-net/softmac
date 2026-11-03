// BackupDrive: delegado de la app de barra de menús (estado, menú, motor).
// Licencia: MIT (ver ../LICENSE).

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
// Simula la primera sincronización de una carpeta y enseña el resultado (también desde el asistente).
- (void)simulateFolder:(NSString *)folder;
@end
