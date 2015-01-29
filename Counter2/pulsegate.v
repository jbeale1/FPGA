`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:56:01 01/28/2015 
// Design Name: 
// Module Name:    pulsegate 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:  emit a specified number of pulses of clock
// ...plus a 5 ns (?) "runt pulse" at the end
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pulsegate(
    input clk,     // clock input to be gated 
    input run,     // low=reset; high starts output pulse train
    output gclk,   // gated output
    output done    // high when pulse train complete
//	 output [7:0] cnt, // DEBUG
//	 output cselect     // DEBUG clock mux select line
    );

parameter COUNT = 4;  // how many clock pulses to emit

reg doneflag;  // 1 with clock output, 0 when pulse train complete
reg doneflag2; // updated on falling edge of clk

reg [7:0] bitcnt;  // counter to track pulses
wire csig[1:0];    // input to clock select multplexer
wire cselect;         // clock mux select line

always @(posedge clk)
begin
   if (^run)
    begin 
     doneflag <= 0;  // clear doneflag on rising clk
     bitcnt <= 8'd0;
	 end
   else
    begin
     bitcnt <= bitcnt+1;
  	  if (bitcnt == (COUNT-1))
 	    doneflag <= 1'b1;
    end
end

assign cnt = bitcnt; // DEBUG

assign csig[0] = 0;     // no signal when done
assign csig[1] = clk;   // clock signal to pass through
assign cselect = ~run & ~doneflag;  // clock output = input clk, or 0
assign gclk = csig[cselect];  // clock output mux

assign done = doneflag;  // send 'done' register to output wire

endmodule
