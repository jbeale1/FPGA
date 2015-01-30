`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: John Beale
// 
// Create Date:    1:28 pm 30-JAN-2015
// Design Name: 
// Module Name:    parshift 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// synchronous parallel load shift register
// adapted from www.csit-sun.pub.ro/courses/Masterat/Xilinx%20Synthesis%20Technology/
// toolbox.xilinx.com/docsan/xilinx4/data/docs/xst/hdlcode8.html

module parshift (
  input  clk,      // shift register clock, data update on rising edge
  input load,      // logic high loads data; low starts shifting out
  input [MSB:0] din,  // bus with data to shift out
  output sout, // the serial output
  output done  // done-shifting flag goes high at start of final bit (b0)
  );

parameter WIDTH = 32;  // MSB of the shift reg (WIDTH+1 bits total)
localparam MSB = WIDTH-1;  // bit numbering from 0 to MSB

reg [MSB:0] sreg;    // shift register data
reg [6:0] bitcount;  // so max WIDTH = 127, but that should be enough...
reg dflag;           // stores DONE flag output
 
// 3 inputs: clk, load, bitcount
// 3 outputs: dflag, bitcount, sreg
always @(posedge clk) 
  begin 
    if (load) 
	  begin
	   dflag = 1'd0;      // reset DONE flag to 0 (false)
	   bitcount = 7'd0;  // set bit counter at b0
      sreg = din;   // b0 is output immediately upon (load & posedge clk)
	  end
    else 
	  begin
       sreg = {sreg[(MSB-1):0], 1'b0}; // shift left and 0-fill on right
		 bitcount = bitcount+1;  // this is the number of current bit output
       if (bitcount == MSB) 
		   dflag = 1'b1;  // MSB is last bit, set DONE flag high
	    else
	      dflag = 1'b0;  // not done yet so DONE remains low
	  end
  end 

assign sout = sreg[MSB];    // shift register data output
assign done = dflag;        // shift register DONE flag output
endmodule 
