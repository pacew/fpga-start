// based on https://www.fpga4fun.com/SPI1.html

module SPI_slave
  (
   input 	clk,
   input 	SCK,
   input 	SSEL,
   input 	MOSI,
   output reg [7:0] cmd,
   output reg 	cmd_valid
   );

   // for test bench
   initial cmd_valid = 0;

   // clk domain crossing
   reg [2:0] 	SCKr; always @(posedge clk) SCKr <= {SCKr[1:0], SCK};
   wire 	SCK_risingedge = (SCKr[2:1]==2'b01);

   reg [2:0] 	SSELr; always @(posedge clk) SSELr <= {SSELr[1:0], SSEL};
   wire 	SSEL_active = ~SSELr[1];  // SSEL is active low

   reg [1:0] 	MOSIr;  always @(posedge clk) MOSIr <= {MOSIr[0], MOSI};
   wire 	MOSI_data = MOSIr[1];


   // read in 8 bit message
   reg [2:0] 	bitcnt;
   reg 		rbuf_avail;  // high when a byte has been received
   reg [7:0] 	rbuf = 0;

   always @(posedge clk) begin
      if (~SSEL_active)
	bitcnt <= 3'b000;
      else if (SCK_risingedge) begin
	 bitcnt <= bitcnt + 3'b001;
	 // implement a shift-left register (since we receive the data MSB first)
	 rbuf <= {rbuf[6:0], MOSI_data};
      end
   end

   always @(posedge clk)
     rbuf_avail <= SSEL_active && SCK_risingedge && (bitcnt==3'b111);
   
   always @(posedge clk) begin
      if(rbuf_avail) begin
	 cmd <= rbuf;
	 cmd_valid <= 1;
      end
   end
   
endmodule
