module top (
	    input  OSCI,
	    output LED1,
	    output LED2,
	    output LED3,
	    output LED4,
	    output LED5,
	    input  spi_ssel,
	    input  spi_sck,
	    input  spi_mosi,
	    output spi_miso
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
      .MISO(spi_miso),
      .cmd(spi_cmd),
      .cmd_valid(spi_cmd_valid)
      );
   
   reg [7:0] 		    last_cmd;

   always @(posedge clk)
     if (spi_cmd_valid)
       last_cmd <= spi_cmd;

   assign LED1 = last_cmd & 1;
   assign LED2 = last_cmd & 2 ? 1 : 0;
   assign LED3 = last_cmd & 4 ? 1 : 0;
   assign LED4 = spi_cmd_valid;
   
   
endmodule		 
