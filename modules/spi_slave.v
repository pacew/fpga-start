// based on https://www.fpga4fun.com/SPI1.html

module spi_slave
  (
   input 	    clk,
   input 	    SCK,
   input 	    SSEL,
   input 	    MOSI,
   output reg 	    MISO,
   output reg [7:0] cmd,
   output reg 	    cmd_valid,
   input [7:0] 	    response
   );

   initial cmd_valid = 0; // initialize for test bench 

   // clk domain crossing
   reg [2:0] 	SCKr; always @(posedge clk) SCKr <= (SCKr << 1) | SCK;
   wire 	SCK_risingedge = (SCKr[2:1] == 2'b01);
   wire 	SCK_fallingedge = (SCKr[2:1] == 2'b10);

   reg [2:0] 	SSELr; always @(posedge clk) SSELr <= (SSELr << 1) | SSEL;
   wire 	SSEL_active = ~SSELr[1];  // SSEL is active low

   reg [1:0] 	MOSIr;  always @(posedge clk) MOSIr <= (MOSIr << 1) | MOSI;
   wire 	MOSI_data = MOSIr[1];


   // read in 8 bit message
   reg [2:0] 	bitcnt;
   reg [7:0] 	rbuf = 0;
   reg [7:0] 	xbuf = 0;
   

   reg 		doing_cmd = 0;
   

   always @(posedge clk) begin
      cmd_valid <= 0;

      if (~SSEL_active) begin
	 bitcnt <= 0;
	 doing_cmd <= 1;
      end else if (doing_cmd) begin
	 if (SCK_risingedge) begin
	    bitcnt <= bitcnt + 1;
	    rbuf <= (rbuf << 1) | MOSI_data;

	    if (bitcnt == 7) begin
	       cmd <= (rbuf << 1) | MOSI_data;
	       cmd_valid <= 1;
	       doing_cmd <= 0;
	    end
	 end
      end else begin
	 if (SCK_risingedge) begin
	    xbuf <= xbuf << 1;
	    bitcnt <= bitcnt + 1;
	    
	 end
      end

      if (SCK_fallingedge && bitcnt == 0) begin
	 xbuf <= response;
      end

      MISO <= xbuf & 8'h80 ? 1 : 0;
   end
   

endmodule
