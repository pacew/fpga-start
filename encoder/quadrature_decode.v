module quadrature_decode(
			 input 	A,
			 input 	B,
			 output [width-1:0] count,
			 input 	clk);

   parameter width = 8;
   
   reg [2:0] 			A_sync, B_sync;
   always @(posedge clk) A_sync <= {A_sync[1:0], A};
   always @(posedge clk) B_sync <= {B_sync[1:0], B};
   wire [1:0] next = {A_sync[2], B_sync[2]};

   reg [1:0] 			last;

   reg [width-1:0] 		count_reg;
   
   wire       count_direction = next[0] ^ last[1];
   wire       count_enable =    next[1] ^ last[0] ^ count_direction;
   
   always @(posedge clk) begin
      if (count_enable)
	 count_reg <= count_direction ? count + 1 : count - 1;

      last <= next;
   end

   assign count = count_reg;

endmodule // quadrature_decode
