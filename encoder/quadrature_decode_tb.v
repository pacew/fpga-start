`timescale 1ns / 1ns

`include "quadrature_decode.v"

`define ASSERT(exp, message) \
     begin if (!(exp)) begin \
	UT_FAIL = UT_FAIL + 1; \
		  $display("unit test error: ", message); end end

module test;
   integer UT_FAIL = 0;

   reg 	   clk = 1;
   always #5 clk = !clk;
   
   reg A = 1'bx, B = 1'bx;
   
   parameter width = 8;
   wire [width-1:0] count;
   
   quadrature_decode uut(A, B, count, clk);
   defparam uut.width = width;

  initial begin
     $dumpfile("sim.vcd");
     $dumpvars;
     
     A = 0; B = 0;
     #10;
     `ASSERT(count == 0, "initially zero");
     
     A = 0; B = 1;
     #30;
     `ASSERT(count == 0, "still 0");
     #10;
     `ASSERT(count == 1, "counted to 1");

     A = 1; B = 1;
     #40;
     `ASSERT(count == 2, "counted to 2");

     A = 1; B = 0;
     #40;
     `ASSERT(count == 3, "counted to 3");

     A = 0; B = 0;
     #40;
     `ASSERT(count == 4, "counted to 4");

     A = 1; B = 0;
     #40;     
     `ASSERT(count == 3, "counted to back to 3");

     A = 0; B = 0;
     #40;
     `ASSERT(count == 4, "counted to back to 4");

     if (UT_FAIL) begin
	$display("error: ", UT_FAIL, " unit tests failed");
	$fatal;
     end else begin
	$display("unit tests: success");
     end
     $finish;
     
     
  end // initial begin
   
endmodule // test
