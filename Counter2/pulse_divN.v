`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:37:04 01/30/2015 
// Design Name: 
// Module Name:    pulse_divN 
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
module pulse_divN(
    input clk,
    output pulse
    );

parameter BITS = 8;
localparam MSB = (BITS-1);

reg [MSB:0] count = 0;  // binary counter
wire [BITS:0] count_next = count+1;  // one bit more than the counter

always @(negedge clk) 
// count <= count_next[MSB:0];
   count <= (count_next[MSB:0] == 1) ? 2 : count_next[MSB:0];
	
assign pulse = count_next[BITS];  // last bit of the carry chain (counter overflow)


endmodule
