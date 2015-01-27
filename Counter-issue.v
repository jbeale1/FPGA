// used to work....?
module count2
#( parameter WIDTH = 29 )
    (
    input wire clk50,
    output [7:0] LEDS
    );

reg [WIDTH:0] cnt;
	 
always @(posedge clk50) 
  begin
    cnt <= cnt+1;  // increment counter register on each clock
  end
  
assign LEDS = cnt[WIDTH:(WIDTH-7)];  // output 7 highest-order bits

endmodule


// below code has LED7 blinking at rate expected for LED0, all other LEDs remain off
module count2
#( parameter WIDTH = 29 )
    (
    input wire clk50,
    output [7:0] LEDS
    );

reg [WIDTH:0] cnt;
wire clk;  // clock signal 
	 
clkgen clkgen_inst ( 
         .CLK_IN1(clk50), // external 50 MHz clock from pin
         .CLK_OUT1(clk) ); // new clock signal
	 
always @(posedge clk) 
  begin
    cnt <= cnt+1;  // increment counter register on each clock
  end
  
assign LEDS = cnt[WIDTH:(WIDTH-7)];  // output 7 highest-order bits
endmodule

// ==================================================================
// this one works!

module counter1
#( parameter WIDTH = 30 )
    (input clk50, input ena1, output reg [7:0] LEDS );
	 
reg [WIDTH:0] cnt;

wire clk;  // clock signal 
	 
clkgen clkgen_inst ( 
         .CLK_IN1(clk50), // external 50 MHz clock from pin
         .CLK_OUT1(clk) ); // new clock signal

always @(posedge clk) 
  begin
    if (ena1) begin
      cnt <= cnt+1;
    end
  LEDS <= cnt[WIDTH:WIDTH-7];
  end
endmodule

