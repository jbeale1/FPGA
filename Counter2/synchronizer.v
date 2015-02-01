`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:55:35 01/31/2015 
// Design Name: 
// Module Name:    synchronizer 
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
module synch(
    input clk,
    input in,
    output out
    );

wire x;

dff dff_A(.d(in), .clk(clk), .q(x));
dff dff_B(.d(x), .clk(clk), .q(out));

endmodule
// ====================================================
// level2pulse : 
// generate neg-edge synch pulse of 2 clocks width on rising edge of 'level'

module level2pulse (
    input clk,
	 input level,
	 output pulse
  );

reg r1;
reg r2;
reg r3;

always @(negedge clk)
  begin
    r1 <= level;
    r2 <= r1;
    r3 <= r2;
  end

assign pulse = ~r3 & r1;

endmodule
	 
// ====================================================
module dff (
  input d,
  input clk,
  output reg q
  );
  
always @(posedge clk)
 begin
    q <= d;
 end
endmodule
 