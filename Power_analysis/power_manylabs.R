library(pwr) # version 1.3.0

F = 17.48
N = 10
t = sqrt(F)
dz = t / sqrt(N)
dz = dz/2

req_N = pwr::pwr.t.test(n=NULL,
                        power=.90,
                        sig.level=.02,
                        type="paired",
                        alternative="greater",
                        d=dz)

round(req_N$n) # 27.6398