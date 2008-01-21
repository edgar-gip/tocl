OBJECTS = comb_mem.oct comb_mem_expectation.oct comb_mem_maximization.oct\
	  comb_mem_loglike.oct comb_one_unfuzzy_matrix.oct

all: $(OBJECTS)

comb_mem_expectation.oct: comb_mem.oct
	ln -sf comb_mem.oct comb_mem_expectation.oct

comb_mem_maximization.oct: comb_mem.oct
	ln -sf comb_mem.oct comb_mem_maximization.oct

comb_mem_loglike.oct: comb_mem.oct
	ln -sf comb_mem.oct comb_mem_loglike.oct

%.oct: %.cc
	mkoctfile $<

clean:
	rm -f $(OBJECTS)
