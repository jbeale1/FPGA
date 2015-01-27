`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:47:51 01/25/2015 
// Design Name: 
// Module Name:    cdiv2 
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

// ===================================
// divide input clock by 2 in frequency

module cdiv2
    (input wire CIN,
	  output reg COUT );
	  
always @(posedge CIN)
  begin
    COUT <= ~COUT;
  end
endmodule
