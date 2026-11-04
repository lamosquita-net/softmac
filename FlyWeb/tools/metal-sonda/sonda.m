// Sonda de Metal para Macs obsoletos (FM.55, metal-mojave.md §3): qué familias, feature sets y APIs de Metal da cada GPU de cada Mac con su macOS.
// Compilar (sin entorno de Xcode concreto; vale cualquier SDK, destino 10.14):
//   clang -fobjc-arc -mmacosx-version-min=10.14 -Wno-deprecated-declarations -framework Foundation -framework Metal sonda.m -o sonda
// Ejecutar: ./sonda > sonda-<modelo>-<macOS>.txt   (solo lee; no escribe nada ni toca la red). Sin datos personales: salen nombre de GPU, versión de macOS y modelo.
// NO ESTÁ COMPILADA NI PROBADA (escrita en una sesión Linux): si no compila, es de sintaxis, no de diseño.
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include <sys/sysctl.h>

static NSString *YN(BOOL b) { return b ? @"sí" : @"no"; }
static NSString *Model(void) {
    char buf[128] = {0}; size_t n = sizeof(buf);
    sysctlbyname("hw.model", buf, &n, NULL, 0);
    return [NSString stringWithUTF8String:buf];
}
// ¿responde el dispositivo al selector? (en 10.14 los de 10.15/11 no existen y llamarlos aborta)
#define RESP(dev, sel) ([(id)(dev) respondsToSelector:@selector(sel)])

static BOOL CompilaMSL(id<MTLDevice> d, MTLLanguageVersion v) {
    NSString *src = @"#include <metal_stdlib>\nusing namespace metal;\nkernel void k(device float *a [[buffer(0)]], uint i [[thread_position_in_grid]]) { a[i] = a[i] * 2.0f; }\n";
    MTLCompileOptions *o = [MTLCompileOptions new];
    o.languageVersion = v;
    NSError *e = nil;
    id<MTLLibrary> l = [d newLibraryWithSource:src options:o error:&e];
    return l != nil;
}

int main(void) {
    @autoreleasepool {
        NSOperatingSystemVersion ov = [[NSProcessInfo processInfo] operatingSystemVersion];
        printf("modelo: %s\nmacOS: %ld.%ld.%ld\n", Model().UTF8String, (long)ov.majorVersion, (long)ov.minorVersion, (long)ov.patchVersion);
        NSArray<id<MTLDevice>> *devs = MTLCopyAllDevices();
        printf("dispositivos Metal: %lu\n", (unsigned long)devs.count);
        for (id<MTLDevice> d in devs) {
            printf("\n== %s\n", d.name.UTF8String);
            printf("baja potencia (integrada): %s | sin pantalla: %s | extraíble: %s\n", YN(d.lowPower).UTF8String, YN(d.headless).UTF8String, YN(d.removable).UTF8String);
            // ---- feature sets (10.11–10.14; obsoletos desde 13, pero son lo único que hay en 10.14)
            struct { const char *n; MTLFeatureSet f; } fs[] = {
                {"macOS_GPUFamily1_v1", MTLFeatureSet_macOS_GPUFamily1_v1},
                {"macOS_GPUFamily1_v2", MTLFeatureSet_macOS_GPUFamily1_v2},
                {"macOS_GPUFamily1_v3", MTLFeatureSet_macOS_GPUFamily1_v3},
                {"macOS_GPUFamily1_v4", MTLFeatureSet_macOS_GPUFamily1_v4},
                {"macOS_GPUFamily2_v1", MTLFeatureSet_macOS_GPUFamily2_v1},
                {"macOS_ReadWriteTextureTier2", MTLFeatureSet_macOS_ReadWriteTextureTier2},
            };
            for (size_t i = 0; i < sizeof(fs)/sizeof(fs[0]); i++)
                printf("supportsFeatureSet %-28s %s\n", fs[i].n, YN([d supportsFeatureSet:fs[i].f]).UTF8String);
            // ---- familias (10.15+)
            if (RESP(d, supportsFamily:)) {
                struct { const char *n; MTLGPUFamily f; } fm[] = {
                    {"Mac1", MTLGPUFamilyMac1}, {"Mac2", MTLGPUFamilyMac2},
                    {"Common1", MTLGPUFamilyCommon1}, {"Common2", MTLGPUFamilyCommon2}, {"Common3", MTLGPUFamilyCommon3},
                };
                for (size_t i = 0; i < sizeof(fm)/sizeof(fm[0]); i++)
                    printf("supportsFamily %-8s %s\n", fm[i].n, YN([d supportsFamily:fm[i].f]).UTF8String);
            } else printf("supportsFamily: el selector no existe (macOS < 10.15)\n");
            // ---- propiedades que ANGLE/Skia/Dawn llaman sin guarda (existen desde la versión indicada)
            printf("hasUnifiedMemory (10.15): %s\n", RESP(d, hasUnifiedMemory) ? YN(d.hasUnifiedMemory).UTF8String : "selector ausente");
            printf("supports32BitFloatFiltering (11): %s\n", RESP(d, supports32BitFloatFiltering) ? YN(d.supports32BitFloatFiltering).UTF8String : "selector ausente");
            printf("supportsBCTextureCompression (11): %s\n", RESP(d, supportsBCTextureCompression) ? YN(d.supportsBCTextureCompression).UTF8String : "selector ausente");
            printf("supportsPullModelInterpolation (11): %s\n", RESP(d, supportsPullModelInterpolation) ? YN(d.supportsPullModelInterpolation).UTF8String : "selector ausente");
            printf("supportsShaderBarycentricCoordinates (10.15): %s\n", RESP(d, supportsShaderBarycentricCoordinates) ? YN(d.supportsShaderBarycentricCoordinates).UTF8String : "selector ausente");
            // ---- capacidades de 10.13/10.14
            printf("argumentBuffersSupport: %ld (0 = tier 1, 1 = tier 2)\n", (long)d.argumentBuffersSupport);
            printf("readWriteTextureSupport: %ld (0 ninguno, 1 tier 1, 2 tier 2)\n", (long)d.readWriteTextureSupport);
            printf("maxThreadgroupMemoryLength: %lu | maxBufferLength: %lu\n", (unsigned long)d.maxThreadgroupMemoryLength, (unsigned long)d.maxBufferLength);
            for (NSUInteger c = 1; c <= 8; c <<= 1)
                printf("supportsTextureSampleCount(%lu): %s\n", (unsigned long)c, YN([d supportsTextureSampleCount:c]).UTF8String);
            // ---- ¿qué versión de MSL compila de verdad?
            printf("MSL 2.0: %s | 2.1: %s", YN(CompilaMSL(d, MTLLanguageVersion2_0)).UTF8String, YN(CompilaMSL(d, MTLLanguageVersion2_1)).UTF8String);
            if (@available(macOS 10.15, *)) printf(" | 2.2: %s", YN(CompilaMSL(d, MTLLanguageVersion2_2)).UTF8String);
            if (@available(macOS 11.0, *)) printf(" | 2.3: %s", YN(CompilaMSL(d, MTLLanguageVersion2_3)).UTF8String);
            printf("\n");
            // ---- MTLSharedEvent (10.14) y textura con swizzle (10.15: se prueba con el selector)
            printf("newSharedEvent (10.14): %s\n", RESP(d, newSharedEvent) ? "sí" : "no");
        }
    }
    return 0;
}
