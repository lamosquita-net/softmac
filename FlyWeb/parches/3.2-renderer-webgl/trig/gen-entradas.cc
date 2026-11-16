#include <cstdio>
#include <cstdint>
#include <cstring>
#include <random>
#include <cmath>
int main(){ std::mt19937_64 rng(99); FILE* f=fopen("inputs.bin","wb");
  for(long i=0;i<20000000;i++){ uint64_t u=rng(); double x; memcpy(&x,&u,8); if(std::isfinite(x)) fwrite(&x,8,1,f);}
  double R[]={1e-3,0.1,1,10,100,1e4,65536,1e6,1e9}; for(double r:R){ std::uniform_real_distribution<double> d(-r,r); for(long i=0;i<10000000;i++){ double x=d(rng); fwrite(&x,8,1,f);} } fclose(f); }
