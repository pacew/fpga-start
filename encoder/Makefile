VFILES = encoder.v pll.v quadrature_decode.v

FREQ_MHZ = 100

all: out.bin sim

pll.v: Makefile mkclock.py
	python mkclock.py $(FREQ_MHZ)

out.json: $(VFILES) Makefile
	yosys -DICE_STICK -q -p "synth_ice40 -json out.json" $(VFILES)

out.asc: out.json pins.pcf
	nextpnr-ice40 --quiet --log out.log --json out.json --pcf pins.pcf --asc out.asc \
	  --freq $(FREQ_MHZ) --hx1k --package tq144 --opt-timing
	@grep -A 2 'Device utilisation' out.log
	@grep 'Max frequency' out.log

out.timings: out.asc
	icetime -p pins.pcf -P tq144 -r out.timings -d hx1k -t out.asc 

out.bin: out.asc
	icepack -s out.asc out.bin

prog: out.bin
	iceprog out.bin

sim: quadrature_decode_tb.v quadrature_decode.v
	iverilog -s test -o sim quadrature_decode_tb.v
	./sim

wave:
	gtkwave sim.vcd

clean:
	rm -f *~ out.json out.asc out.timings out.bin

