module top (
	    input  OSCI,
	    output LED1,
	    output LED2,
	    output LED3,
	    output LED4,
	    output LED5,
	    input  ENC_A_raw,
	    input  ENC_B_raw
	    );

   wire 	   clk;
   wire 	   locked;
   
   pll pll_inst(.clock_in(OSCI), .clock_out(clk), .locked(locked));

   parameter decode1_width = 4;
   wire [decode1_width-1:0] 	   count1;
   quadrature_decode decode1 
     (
      .A(ENC_A_raw),
      .B(ENC_B_raw),
      .count(count1),
      .clk(clk)
      );
   defparam decode1.width = decode1_width;
   
   
   localparam SYS_CNTR_WIDTH = 25;
   reg [SYS_CNTR_WIDTH-1:0] syscounter;

   always @(posedge clk) syscounter <= syscounter + 1;

   assign LED5 = syscounter[SYS_CNTR_WIDTH-1];

   assign LED4 = count1[3] == 0 && count1[2] == 0;
   assign LED3 = count1[3] == 0 && count1[2] == 1;
   assign LED2 = count1[3] == 1 && count1[2] == 0;
   assign LED1 = count1[3] == 1 && count1[2] == 1;

endmodule		 
