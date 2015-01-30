// Synchronous Finite-State Machine for simple output-only SPI Master
// based on http://inst.eecs.berkeley.edu/~cs150/fa08/Documents/FSM.pdf

module SerialCTL (
  input wire  Clock,
  input wire  Reset,
  input wire  Start,
  input wire  [MSB:0] Data,
  
  output wire SS,      // SPI slave select (active low)
  output wire SCLK,    // SPI clock output
  output wire MOSI,     // SPI MOSI serial data output
  output wire DoneFlag,  // 1-clk pulse indicating done
  output wire [2:0] CurrentStateOut, // DEBUG
  output wire Gclock // gated clock from pulsegate
  );
  
parameter BITS = 4;  // how many bits in one SPI output word
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
reg[2:0]  CurrentState;
reg[2:0]  NextState;

wire PGrun;     // run signal to pulsegate
// wire Gclock;  // gated clock signal
wire DoneSR; // done flag from pulsegate
// wire [2:0] CurrentStateOut; // DEBUG

// ==============================================
// generate pulse train with fixed number COUNT of clocks
pulsegate #(.COUNT(4)) pg1 (
    .clk(Clock),     // clock input to be gated 
    .run(PGrun),     // low=reset; high starts output pulse train
    .gclk(Gclock),   // gated output pulses
    .done(DoneSR)    // high when pulse train complete
    );

// =============================================================

//reg  SSreg;  // store value of SS/ output
//reg  [MSB:0] SRdata; // the data being shifted out
 
// signals from combinatorial logic
//assign SCLK = Clock & ^SS;  // output clock is gated by SS/ (select line active low) 

assign SS = (CurrentState == STATE_Initial);          // SS/ driven from register
assign PGrun = (CurrentState == STATE_1);  // pulsgate RUN signal
assign DoneFlag = ( CurrentState == STATE_4);  // last state before IDLE
assign CurrentStateOut = CurrentState; // DEBUG

// =============================================================
// State Engine logic for changing states
// inputs: CurrentState, Start, DoneSR, Reset
// outputs: NextState

always@( * ) begin  
 if(Reset == 1'b1)
    NextState = STATE_Initial;
 else begin
  NextState = CurrentState;
  case (CurrentState)
    STATE_Initial: begin  // idle state
//	  SSreg = 1'b1;      // SS/ signal is inactive in idle state
	  if (Start)  NextState = STATE_1;  // Start is the only way out of idle
	end
	STATE_1: begin    // we have received 'Start' : parallel load shift reg.
                      // and signal output is starting
	  NextState = STATE_2;
	end
	STATE_2: begin  // shift register is actively shifting data out
	  if (DoneSR)  NextState = STATE_3;
	end
	STATE_3: begin // SR is now done
      NextState = STATE_4;
	end	
	STATE_4: begin // final state, return to IDLE after this
	  NextState = STATE_Initial;
	end	
	STATE_5: begin // unused
	  NextState = STATE_Initial;
	end	
	STATE_6: begin // unused
	  NextState = STATE_Initial;
	end	
	STATE_7: begin // unused
	  NextState = STATE_Initial;
	end	
  endcase
 end // if-else
end // always
 // --------------------------------------------
 always@(posedge Clock) begin  // one tick forward of the state engine
  if (Reset) CurrentState <= STATE_Initial;
  else CurrentState <= NextState;
end
// =============================================================

 endmodule