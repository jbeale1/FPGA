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
  output wire Gclock, // gated clock from pulsegate
  output wire PSClock // DEBUG show gated clock with 1 extra clock in front
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
reg[2:0]  CurrentState;
reg[2:0]  NextState;

wire PGrun;     // run signal to pulsegate
wire DoneSR; // done flag from pulsegate
// wire PSClock; // clock intput to shift reg

// reg [MSB:0] SR; // shift register to rotate serial data out

// ==============================================
// generate pulse train with fixed number COUNT of clocks
pulsegate #(.COUNT(BITS-1)) pg1 (
    .clk(Clock),     // clock input to be gated 
	 .reset(Reset),   // reset line
    .run(PGrun),     // low=reset; high starts output pulse train
    .gclk(Gclock),   // gated output pulses
    .done(DoneSR)    // high when pulse train complete
    );

// =============================================================
// shift register with parallel load and serial output
parshift #(.WIDTH(BITS)) ps1 (
     .clk(PSClock),  // clock to shift reg (1 more clock than # bits)
	  .load(PGrun),  // signal to parallel-load shift reg
     .din(Data),     // parallel data bus
	  .sout(MOSI),    // serial data output line
	  .done(PSDone)   // shift reg done flag
    );

// =============================================================
//reg  SSreg;  // store value of SS/ output
//reg  [MSB:0] SRdata; // the data being shifted out
 
// signals from combinatorial logic
//assign SCLK = Clock & ^SS;  // output clock is gated by SS/ (select line active low) 

assign SS = (CurrentState == STATE_Initial);          // SS/ driven from register
assign PGrun = (CurrentState == STATE_2);  // pulsegate RUN signal
assign DoneFlag = ( CurrentState == STATE_4);  // last state before IDLE
assign CurrentStateOut = CurrentState; // DEBUG
assign PSClock = (Gclock | (PGrun & Clock));  // one more clock than BITS
// assign SCLK = Gclock; // gated clock signal used as SPI Master output clock
assign SCLK = PSClock; // gated clock signal used as SPI Master output clock
// =============================================================
// State Engine logic sequence for each state
// 4 Inputs : CurrentState, Start, DoneSR, Reset
// 1 Output : NextState

always@( * ) begin  
 if(Reset == 1'b1)
    NextState = STATE_Initial;
 else begin
  NextState = CurrentState;
  case (CurrentState)
    STATE_Initial: begin  // idle state
	  if (Start)  NextState = STATE_1;  // Start is the only way out of idle
	end
	STATE_1: begin    // we have received 'Start' : parallel load shift reg.
	  NextState = STATE_2;
	end
	STATE_2: begin  // signal output starts with b0
	  NextState = STATE_3;
	end
	STATE_3: begin // // shift register is actively shifting data out
      if (DoneSR) NextState = STATE_4;
	end	
	STATE_4: begin // SR is now done, return to idle
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
// =============================================================
// Machine to move state engine one tick forward on each clock
 always@(posedge Clock) begin
  if (Reset) 
    CurrentState <= STATE_Initial;  // initial state upon reset
  else 
    CurrentState <= NextState;
end
// =============================================================

 endmodule