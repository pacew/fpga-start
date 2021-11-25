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

   wire 	   sysclk;
   wire 	   locked;
   
   pll pll_inst (.clock_in(OSCI), .clock_out(sysclk), .locked(locked));

   localparam SYS_CNTR_WIDTH = 24;
   reg [SYS_CNTR_WIDTH-1:0] syscounter;

   reg [7:0] 		    position;
   reg 			    last_a;
   reg 			    last_b;
   
   reg 			    ENC_A;
   reg 			    ENC_B;

   always @(posedge sysclk) begin
     syscounter <= syscounter + 1;

      ENC_A <= ENC_A_raw;
      ENC_B <= ENC_B_raw;

      if (last_a == 0 && last_b == 0) begin
	 if (ENC_B == 1) begin
	    position <= position + 1;
	 end else if (ENC_A == 1) begin
	    position <= position - 1;
	 end
      end else if (last_a == 0 && last_b == 1) begin
	 if (ENC_A == 1) begin
	    position <= position + 1;
	 end else if (ENC_B == 0) begin
	    position <= position - 1;
	 end 
      end else if (last_a == 1 && last_b == 1) begin
	 if (ENC_B == 0) begin
	    position <= position + 1;
	 end else if (ENC_A == 0) begin
	    position <= position - 1;
	 end
      end else if (last_a == 1 && last_b == 0) begin
	 if (ENC_A == 0) begin
	    position <= position + 1;
	 end else if (ENC_B == 1) begin
	    position <= position - 1;
	 end
      end
	    
      last_a <= ENC_A;
      last_b <= ENC_B;
   end

   assign LED5 = syscounter[SYS_CNTR_WIDTH-1];

   assign LED4 = position[3] == 0 && position[2] == 0;
   assign LED3 = position[3] == 0 && position[2] == 1;
   assign LED2 = position[3] == 1 && position[2] == 0;
   assign LED1 = position[3] == 1 && position[2] == 1;

endmodule		 
