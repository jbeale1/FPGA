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
	  input [4:1] SW, // dip switches
	  output outsig2, // FSM output
	  output clktap, // bit clock output
	  output serout, // serial data output
	  output [7:0] LEDS  // external LEDs
    );

wire clk;  // clock signal 
wire clk2; // clock signal divided by 2	 
wire clk3; // clock signal divided by 4	 
wire [WIDTH:0] creg; // counter register
wire sdone;  // DONE flag from shift register
wire bflag;  // overflow flag from settable up counter, 20 kHz
wire clk200; // 200 Hz clock signal
wire clk100; // 100 Hz clock signal, 50% duty cycle
reg [WIDTH:0] outword;  // output buffer
reg outflag; // debug flag output

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
	  .reset(SW[1]), // reset signal
	  .ena1(ena1), // external enable input
	  .out(creg)   // counter register
	 );	 

bincount #(.WIDTH(12), .DIV(6250)) clk20k (
    .clk(clk3),
	 .reset(ena1),
	 .out(bflag)
    );

cdiv2 cdiv2_C (
         .CIN(bflag), // from preset upcounter
			.COUT(clktap) ); // clock frequency divided by two: 20kHz /2 = 10 kHz

bincount #(.WIDTH(6), .DIV(50)) clk200Hz (
    .clk(clktap),
	 .reset(ena1),
	 .out(clk200)
    );
	 
cdiv2 cdiv2_D (
         .CIN(clk200), // from preset upcounter
			.COUT(clk100) ); // input clock frequency divided by two, with 50% duty cycle
	
parshift #(.WIDTH(30)) psr_A (      // shift register to transmit data serially
  .clk(clktap),       // 10 kHz bit SR clock
//  .load(insig1),
  .load(clk100),
  .din(outword),      // WIDTH data bus with word to shift out
  .sout(serout),
  .done(sdone)
  );
	 
always @ (posedge clk3) 
  begin
    outword <= creg;
//    outword[7:1] <= creg[WIDTH -: 7];
//    outword[0] <= ena1;
  end


assign LEDS = outword[WIDTH -:8];   // show output of counter on 7 LEDs	 
//assign clktap = ck10o[15];  // MSB of 10 kHz clock word
// assign clktap = outflag;  //debug
assign outsig2 = sdone; // shift register done flag

endmodule
