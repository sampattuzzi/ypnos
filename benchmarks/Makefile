benchmarks : comp_life comp_avg id
benchmarks : comp_avg comp_life id sum

sources = Benchmark
bench = ./Benchmark
funcs = avg life id sum
archs = gpu cpu
nums = 10 100

Benchmark : Benchmark.hs
	ghc -i"../src" -main-is Benchmark Benchmark.hs

clean :
	rm -f *.hi
	rm -f *.o

clean-all : clean
	rm -i *.csv

comp_life : comp_life_100 comp_life_1000
comp_avg : comp_avg_100 comp_avg_1000
id : id_100 id_1000
sum : sum_100

comp_life_100 : life_cpu_100.csv life_gpu_100.csv
comp_life_1000 : life_gpu_1000.csv #life_cpu_1000.csv

comp_avg_100 : avg_cpu_100.csv avg_gpu_100.csv
comp_avg_1000 : avg_gpu_1000.csv #avg_cpu_1000.csv

id_100: id_gpu_100.csv

id_1000: id_gpu_1000.csv

sum_100: sum_cpu_100.csv sum_gpu_100.csv

define BENCHMARK_template
$(1)_$(2)_$(4).csv : $(sources)
	$(bench) $(1) $(2) 2 $(3) $(4) $(1)_$(2)_$(4).csv
endef

$(foreach func,$(funcs),\
$(foreach arch,$(archs),\
$(foreach num,$(nums),\
$(eval $(call BENCHMARK_template,$(func),$(arch),$(num),$(num)0))\
)))
