#ifdef FLAGS
#define LIBC_MATH (LIBC_MATH_NO_ERRNO | LIBC_MATH_NO_EXCEPT | LIBC_MATH_ASSUME_ROUND_NEAREST_ONLY)
#endif
#include "shared/math/sin.h"
#include "shared/math/cos.h"
#include <cstdio>
#include <cstdint>
#include <cmath>
#include <chrono>
#include <vector>
#include <algorithm>
__attribute__((noinline)) double S(double x){ return LIBC_NAMESPACE::shared::sin(x); }
__attribute__((noinline)) double C(double x){ return LIBC_NAMESPACE::shared::cos(x); }
int main(int argc,char**argv){ FILE* f=fopen("inputs.bin","rb"); FILE* o=fopen(argv[1],"wb"); double x;
  while(fread(&x,8,1,f)==1){ double r[2]={S(x),C(x)}; fwrite(r,8,2,o);} fclose(o);
  double sp[]={INFINITY,-INFINITY,NAN,-NAN,0.0,-0.0,1e-310}; for(double v:sp) printf("%a->%a,%a ",v,S(v),C(v)); printf("\n");
  std::vector<double> t; for(int rep=0;rep<9;rep++){ auto t0=std::chrono::steady_clock::now(); double acc=0; for(long i=0;i<20000000;i++){ double a=(i%20000)*0.0005+i*1e-7; acc+=S(a)+C(a*0.556);} auto t1=std::chrono::steady_clock::now(); static volatile double sink; sink=acc; t.push_back(std::chrono::duration<double,std::nano>(t1-t0).count()/4e7);} std::sort(t.begin(),t.end()); printf("median ns/call %.2f\n", t[4]); }
