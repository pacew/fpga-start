module top (
	    input  OSCI,
	    output LED1,
	    output LED2,
	    output LED3,
	    output LED4,
	    output LED5,
	    input  spi_ssel,
	    input  spi_sck,
	    input  spi_mosi
	    );

   wire 	   clk;
   
   pll pll_inst(.clock_in(OSCI), .clock_out(clk));

   localparam SYS_CNTR_WIDTH = 25;
   reg [SYS_CNTR_WIDTH-1:0] syscounter;
   always @(posedge clk) syscounter <= syscounter + 1;
   assign LED5 = syscounter[SYS_CNTR_WIDTH-1];

   wire [7:0] 		    spi_cmd;
   wire 		    spi_cmd_valid;
   
   spi_slave spi
     (
      .clk(clk),
      .SCK(spi_sck),
      .SSEL(spi_ssel),
      .MOSI(spi_mosi),
      .cmd(spi_cmd),
      .cmd_valid(spi_cmd_valid)
      );
   
   assign LED1 = spi_cmd & 1;
   assign LED2 = spi_cmd & 2 ? 1 : 0;
   assign LED3 = spi_cmd & 4 ? 1 : 0;
   assign LED4 = spi_cmd & 8 ? 1 : 0;
   
endmodule		 
