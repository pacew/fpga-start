VFILES = encoder.v pll.v

FREQ_MHZ = 100

all: out.bin

pll.v: Makefile mkclock.py
	python mkclock.py $(FREQ_MHZ)

out.json: $(VFILES) Makefile
	yosys -DICE_STICK -q -p "synth_ice40 -relut -json out.json" $(VFILES)

out.asc: out.json pins.pcf
	nextpnr-ice40 --quiet --json out.json --pcf pins.pcf --asc out.asc \
	  --freq $(FREQ_MHZ) --hx1k --package tq144 --opt-timing

out.timings: out.asc
	icetime -p pins.pcf -P tq144 -r out.timings -d hx1k -t out.asc 

out.bin: out.asc
	icepack -s out.asc out.bin

prog: out.bin
	iceprog out.bin

clean:
	rm -f *~ out.json out.asc out.timings out.bin

