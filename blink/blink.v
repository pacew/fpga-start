module top (input  OSCI, output LED5);

   wire 	   clk;
   
   pll system_clock(.clock_in(OSCI), .clock_out(clk));

   localparam SYSTICK_WIDTH = 25;
   reg [SYSTICK_WIDTH-1:0] systick;

   always @(posedge clk) systick <= systick + 1;

   assign LED5 = systick[systick-1];

endmodule		 
