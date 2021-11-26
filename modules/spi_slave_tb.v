`timescale 1ns / 1ns

`include "spi_slave.v"

`define ASSERT(exp, message) \
     begin if (!(exp) || (^(exp) === 1'bx)) begin \
	UT_FAIL = UT_FAIL + 1; \
		  $display("unit test error: ", message, " result=", exp); end end

module test;
   integer UT_FAIL = 0;

   reg 	   clk = 1;
   always #5 clk = !clk;
   
   reg 	   SCK = 0;
   reg 	   SSEL = 0;
   reg 	   MOSI = 0;

   wire [7:0] cmd;
   wire       cmd_valid;
   wire       MISO;
   
   spi_slave uut(clk, SCK, SSEL, MOSI, MISO, cmd, cmd_valid);

   initial begin
      $dumpfile("TMP.vcd");
      $dumpvars;
      
      SSEL = 1; SCK = 0; MOSI = 1; #40; 
      SSEL = 0; SCK = 0; MOSI = 1; #10;

      SSEL = 0; SCK = 1; MOSI = 1; #10; // bit 7
      SSEL = 0; SCK = 0; MOSI = 1; #10;
      SSEL = 0; SCK = 1; MOSI = 1; #10; // bit 6
      SSEL = 0; SCK = 0; MOSI = 1; #10;
      SSEL = 0; SCK = 1; MOSI = 1; #10; // bit 5
      SSEL = 0; SCK = 0; MOSI = 1; #10;
      SSEL = 0; SCK = 1; MOSI = 0; #10; // bit 4
      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 1; #10; // bit 3
      SSEL = 0; SCK = 0; MOSI = 1; #10;
      SSEL = 0; SCK = 1; MOSI = 0; #10; // bit 2
      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 1; #10; // bit 1
      SSEL = 0; SCK = 0; MOSI = 1; #10;
      
      SSEL = 0; SCK = 1; MOSI = 0; // bit 0
      #20;
      `ASSERT(! cmd_valid, "cmd shouldn't be valid yet");
      #10;
      `ASSERT(cmd_valid, "cmd should be valid");
      `ASSERT(cmd == 8'hea, "unexpected cmd value");
      #10;
      `ASSERT(! cmd_valid, "cmd should be only be valid for one cycle");

      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 0; #10; // bit 7
      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 0; #10; // bit 6
      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 0; #10; // bit 5
      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 0; #10; // bit 4
      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 0; #10; // bit 3
      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 0; #10; // bit 2
      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 0; #10; // bit 1
      SSEL = 0; SCK = 0; MOSI = 0; #10;
      SSEL = 0; SCK = 1; MOSI = 1; // bit 0
      #20;
      `ASSERT(! cmd_valid, "cmd should not be valid 2a");
      #10;
      `ASSERT(cmd_valid, "cmd should be valid 2");
      `ASSERT(cmd == 8'h1, "bad final cmd value 2");
      #10;
      `ASSERT(! cmd_valid, "cmd should not be valid 2");

      if (UT_FAIL) begin
	 $display("error: ", UT_FAIL, " unit tests failed");
	 $fatal;
      end else begin
	 $display("unit tests: success");
      end
      $finish;

  end // initial begin
endmodule // test
