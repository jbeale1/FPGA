// Synchronous Finite-State Machine for simple output-only SPI Master
// based on http://inst.eecs.berkeley.edu/~cs150/fa08/Documents/FSM.pdf

module SimpleFSM (
  input wire  Clock,
  input wire  Reset,
  input wire  Start,
  input wire  [MSB:0] Data,
  
  output wire SS,      // SPI slave select (active low)
  output wire SCLK,    // SPI clock output
  output wire MOSI     // SPI MOSI serial data output
  );
  
parameter BITS = 32;  // how many bits in one SPI output word
localparam MSB = BITS-1;  // count bits from 0 to MSB

// Names of each possible state of the FSM
localparam STATE_Initial = 3'd0,
           STATE_1 = 3'd1,
		   STATE_2 = 3'd2,
		   STATE_3 = 3'd3,
		   STATE_4 = 3'd4,
		   STATE_5 = 3'd5,
		   STATE_6 = 3'd6,
		   STATE_7 = 3'd7;
		   
// Registers holding value of current and future state		   
reg[2:0]  Currentstate;
reg[2:0]  NextState;

reg  SSreg;  // store value of SS/ output
reg  [MSB:0] SRdata; // the data being shifted out
 
// signals from combinatorial logic
assign SCLK = Clock & ^SS;  // output clock is gated by SS/ (select line active low) 
assign SS = SSreg;          // SS/ driven from register
  
always@(posedge Clock) begin
  if (Reset) CurrentState <= STATE_Initial;
  else CurrentState <= NextState;
end

always@( CurrentState or Start ) begin
  NextState = CurrentState;
  case (CurrentState)
    STATE_Initial: begin  // idle state
	  SSreg = 1'b1;      // SS/ signal is inactive in idle state
	  if (Start)  NextState = STATE_1;  // Start is the only way out of idle
	end
	STATE_1: begin    // we have received 'Start' and begin the data output
	  SRdata = Data;  // parallel-load the shift register from input bus
	  SSreg = 1'b0;   // bring SS/ signal active
	  NextState = STATE_2;
	end
	STATE_2: begin
	  // do various stuff
	  NextState = STATE_3;
	end
	STATE_3: begin
	  // do various stuff
	  NextState = STATE_4;
	end	
	STATE_4: begin
	  // do various stuff
	  NextState = STATE_Initial;
	end	
  endcase
 end
 // --------------------------------------------
 endmodule