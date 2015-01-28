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
	   output wire [WIDTH:0] out );
		
parameter WIDTH = 30;  // total bits in the counter
localparam MSB = WIDTH-1;  // bit numbering from 0 to MSB	 
	 
reg [MSB:0] cnt;
reg clkreg;  // save the value of the clock signal as the LSB of counter

always @(posedge clk) 
  begin
    if (reset)
	   cnt <= 0;   // reset counter to zero
    else 
	   if (ena1)  
	    begin
        cnt <= cnt+1;    
		  clkreg <= clk; // clock signal itself is LSB of counter
       end
  end
  
// assign out = cnt[WIDTH -:7];   // show output of counter on 7 LEDs
assign out[WIDTH -:(WIDTH-1)] = cnt;   // output counter bits except LSB
assign out[0] = clkreg;  // counter LSB is clock value
endmodule

