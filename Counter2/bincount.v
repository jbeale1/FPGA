`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:15:45 01/26/2015 
// Design Name: 
// Module Name:    bincount 
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
module bincount
    (
    input clk,
    input reset,
    output wire [WIDTH:0] dout
    );
	 
parameter DIVFACTOR = 12500;   // count up limit. 125 MHz / N = 10 kHz
parameter WIDTH = 13;         // how many bits in counter register

reg [WIDTH:0] creg;

always @(posedge clk)
 begin
  if (reset) 
    begin
      creg <= 0;  // reset counter to 0
    end
  else 
    begin
      if (creg == (DIVFACTOR-1))
       creg <= 0;
      else
       creg <= creg+1;
	 end
 end
 
assign dout = creg;  // send it out on the wire

endmodule
