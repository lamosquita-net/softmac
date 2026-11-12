#include "memo.h"
#include <chrono>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
#include <cmath>
static uint64_t bits(double d){uint64_t u; memcpy(&u,&d,8); return u;}
__attribute__((noinline)) double psin(double x){ return LIBC_NAMESPACE::shared::sin(x); }
__attribute__((noinline)) double pcos(double x){ return LIBC_NAMESPACE::shared::cos(x); }
__attribute__((noinline)) double msin(double x){ return memo::Sin(x); }
__attribute__((noinline)) double mcos(double x){ return memo::Cos(x); }
template<class F> double run(F f){ auto t0=std::chrono::steady_clock::now(); double acc=f(); auto t1=std::chrono::steady_clock::now();
  static volatile double sink; sink=acc; return std::chrono::duration<double,std::nano>(t1-t0).count(); }
int main(int argc, char** argv){
  long n = argc>1? atol(argv[1]) : 3000000;
  // 1) identity
  std::mt19937_64 rng(7); long mism=0, tested=0;
  auto chk=[&](double x){ tested++; double a=psin(x),b=msin(x),c=pcos(x),d=mcos(x); double e=mcos(x), f=msin(x);
    if(bits(a)!=bits(b)||bits(c)!=bits(d)||bits(c)!=bits(e)||bits(a)!=bits(f)){ if(mism<5) printf("MISMATCH %a\n",x); mism++; } };
  double sp[]={0.0,-0.0,1e-320,0x1p-27,0x1p-5,0x1p-4,-0x1p-4,0x1.fffffffffffffp-5,1,M_PI,65535.9,65536.0,1e22,1e300,INFINITY,-INFINITY,NAN};
  for(double x:sp) chk(x);
  for(long i=0;i<n;i++){ uint64_t u=rng(); double x; memcpy(&x,&u,8); if(std::isfinite(x)) chk(x); }
  double R[]={1e-3,0.07,0.1,1,10,100,1e4,65536,1e6,1e9,1e15};
  for(double r:R){ std::uniform_real_distribution<double> d(-r,r); for(long i=0;i<n;i++) chk(d(rng)); }
  // interleavings: sin a, sin b, cos a, cos b, cos c ... random order on a small pool
  { std::uniform_real_distribution<double> d(-100,100); double pool[3]; for(long i=0;i<n;i++){ for(auto&p:pool) p=d(rng);
      for(int j=0;j<6;j++){ double x=pool[rng()%3]; bool s=rng()&1; double a= s? msin(x):mcos(x); double b= s? psin(x):pcos(x); tested++; if(bits(a)!=bits(b)) mism++; } } }
  printf("identity: tested %ld, mismatches %ld\n", tested, mism);
  // 2) speed
  const int FISH=15000, FRAMES=100; std::uniform_real_distribution<double> u(0,1);
  std::vector<double> spd(FISH); for(auto&v:spd) v=1+u(rng)*0.2;
  long calls=(long)FISH*FRAMES*6;
  auto aq=[&](auto S, auto C){ return [&,S,C]{ double acc=0; for(int f=0;f<FRAMES;f++){ double clock=10+f/60.0;
     for(int i=0;i<FISH;i++){ double fc=(clock*0.08+i*0.52)*spd[i]; double xc=fc*1, yc=fc*0.556, zc=fc*1;
       acc+=S(xc)+S(yc)+C(zc)+S(xc-0.04)+S(yc-0.01)+C(zc-0.04);} } return acc; }; };
  auto sonly=[&](auto S){ return [&,S]{ double acc=0; for(long i=0;i<calls;i++) acc+=S(1+i*1e-3); return acc; }; };
  auto pair=[&](auto S, auto C){ return [&,S,C]{ double acc=0; for(long i=0;i<calls/2;i++){ double a=1+i*1e-3; acc+=S(a)+C(a);} return acc; }; };
  std::vector<double> A,B,C,D,E,F;
  for(int rep=0;rep<7;rep++){ A.push_back(run(aq(psin,pcos))); B.push_back(run(aq(msin,mcos)));
    C.push_back(run(sonly(psin))); D.push_back(run(sonly(msin))); E.push_back(run(pair(psin,pcos))); F.push_back(run(pair(msin,mcos))); }
  auto med=[](std::vector<double> v){ std::sort(v.begin(),v.end()); return v[v.size()/2]; };
  double a=med(A),b=med(B),c=med(C),d=med(D),e=med(E),f=med(F);
  printf("median of 7 (ns/call): aquarium %.2f -> %.2f (%+.1f%%) | sin-only %.2f -> %.2f (%+.1f%%) | sin+cos pairs %.2f -> %.2f (%+.1f%%)\n",
    a/calls,b/calls,100*(b-a)/a, c/calls,d/calls,100*(d-c)/c, e/calls,f/calls,100*(f-e)/e);
}
