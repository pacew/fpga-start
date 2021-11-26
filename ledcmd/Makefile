MODULES_DIR=../modules

VFILES = ledcmd.v pll.v \
	$(MODULES_DIR)/spi_slave.v

FREQ_MHZ = 100

all: design.bin

pll.v: $(MODULES_DIR)/mkclock.py
	python $(MODULES_DIR)/mkclock.py $(FREQ_MHZ)

design.bin: $(VFILES) pins.pcf
	yosys -DICE_STICK -q -p "synth_ice40 -json TMP.json" $(VFILES)
	nextpnr-ice40 --quiet --opt-timing --hx1k --package tq144 \
	 --freq $(FREQ_MHZ) --log TMP.log --json TMP.json \
	 --pcf pins.pcf --asc TMP.asc 
	@egrep '(ICESTORM_LC|ICESTORM_RAM).*%' TMP.log
	@grep 'Max frequency' TMP.log
	icepack -s TMP.asc design.bin

upload: design.bin
	iceprog design.bin

clean:
	rm -f *~ TMP.*
