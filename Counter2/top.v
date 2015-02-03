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
	  //output clktap, // bit clock output
	  output SS,     // SPI slave-select output line
	  output serbits, // SPI serial data output
	  output serclk, // SPI serial data clock output
	  output serdone, // SPI output done
//	  output pulseN,  // DEBUG output start-SPI-xmit pulse
	  output p1kout,     // 1k divider pulse out
	  output clk10Hz, // 10 Hz signal out
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
wire clk10;
wire clk4M;
assign const1w = const1; // DEBUG

// BUFG U0 (.O(clk50b), .I(clk50));//clkgen clkgen_inst ( 
//         .CLK_IN1(clk50), // external 50 MHz clock from pin
//         .CLK_OUT1(clk) ); // new clock signal from PLL is 500 MHz
			
// Xilinx resource: gated global clock buffer			
// BUFGCE U1 (.O(clkg), .CE(ena_sync), .I(clk)); 			

wire [9:0] word1k;  // output from divide-by-1k counter
wire [9:0] word10Hz;  // output from divide-by-1k counter
wire p1k;  // 1k div pulse output
wire truej;
// wire p1kout;
wire clkg180; // 250 MHz clock at PHASE = 180 degrees
wire clk10kHz;
// wire clk10Hz; // 10 Hz signal out

assign truej = 1'b1;  // DEBUG: fixed logic high
assign p1kout = word1k[9];
assign clk10Hz = word10Hz[9];

BUFG clk10kHz_buf
   (.O   (clk10kHz),
    .I   (word1k[9]));

//assign p1kout = p1k;

// ==============================================================
// generate high-speed clock 
clkgen200 clkgen_A (
 // Clock in ports
  .CLK_IN1(clk50),
  // Clock out ports ============
  .CLK_OUT1_CE(truej),
  .CLK_OUT1(clkg),  // 250 MHz
  .CLK_OUT2_CE(ena_sync),
  .CLK_OUT2(),
  .CLK_OUT3_CE(ena_sync),
  .CLK_OUT3(clkg180),
  .CLK_OUT4_CE(ena_sync),
  .CLK_OUT4(),
  .CLK_OUT5_CE(truej),
  .CLK_OUT5(clk10),  // 10 MHz
  .CLK_OUT6_CE(truej),
  .CLK_OUT6(clk4M)
 );


// =======================================
// Divide-by-1000 slow clock generator
bincount1k cnt1k_A (
  .clk(clk10),  // 10 MHz
  .ce(truej),
  .thresh0(),  // 10 kHz
  .q(word1k) );   // 10-bit up counter @ 10 MHz, MSB is 10 kHz, near 50% duty

// =======================================
// Another divide-by-1000 10 Hz clock generator
bincount1k cnt1k_B (
  .clk(clk10kHz),  // 10 MHz
  .ce(truej),
  .thresh0(),  // 10 Hz
  .q(word10Hz) );   // 10-bit up counter @ 10 MHz, MSB is 10 kHz, near 50% duty


//cdiv2 cdiv2_A (
//         .CIN(clk10), // 10 MHz clock signal from clkgen PLL
//			.COUT(clk2) ); // clk output is divided by two

//cdiv2 cdiv2_B (
//         .CIN(clk2), // from first flop
//			.COUT(clk3) ); // slower clk output is clk2 divided by two
			
// ================================================================

//synch syn_A (     // synchronize enable input with (fast clock)
//    .clk(clkg),
//    .in(ena_raw),
//    .out(ena_sync)
//    );


// take 1pps with small duty cycle and get 0.5 Hz with 50% duty cycle
cdiv2 cdiv2_G (
         .CIN(ena_sync), // input pulse
			.COUT(ena1) ); // output is input frequency / 2			

assign ena1_not = ~ena_sync;
	 
level2pulse l2p_A (  // note that 'ena1' must be low through one full 'clktap' cycle
    .clk(clk10kHz),
	 .level(ena1_not),
	 .pulse(ena1_np)
  );	 

// ===========================================================
// high-speed large counter
// ------------------------------------------------------------			
counter1 cnt_inst (
     .clk(clk10),  // fast clock
	  .reset(SW[1]), // reset signal
	  .s_in(ena_raw), // external async enable input
	  .out(creg),   // counter register
	  .outp(ena_sync) // output "captured" pulse
	 );	 
	 
 
// ===========================================================

//bincount #(.WIDTH(12), .DIV(500)) clk100k (
//    .clk(p1k),
//	 .reset(SW[2]),
//	 .out(bflag)
 //   );

//cdiv2 cdiv2_D (
//         .CIN(bflag), // from preset upcounter
//			.COUT(clktap) ); // clock frequency divided by two: 100kHz /2 = 50 kHz

//bincount #(.WIDTH(6), .DIV(50)) clk200Hz (
//    .clk(clktap),
//	 .reset(SW[2]),
//	 .out(clk200)
//    );
	 
//cdiv2 cdiv2_E (
//         .CIN(clk200), // from preset upcounter
//			.COUT(clk100) ); // input clock frequency divided by two, with 50% duty cycle
	
//pulse_divN #(.BITS(8)) pdN_A (
//      .clk(clk10kHz),    // clock input
//		.pulse(pulseN)   // pulse output
//    );

//wire pulseNe; // readout signal gated by count-enable-not
// assign pulseNe = (pulseN & ~ena1); // readout only when not counting

SerialCTL #(.BITS(WIDTH)) sctl_A (  // FSM for Shift Register control
  .Clock(clk10kHz),
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
	 
always @ (posedge serdone) 
  begin
    outword <= creg;
  end

/*
assign LEDS[7] = ena_raw;
assign LEDS[6] = ena1;
assign LEDS[5:0] = outword[MSB -:6];   // show output of counter on 7 LEDs	 
*/
assign LEDS[7] = outword[11];
assign LEDS[6] = outword[10];
assign LEDS[5:0] = 6'b0;
endmodule
