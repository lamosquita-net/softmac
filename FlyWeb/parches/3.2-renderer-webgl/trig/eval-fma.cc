#include "shared/math/sin.h"
#include "shared/math/cos.h"
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <vector>
int main(int argc,char**argv){ FILE* f=fopen("inputs.bin","rb"); FILE* o=fopen(argv[1],"wb"); double x;
  while(fread(&x,8,1,f)==1){ double r[2]={LIBC_NAMESPACE::shared::sin(x),LIBC_NAMESPACE::shared::cos(x)}; fwrite(r,8,2,o);} fclose(o); }
