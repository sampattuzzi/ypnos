# coding: utf-8
from numpy import vstack
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt

def plot_csv(file, label, fmt):
    r = mlab.csv2rec(file,names=["x","y","ylo","yhi"])
    plt.errorbar(r["x"],r["y"],
                 yerr=vstack((r["y"]-r["ylo"], r["yhi"]-r["y"])),
                 label=label,
                 fmt=fmt)
#    plt.plot(r["x"],r["y"],label=label)

def plot(fun, cpu, gpu, f, fmts):
    plot_csv(cpu, fun + " CPU", fmts[0])
    plot_csv(gpu, fun + " GPU", fmts[1])
    plt.legend(loc=2)
    plt.xlabel("Grid size (width in elements)")
    plt.ylabel("Run time (seconds)")
    plt.title("Performance of the CPU vs GPU for over grid size.")

f = plt.figure(1)
plot("Average", "avg_cpu_100.csv", "avg_gpu_100.csv", f, ["r-","g-"])
plot("Life", "life_cpu_100.csv", "life_gpu_100.csv", f, ["r:","g:"])
plot_csv("id_gpu_100.csv", "Copy on/off time","k-")
plt.show()
