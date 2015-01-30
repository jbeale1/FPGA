`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:   John Beale
// 
// Create Date:    2:23 pm 30-JAN-2015
// Module Name:    pulsegate 
// Description:  emit a specified number of pulses of clock
//   ...plus a 5 ns (?) "runt pulse" at the end
//
//////////////////////////////////////////////////////////////////////////////////
module pulsegate(
    input clk,     // clock input to be gated 
	 input reset,   // zero out counter register
    input run,     // low=reset; high starts output pulse train
    output gclk,   // gated output
    output done    // high when pulse train complete
    );

parameter COUNT = 4;  // how many clock pulses to emit

reg doneflag;  // 1 with clock output, 0 when pulse train complete
reg doneflag2; // updated on falling edge of clk

reg [7:0] bitcnt;  // counter to track pulses
wire csig[1:0];    // input to clock select multplexer
wire cselect;         // clock mux select line

// 4 inputs: clk, reset, run, bitcnt[]
// 2 outputs: bitcnt[], doneflag
always @(posedge clk)
begin
 if (reset)
  begin
   bitcnt <= 0;
	doneflag <= 1'b1;  // start out "done", until next 'run'
  end
 else
  begin
   if (run)  // 'run' high: clear done flag & bit counter
    begin 
     doneflag <= 0;  // clear doneflag on rising clk
     bitcnt <= 8'd0;
	 end
   else  // 'run' low:  count up, and signal end pulse
    begin
     bitcnt <= bitcnt+1;
  	  if (bitcnt == (COUNT-1))
 	    doneflag <= 1'b1;

// NOTE! doneflag net has a latch, with missing 'else bitcnt ==' assignment

    end
  end
end

assign cnt = bitcnt; // DEBUG

assign csig[0] = 0;     // no signal when done
assign csig[1] = clk;   // clock signal to pass through
assign cselect = ~run & ~doneflag;  // clock output = input clk, or 0
assign gclk = csig[cselect];  // clock output mux

assign done = doneflag;  // send 'done' register to output wire

endmodule
