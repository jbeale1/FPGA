`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: John Beale
// 
// Create Date:    19:08:12 01/24/2015 
// Design Name: 
// Module Name:    count2 
// Project Name: 
// Target Devices: Spartan-6 XC6SLX9-FTG256
// Tool versions: 
// Description: simple counter
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module counter1
    ( input clk, 
	   input reset,
      input s_in, 
	   output reg [MSB:0] out,  // captured frozen count value
      output outp  // output sync pulse "captured"
		);
		
parameter WIDTH = 32;  // bits in the counter (not including clock LSB)
localparam MSB = WIDTH-1;  // bit numbering from 0 to MSB	 
	 
wire sample;  // signal to grab current value of clock register
reg [MSB:0] count;  // the ever-incrementing register

synch syn_A (.clk(clk), .in(s_in), .out(sample)  ); // synch input to clock
synch syn_B (.clk(clk), .in(sample), .out(outp)  ); // delay "captured" signal out

always @(posedge clk) 
 begin
  count <= count+1; 
//  out <= count;  
 end

always @(negedge clk)
 begin
  if (sample)
    out <= count;
 end
  
// assign out = count;   // output counter bits 
endmodule

