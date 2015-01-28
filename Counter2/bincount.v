`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: John Beale
// 
// Create Date:    11:15:45 01/26/2015 
// Module Name:    bincount 
// Description:    binary counter outputs 1 pulse every DIV clocks
//
// Revision: 1.0
//
//////////////////////////////////////////////////////////////////////////////////
module bincount
    (
    input clk,
    input reset,
	 output reg out  // high for 1 clock when full count reached
    );
	 
parameter WIDTH = 13;       // how many bits in counter register
parameter DIV = 12500;      // count up limit. 125 MHz / N = 10 kHz

reg [WIDTH:0] creg;

always @(posedge clk)
 begin
  if (reset) 
    begin
      creg <= 0;  // reset counter to 0
		out <= 0;   // clear output flag
    end
  else 
    begin
      if (creg == (DIV-1))  // roll over after DIV counts
		 begin
         creg <= 0;
			out <= 1;  // set overflow flag
		 end
      else
		 begin
        creg <= creg+1;
		  out <= 0; // no overflow yet, output flag still 0
		 end
	 end
 end
 
endmodule
