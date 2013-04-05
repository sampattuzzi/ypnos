# coding: utf-8
from numpy import vstack
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

def get_rec(file):
    return mlab.csv2rec(file,names=["x","y","ylo","yhi"])

def errors(r):
    return vstack((r["y"] - r["ylo"], r["yhi"] - r["y"]))

def plot_csv(file, label, fmt="k-"):
    r = get_rec(file)
    plt.errorbar(r["x"],r["y"],
                 yerr=errors(r),
                 label=label,
                 fmt=fmt)
#    plt.plot(r["x"],r["y"],label=label)

def plot_diff(file1, file2, label, fmt="k-"):
    r1 = get_rec(file1)
    r2 = get_rec(file2)
    newy = r2["y"]-r1["y"]
    erry = errors(r1) + errors(r2)
    plt.errorbar(r2["x"], newy,
                 yerr=erry,
                 label=label,
                 fmt=fmt)

def plot_setup(title):
    plt.legend(loc=2)
    plt.xlabel("Grid size (width in elements)")
    plt.ylabel("Run time (seconds)")
    plt.title(title)

def plot(fun, cpu, gpu, fmts):
    plot_csv(cpu, fun + " CPU", fmts[0])
    plot_csv(gpu, fun + " GPU", fmts[1])
    plot_setup("Performance of the CPU verses GPU for over grid size.")

def plot_fit(file, fun, label="", fmt="k-"):
    r = get_rec(file)
    popt, pcov = curve_fit(fun, r["x"], r["y"])
    yopt = fun(r["x"], *popt)
    plt.errorbar(r["x"],yopt,
                 label=label,
                 fmt=fmt)

avg_label = "Average"
life_label = "Life"
id_label = "Copy on/off time"

f = plt.figure(1)
plot(avg_label, "avg_cpu_100.csv", "avg_gpu_100.csv", ["r-","g-"])
plot(life_label, "life_cpu_100.csv", "life_gpu_100.csv", ["r:","g:"])
plot_csv("id_gpu_100.csv", id_label)

f = plt.figure(2)
plot_csv("avg_gpu_1000.csv", avg_label, "g-")
plot_csv("life_gpu_1000.csv", life_label, "g:")
plot_csv("id_gpu_1000.csv", id_label, "k")
plot_setup("Performance of the GPU on a larger grid sizes range.")

f = plt.figure(3)
plot_diff("id_gpu_1000.csv","life_gpu_1000.csv", life_label, "g:")
plot_diff("id_gpu_1000.csv","avg_gpu_1000.csv", avg_label, "g-")
plot_setup("Performance of the GPU modulo the copy on/off time.")

f = plt.figure(4)

def lin(x,b,c):
    return x*b + c

plot_fit("avg_cpu_100.csv", lin)

plot_csv("avg_cpu_100.csv", avg_label, "g:")
plot_setup("Performance of the GPU modulo the copy on/off time.")

plt.show()
