`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:39:33 01/26/2015 
// Design Name: 
// Module Name:    fsm1 
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

module fsm1 (
  input clk,
  input reset,
  input in,
  output wire out );
  
reg state; // internal state variable
reg outreg; // output signal  
  
always @(posedge clk)
  if (reset) 
    state <= 1'b0;
  else
	  case (state)
	   1'b0: // last input was a zero
	    begin
	     outreg <= 0;
		 if (in) state <= 1'b1;
		 else    state <= 1'b0;
	    end
		 
	   1'b1: // we've seen one 1
       begin
		  outreg <= 1;
       end
		 
	  endcase
	  
assign out = outreg;
endmodule
