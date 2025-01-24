# -*- coding: utf-8 -*-
"""
Python 3.12.7

@author: Martin Constant (martin.constant@unige.ch)
"""

import mne  # version 1.8.0
import pandas as pd  # version 2.2.2
import numpy as np  # version 1.26.4
import matplotlib.pyplot as plt  # version 3.9.2
import scipy.interpolate as interpolate  # version 1.14.1


plt.rcParams.update(
    {
        "ytick.labelsize": "large",
        "xtick.labelsize": "large",
        "axes.labelsize": "large",
        "axes.titlesize": "x-large",
        "legend.fontsize": "large",
    }
)
C_forms = (0.30, 0.30, 0.30)

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


filtered_colors_contra = mne.filter.filter_data(y_colors_contra, srate, None, 40, method="fir")
filtered_colors_ipsi = mne.filter.filter_data(y_colors_ipsi, srate, None, 40, method="fir")
filtered_forms_contra = mne.filter.filter_data(y_forms_contra, srate, None, 40, method="fir")
filtered_forms_ipsi = mne.filter.filter_data(y_forms_ipsi, srate, None, 40, method="fir")


filtered_colors_contra = mne.filter.resample(filtered_colors_contra, down=5)
filtered_colors_ipsi = mne.filter.resample(filtered_colors_ipsi, down=5)
filtered_forms_contra = mne.filter.resample(filtered_forms_contra, down=5)
filtered_forms_ipsi = mne.filter.resample(filtered_forms_ipsi, down=5)
srate = 200

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

peak_colors = mne_colors_diff.data.min()*1e6
time_colors = mne_colors_diff.times[mne_colors_diff.data.argmin()]*1000
peak_forms = mne_forms_diff.data.min()*1e6
time_forms = mne_forms_diff.times[mne_forms_diff.data.argmin()]*1000

fig1, ax = plt.subplots()
mne.viz.plot_compare_evokeds(evokeds=[mne_colors_contra,
                                      mne_colors_ipsi,
                                      mne_forms_contra,
                                      mne_forms_ipsi,],
                             ylim={"eeg":[-9, 9]},
                             styles={"Colors Contra": {"linestyle": "-", "color": "C1"},
                                     "Colors Ipsi": {"linestyle": "--", "color": "C1"},
                                     "Forms Contra": {"linestyle": "-", "color": C_forms},
                                     "Forms Ipsi": {"linestyle": "--", "color": C_forms},                               
                                     },
                             truncate_xaxis="auto",
                             invert_y = False,
                             show_sensors=False,
                             time_unit="ms",
                             legend="lower right",
                             show=False,
                             axes=ax,
                             )

fig1.get_axes()[0].axvspan(220, 300, ymin=0.2, ymax=0.65, color="gray", alpha=0.5)
plt.title("Contra and Ipsi Waves")
plt.text(0.125, 1.03, 'OL/OR', horizontalalignment='right', verticalalignment='top', transform=plt.gca().transAxes)
plt.savefig("Contra_Ipsi waves.svg")
plt.savefig("Contra_Ipsi waves.png", dpi=300)
plt.show()

fig2, ax = plt.subplots(figsize=(12,4))
mne.viz.plot_compare_evokeds([mne_colors_diff, mne_forms_diff],
                             ylim={"eeg":[-3.6, 1.6]},
                             styles={"Colors Contra − Colors Ipsi": {"linestyle": "-", "color": "C1", "linewidth": 1.8},
                                     "Forms Contra − Forms Ipsi": {"linestyle": "-", "color": C_forms, "linewidth": 1.8},
                                     },
                             truncate_xaxis="auto",
                             invert_y=False,
                             show_sensors=False,
                             time_unit="ms",                             
                             legend="lower right",
                             show=False,
                             axes=ax,
                             )

plt.text(0.125, 1.03, 'OL/OR', horizontalalignment='right', verticalalignment='top', transform=plt.gca().transAxes)
fig2.get_axes()[0].axvspan(220, 300, ymin=0, ymax=3.6/(3.6+1.6), color="gray", alpha=0.5)
plt.title("Contra−Ipsi Difference Waves")
plt.legend(["Colors", "Forms"], loc="lower right")
plt.savefig("Difference waves.svg")
plt.savefig("Difference waves.png", dpi=300)
plt.show()



fig1, ax = plt.subplots(figsize=(6,4))
mne.viz.plot_compare_evokeds(evokeds=[mne_colors_contra,
                                      mne_colors_ipsi,],
                             ylim={"eeg":[-9, 7]},
                             styles={"Colors Contra": {"linestyle": "-", "color": "#0000FF"},
                                     "Colors Ipsi": {"linestyle": "-", "color": "#FA8775"},                               
                                     },
                             truncate_xaxis="auto",
                             invert_y = False,
                             show_sensors=False,
                             time_unit="ms",
                             legend="lower right",
                             show=False,
                             axes=ax,
                             )

fig1.get_axes()[0].axvspan(220, 300, ymin=0.2, ymax=0.65, color="gray", alpha=0.5)
plt.title("Colors")
plt.text(0.125, 1.03, 'OL/OR', horizontalalignment='right', verticalalignment='top', transform=plt.gca().transAxes)
plt.legend(["Contra", "Ipsi"], loc="lower right")
plt.savefig("Color waves.svg")
plt.savefig("Color waves.png", dpi=300)
plt.show()

fig1, ax = plt.subplots(figsize=(6,4))
mne.viz.plot_compare_evokeds(evokeds=[mne_forms_contra,
                                      mne_forms_ipsi,],
                             ylim={"eeg":[-9, 7]},
                             styles={"Forms Contra": {"linestyle": "-", "color": "#0000FF"},
                                     "Forms Ipsi": {"linestyle": "-", "color": "#FA8775"},                             
                                     },
                             truncate_xaxis="auto",
                             invert_y = False,
                             show_sensors=False,
                             time_unit="ms",
                             legend="lower right",
                             show=False,
                             axes=ax,
                             )

fig1.get_axes()[0].axvspan(220, 300, ymin=0.2, ymax=0.65, color="gray", alpha=0.5)
plt.title("Forms")
plt.text(0.125, 1.03, 'OL/OR', horizontalalignment='right', verticalalignment='top', transform=plt.gca().transAxes)
plt.legend(["Contra", "Ipsi"], loc="lower right")
plt.savefig("Forms waves.svg")
plt.savefig("Forms waves.png", dpi=300)
plt.show()

"""
fig3 = mne.viz.plot_compare_evokeds(evokeds=[mne_colors_contra,
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
                             invert_y = True,
                             show_sensors=False,
                             time_unit="ms",
                             legend="upper right",
                             show=False,
                             )

fig3[0].get_axes()[0].axvspan(220, 300, ymin=0.3, ymax=0.75, color="gray", alpha=0.5)
#plt.savefig("Contra_Ipsi waves inverted Y.svg")
plt.savefig("Contra_Ipsi waves inverted Y.png", dpi=300)
plt.show()

fig4 = mne.viz.plot_compare_evokeds([mne_colors_diff, mne_forms_diff],
                             ylim={"eeg":[-3.6, 3.6]},
                             styles={"Colors Contra − Colors Ipsi": {"linestyle": "-", "color": "C1"},
                                     "Forms Contra − Forms Ipsi": {"linestyle": "-", "color": "C2"},
                                     },
                             truncate_xaxis="auto",
                             invert_y=True,
                             show_sensors=False,
                             time_unit="ms",                             
                             legend="lower right",
                             show=False,
                             )

fig4[0].get_axes()[0].axvspan(220, 300, ymin=0.5, ymax=1, color="gray", alpha=0.5)
#plt.savefig("Difference waves inverted Y.svg")
plt.savefig("Difference waves inverted Y.png", dpi=300)
plt.show()
"""