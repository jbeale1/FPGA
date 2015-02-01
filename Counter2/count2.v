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
	   input ena1, 
	   output wire [MSB:0] out );
		
parameter WIDTH = 32;  // bits in the counter (not including clock LSB)
localparam MSB = WIDTH-1;  // bit numbering from 0 to MSB	 
	 
reg [MSB:0] count;
reg [MSB:0] lastcount; // value of 'count' from 1/2 clock cycle ago

reg clkreg;  // save the value of the clock signal as the LSB of counter

always @(posedge clk) 
  begin
    if (reset)
	   count <= 0;   // reset counter to zero
    else 
	   if (ena1)  
	    begin
        count <= count+1;    
       end
		else // not enabled; hold count
		 begin
		  count <= lastcount;
		 end
  end
  
always @(negedge clk)
  begin
    lastcount <= count;  // save the value from previous positive edge
  end
  
assign out = count;   // output counter bits 
endmodule

