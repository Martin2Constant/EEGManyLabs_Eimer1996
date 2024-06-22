# -*- coding: utf-8 -*-
"""
Python 3.10.9

@author: Martin Constant (martin.constant@unige.ch)
"""

import pingouin as pg
import numpy as np  # version 1.24.2
from scipy import special, stats, integrate
import pandas as pd

Fs = np.array([17.48, 57.10, 37.49])
N = 10
df = N-1
Jv = np.exp(special.loggamma(df / 2) -
            (np.log(np.sqrt(df / 2)) + special.loggamma((df - 1) / 2)))

ts = np.sqrt(Fs)
dz = ts / np.sqrt(N)
dz_var = (1/N) * (df / (df-2)) * (1 + N * dz**2) - (dz**2) / (Jv**2);
gz = dz * Jv
gz_var = dz_var * Jv
d = {"ES_colors": gz[0], "SE_colors": gz_var[0], 
     "ES_letters": gz[1], "SE_letters": gz_var[1],
     "ES_interaction": gz[2], "SE_interaction": gz_var[2]}
data = pd.DataFrame(data=d, index=[1])

dz = dz[0]
dz /= 2

req_N = pg.power_ttest(d=dz,
                   n=None,
                   power=.90,
                   alpha=.02,
                   contrast="paired",
                   alternative="greater",
                   )
print(f"Required N = {round(req_N)}")  # 27.639796831824828