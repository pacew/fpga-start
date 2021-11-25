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
   
   pll pll_inst (.clock_in(OSCI), .clock_out(clk), .locked(locked));

   localparam SYS_CNTR_WIDTH = 24;
   reg [SYS_CNTR_WIDTH-1:0] syscounter;

   reg [7:0] 		    count;
   reg [1:0] 		    ENC_last;
   
   reg [2:0] 		    ENC_A_sync, ENC_B_sync;

   always @(posedge clk) ENC_A_sync <= {ENC_A_sync[1:0], ENC_A_raw};
   always @(posedge clk) ENC_B_sync <= {ENC_B_sync[1:0], ENC_B_raw};

   wire [1:0] ENC_next = {ENC_A_sync[2], ENC_B_sync[2]};
   
   wire       count_direction = ENC_next[0] ^ ENC_last[1];
   wire       count_enable =    ENC_next[1] ^ ENC_last[0] ^ count_direction;
   
   
   always @(posedge clk) begin
      syscounter <= syscounter + 1;

      if (count_enable)
	 count <= count_direction ? count + 1 : count - 1;

      ENC_last <= ENC_next;
      
   end

   assign LED5 = syscounter[SYS_CNTR_WIDTH-1];

   assign LED4 = count[3] == 0 && count[2] == 0;
   assign LED3 = count[3] == 0 && count[2] == 1;
   assign LED2 = count[3] == 1 && count[2] == 0;
   assign LED1 = count[3] == 1 && count[2] == 1;

endmodule		 
