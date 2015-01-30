`timescale 1ns / 10ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:45:50 01/29/2015
// Design Name:   SerialCTL
// Module Name:   C:/Users/John/ShiftRegControl-FSM-_TB/SR_FSM_TB.v
// Project Name:  ShiftRegControl-FSM-_TB
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SerialCTL
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module SR_FSM_TB;

	// Inputs
	reg Clock;
	reg Reset;
	reg Start;
	reg [31:0] Data;

	// Outputs
	wire SS;
	wire SCLK;
	wire MOSI;
	wire DoneFlag;
	wire [2:0] State;
   wire Gclock;
   wire PSClock;
	
	// Instantiate the Unit Under Test (UUT)
	SerialCTL uut (
		.Clock(Clock), 
		.Reset(Reset), 
		.Start(Start), 
		.Data(Data), 
		.SS(SS), 
		.SCLK(SCLK), 
		.MOSI(MOSI), 
		.DoneFlag(DoneFlag),
		.CurrentStateOut(State), // DEBUG out
		.Gclock(Gclock),
		.PSClock(PSClock) // DEBUG out
	);

	always
		  #2 Clock = !Clock;

	initial 
	begin
		// Initialize Inputs
		Clock = 0;
		Reset = 0;
		Start = 0;
		Data = 32'h6bc57a91;

	   $display("starting simulation for Pulsegate circuit...");

		// Wait 100 ns for global reset to finish
		#100
        
		#102 Reset = 1'b1;
		#107 Reset = 1'b0;
		
		// Add stimulus here		  
    
	   #6 Start = 1'b1;  // bring RUN to true
		$display($time, " << RUN is true >>");  
		#6 Start= 1'b0;  // bring RUN low again
		$display($time, " << RUN goes low >>"); 
		#1000 Start = 1'b0;
		$display($time, " << Simulation Complete >>");
      $stop;
	 end
	 
   initial begin
 // $monitor will print whenever a signal changes
 // in the design
   $monitor($time, " clk=%b, Start=%b, SS=%b, SCLK=%b, DF=%b, State=%d, GCK=%b",
	  Clock, Start, SS, SCLK, DoneFlag, State, Gclock);	 
   end
		
		
endmodule

