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
#( parameter WIDTH = 32 )
   (
     input clk50, // external clock coming in through pin
	  input ena_raw,  // external count enable (PORTA0)
	  input insig1, // second input
	  input [4:1] SW, // dip switches
	  output clktap, // bit clock output
	  output SS,     // SPI slave-select output line
	  output serbits, // SPI serial data output
	  output serclk, // SPI serial data clock output
	  output serdone, // SPI output done
	  output pulseN,  // DEBUG output start-SPI-xmit pulse
	  output [7:0] LEDS  // external LEDs
    );

localparam MSB = WIDTH-1;  // bit numbering from 0 to MSB

wire clk;  // clock signal 
wire clk2; // clock signal divided by 2	 
wire clk3; // clock signal divided by 4	 
wire clk4; // clock signal divided by 8
wire clk5; // clock signal divided by 16

wire [MSB:0] creg; // counter register
wire sdone;  // DONE flag from shift register
wire bflag;  // overflow flag from settable up counter, 20 kHz
wire clk200; // 200 Hz clock signal
wire clk100; // 100 Hz clock signal, 50% duty cycle
wire ena1;   // enable input after synch to fast clock
wire ena1_not; // inverted ena1 signal

// wire pulseN; // single clock pulse every N clocks

reg [MSB:0] outword;  // output buffer
reg outflag; // debug flag output

reg [MSB:0] const1 = 12345;  // DEBUG test vector
wire [MSB:0] const1w;  // DEBUG

assign const1w = const1; // DEBUG


clkgen clkgen_inst ( 
         .CLK_IN1(clk50), // external 50 MHz clock from pin
         .CLK_OUT1(clk) ); // new clock signal from PLL is 500 MHz

cdiv2 cdiv2_A (
         .CIN(clk), // fast clock signal from clkgen PLL
			.COUT(clk2) ); // clk output is divided by two

cdiv2 cdiv2_B (
         .CIN(clk2), // from first flop
			.COUT(clk3) ); // slower clk output is clk2 divided by two
			
cdiv2 cdiv2_C (
         .CIN(clk3), // from first flop
			.COUT(clk4) ); // slower clk output is clk2 divided by two			

cdiv2 cdiv2_F (
         .CIN(clk4), // from first flop
			.COUT(clk5) ); // slower clk output is clk2 divided by two			

// ================================================================

synch syn_A (     // synchronize enable input with (fast clock)
    .clk(clk),
    .in(ena_raw),
    .out(ena1)
    );
	 
level2pulse l2p_A (  // note that 'ena1' must be low through one full 'clktap' cycle
    .clk(clktap),
	 .level(ena1_not),
	 .pulse(ena1_np)
  );	 
			
counter1 cnt_inst (
     .clk(clk),  // fast clock
	  .reset(SW[1]), // reset signal
	  .ena1(ena1), // external enable input
	  .out(creg)   // counter register
	 );	 

bincount #(.WIDTH(12), .DIV(6250)) clk20k (
    .clk(clk3),
	 .reset(SW[2]),
	 .out(bflag)
    );

cdiv2 cdiv2_D (
         .CIN(bflag), // from preset upcounter
			.COUT(clktap) ); // clock frequency divided by two: 20kHz /2 = 10 kHz

bincount #(.WIDTH(6), .DIV(50)) clk200Hz (
    .clk(clktap),
	 .reset(SW[2]),
	 .out(clk200)
    );
	 
cdiv2 cdiv2_E (
         .CIN(clk200), // from preset upcounter
			.COUT(clk100) ); // input clock frequency divided by two, with 50% duty cycle
	
pulse_divN #(.BITS(8)) pdN_A (
      .clk(clktap),    // clock input
		.pulse(pulseN)   // pulse output
    );

wire pulseNe; // readout signal gated by count-enable-not
assign pulseNe = (pulseN & ~ena1); // readout only when not counting

SerialCTL #(.BITS(WIDTH)) sctl_A (  // FSM for Shift Register control
  .Clock(clktap),
  .Reset(SW[2]),
  .Start(ena1_np),          // single-clock (clktap) pulse, right after 'ena1' goes low
//  .Data(outword),             // counter is data word to shift out
  .Data(creg),             // counter is data word to shift out
	
  .SS(SS),      // SPI slave select (active low)
  .SCLK(serclk),    // SPI clock output
  .MOSI(serbits),     // SPI MOSI serial data output
  .DoneFlag(serdone)  // 1-clk pulse indicating done
  );	 
	 
// ==============================================
// generate pulse train with fixed number COUNT of clocks
/*
pulsegate #(.COUNT(8)) pg1 (
    .clk(clk5),     // clock input to be gated 
    .run(clk100),     // low=reset; high starts output pulse train
    .gclk(PORTA7),   // gated output pulses
    .done(PORTA9)    // high when pulse train complete
    );	 
*/
	 
always @ (posedge clk4) 
  begin
    outword <= creg;
  end

assign LEDS[7] = ena_raw;
assign LEDS[6] = ena1;
assign LEDS[5:0] = outword[MSB -:6];   // show output of counter on 7 LEDs	 
assign ena1_not = ~ena1;

endmodule
