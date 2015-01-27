`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:39:56 01/26/2015 
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
  input  clk,
  input load,
  input [WIDTH:0] din,
  output sout );

parameter WIDTH = 30;  // MSB of the shift reg (WIDTH+1 bits total)

reg [WIDTH:0] tmp; 
 
always @(posedge clk) 
  begin 
    if (load) 
      tmp = din; 
    else 
      tmp = {tmp[(WIDTH-1):0], 1'b0}; // shift left and 0-fill on right
  end 

assign sout = tmp[WIDTH]; 
endmodule 
