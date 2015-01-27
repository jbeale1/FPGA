`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:58:30 01/25/2015 
// Design Name: 
// Module Name:    top 
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
module top
#( parameter WIDTH = 30 )
   (
     input clk50, // external clock coming in through pin
	  input ena1,  // external count enable
	  input insig1, // second input
	  output outsig2, // FSM output
	  output clktap, // bit clock output
	  output serout, // serial data output
	  output [7:0] LEDS  // external LEDs
    );

wire clk;  // clock signal 
wire clk2; // clock signal divided by 2	 
wire clk3; // clock signal divided by 4	 
wire [WIDTH:0] creg; // counter register
reg [WIDTH:0] outword;  // output buffer
reg outflag; // debug flag output

wire [13:0] ck10o;  // output of 10 kHz clock

clkgen clkgen_inst ( 
         .CLK_IN1(clk50), // external 50 MHz clock from pin
         .CLK_OUT1(clk) ); // new clock signal from PLL is 1 GHz

cdiv2 cdiv2_A (
         .CIN(clk), // fast clock signal from clkgen PLL
			.COUT(clk2) ); // clk output is divided by two

cdiv2 cdiv2_B (
         .CIN(clk2), // from first flop
			.COUT(clk3) ); // slower clk output is clk2 divided by two
			
counter1 cnt_inst (
     .clk(clk2),  // (1GHz / 2) clock
	  .ena1(ena1), // external enable input
	  .out(creg)   // counter register
	 );	 

bincount clk10k (
    .clk(clk3),
	 .reset(ena1),
	 .dout(ck10o)
    );

fsm1 fsm1_A (       // simple finite state machine
      .clk(clk3),
		.reset(ena1),
		.in(insig1),
		.out(outsig2)
	);
	 
parshift psr_A (      // shift register to transmit data serially
  .clk(outflag),       // 10 kHz bit SR clock
  .load(insig1),
  .din(outword),
  .sout(serout)
  );
	 
always @ (posedge clk3) 
  begin
    outword <= creg;
//    outword[7:1] <= creg[WIDTH -: 7];
//    outword[0] <= ena1;
  end

always @ (negedge clk3)
  begin
    	 outflag <= ck10o[13]; // b.13 toggles at 10 kHz
  end

assign LEDS = outword[WIDTH -:8];   // show output of counter on 7 LEDs	 
//assign clktap = ck10o[15];  // MSB of 10 kHz clock word
assign clktap = outflag;  //debug

endmodule
