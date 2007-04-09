all: 	comb_mem.oct comb_mem_expectation.oct comb_mem_maximization.oct\
	comb_mem_loglike.oct comb_one_unfuzzy_matrix.oct

comb_mem.oct: comb_mem.cc
	mkoctfile comb_mem.cc

comb_mem_expectation.oct: comb_mem.oct
	ln -sf comb_mem.oct comb_mem_expectation.oct

comb_mem_maximization.oct: comb_mem.oct
	ln -sf comb_mem.oct comb_mem_maximization.oct

comb_mem_loglike.oct: comb_mem.oct
	ln -sf comb_mem.oct comb_mem_loglike.oct

comb_one_unfuzzy_matrix.oct: comb_one_unfuzzy_matrix.cc
	mkoctfile comb_one_unfuzzy_matrix.cc

