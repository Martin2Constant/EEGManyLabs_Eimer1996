# -*- coding: utf-8 -*-
"""
Python 3.10.9

@author: Martin Constant (martin.constant@uni-bremen.de)
"""

import pingouin as pg  # version 0.5.3
import numpy as np  # version 1.24.2

F = 17.48
N = 10
t = np.sqrt(F)
dz = t / np.sqrt(N)
dz = dz/2

req_N = pg.power_ttest(d=dz,
                   n=None,
                   power=.90,
                   alpha=.02,
                   contrast="paired",
                   alternative="greater",
                   )
print(f"Required N = {round(req_N)}")  # 27.639796831824828