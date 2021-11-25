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

   reg [7:0] 		    position;
   reg [1:0] 		    ENC_last;
   
   reg [2:0] 		    ENC_A_sync, ENC_B_sync;

   always @(posedge clk) ENC_A_sync <= {ENC_A_sync[1:0], ENC_A_raw};
   always @(posedge clk) ENC_B_sync <= {ENC_B_sync[1:0], ENC_B_raw};

   wire [1:0] ENC_next = {ENC_A_sync[2], ENC_B_sync[2]};
   
   always @(posedge clk) begin
     syscounter <= syscounter + 1;

      case (ENC_last)
	2'b00: 
	  begin
	     if (ENC_next[0] == 1)
	       position <= position + 1;
	     else if (ENC_next[1] == 1)
	       position <= position - 1;
	  end
	2'b01:
	  begin
	     if (ENC_next[1] == 1)
	       position <= position + 1;
	     else if (ENC_next[0] == 0)
	       position <= position - 1;
	  end 
	2'b11:
	  begin
	     if (ENC_next[0] == 0)
		position <= position + 1;
	     else if (ENC_next[1] == 0)
		position <= position - 1;
	  end 
	2'b10:
	  begin
	     if (ENC_next[1] == 0)
		position <= position + 1;
	     else if (ENC_next[0] == 1)
		position <= position - 1;
	  end
      endcase

      ENC_last <= ENC_next;
      
   end

   assign LED5 = syscounter[SYS_CNTR_WIDTH-1];

   assign LED4 = position[3] == 0 && position[2] == 0;
   assign LED3 = position[3] == 0 && position[2] == 1;
   assign LED2 = position[3] == 1 && position[2] == 0;
   assign LED1 = position[3] == 1 && position[2] == 1;

endmodule		 
