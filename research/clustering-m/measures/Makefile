OBJECTS = meas_occ.oct

all: $(OBJECTS)

%.oct: %.cc
	mkoctfile $<

clean:
	rm -f $(OBJECTS)
