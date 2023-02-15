# -*- coding: utf-8 -*-
"""
Python 3.10.9

@author: Martin Constant (martin.constant@uni-bremen.de)
"""

import mne  # version 1.3.0
import pandas as pd  # version 1.5.1
import numpy as np  # version 1.23.5
import matplotlib.pyplot as plt  # version 3.7.0
import scipy.interpolate as interpolate  # version 1.10.0

forms = pd.read_csv("./Figure3_PanelB.csv")
colors = pd.read_csv("./Figure3_PanelD.csv")
colors["Difference"] = colors["Contralateral"]-colors["Ipsilateral"]
forms["Difference"] = forms["Contralateral"]-forms["Ipsilateral"]

times = np.arange(-100, 600+1, 1)
srate = 1000.0

f_colors_contra = interpolate.CubicSpline(colors["x"], colors["Contralateral"], extrapolate=True)
f_colors_ipsi = interpolate.CubicSpline(colors["x"], colors["Ipsilateral"], extrapolate=True)
y_colors_contra = np.expand_dims(f_colors_contra(times), 0)
y_colors_ipsi = np.expand_dims(f_colors_ipsi(times), 0)

f_forms_contra = interpolate.CubicSpline(forms["x"], forms["Contralateral"], extrapolate=True)
f_forms_ipsi = interpolate.CubicSpline(forms["x"], forms["Ipsilateral"], extrapolate=True)
y_forms_contra = np.expand_dims(f_forms_contra(times), 0)
y_forms_ipsi = np.expand_dims(f_forms_ipsi(times), 0)


filtered_colors_contra = mne.filter.filter_data(y_colors_contra, srate, None, 30, method="fir")
filtered_colors_ipsi = mne.filter.filter_data(y_colors_ipsi, srate, None, 30, method="fir")
filtered_forms_contra = mne.filter.filter_data(y_forms_contra, srate, None, 30, method="fir")
filtered_forms_ipsi = mne.filter.filter_data(y_forms_ipsi, srate, None, 30, method="fir")



mne_colors_contra = mne.EvokedArray(filtered_colors_contra/1e6,
                             mne.create_info(["PO7/PO8"], srate, ch_types='eeg'),
                             tmin=-0.1,
                             baseline=(-0.1, 0),
                             comment="Colors Contra",
                             )
mne_colors_ipsi = mne.EvokedArray(filtered_colors_ipsi/1e6,
                             mne.create_info(["PO7/PO8"], srate, ch_types='eeg'),
                             tmin=-0.1,
                             baseline=(-0.1, 0),
                             comment="Colors Ipsi",
                             )

mne_forms_contra = mne.EvokedArray(filtered_forms_contra/1e6,
                             mne.create_info(["PO7/PO8"], srate, ch_types='eeg'),
                             tmin=-0.1,
                             baseline=(-0.1, 0),
                             comment="Forms Contra",
                             )

mne_forms_ipsi = mne.EvokedArray(filtered_forms_ipsi/1e6,
                             mne.create_info(["PO7/PO8"], srate, ch_types='eeg'),
                             tmin=-0.1,
                             baseline=(-0.1, 0),
                             comment="Forms Ipsi",
                             )

mne_forms_diff = mne.combine_evoked([mne_forms_contra, mne_forms_ipsi], [1, -1])
mne_colors_diff = mne.combine_evoked([mne_colors_contra, mne_colors_ipsi], [1, -1])




fig1 = mne.viz.plot_compare_evokeds(evokeds=[mne_colors_contra,
                                      mne_colors_ipsi,
                                      mne_forms_contra,
                                      mne_forms_ipsi,],
                             ylim={"eeg":[-9, 9]},
                             styles={"Colors Contra": {"linestyle": "-", "color": "C1"},
                                     "Colors Ipsi": {"linestyle": "--", "color": "C1"},
                                     "Forms Contra": {"linestyle": "-", "color": "C2"},
                                     "Forms Ipsi": {"linestyle": "--", "color": "C2"},                               
                                     },
                             truncate_xaxis="auto",
                             invert_y = False,
                             show_sensors=False,
                             time_unit="ms",
                             legend="lower right",
                             show=False,
                             )

fig1[0].get_axes()[0].axvspan(220, 300, ymin=0.2, ymax=0.65, color="gray", alpha=0.5)
plt.savefig("Contra_Ipsi waves.svg")
plt.savefig("Contra_Ipsi waves.png", dpi=300)
plt.show()

fig2 = mne.viz.plot_compare_evokeds([mne_colors_diff, mne_forms_diff],
                             ylim={"eeg":[-3.6, 3.6]},
                             styles={"Colors Contra − Colors Ipsi": {"linestyle": "-", "color": "C1"},
                                     "Forms Contra − Forms Ipsi": {"linestyle": "-", "color": "C2"},
                                     },
                             truncate_xaxis="auto",
                             invert_y=False,
                             show_sensors=False,
                             time_unit="ms",                             
                             legend="upper right",
                             show=False,
                             )

fig2[0].get_axes()[0].axvspan(220, 300, ymin=0, ymax=0.5, color="gray", alpha=0.5)
plt.savefig("Difference waves.svg")
plt.savefig("Difference waves.png", dpi=300)
plt.show()
