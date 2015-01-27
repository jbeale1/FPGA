`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: John Beale
// 
// Create Date:    19:08:12 01/24/2015 
// Design Name: 
// Module Name:    count2 
// Project Name: 
// Target Devices: Spartan-6 XC6SLX9-FTG256
// Tool versions: 
// Description: simple counter
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module count2
#( parameter WIDTH = 29 )
    (
    input wire clk50,
//	 input wire ena1,
    output reg [7:0] LEDS,
	 output reg PORTF10
    );

reg [WIDTH:0] cnt;
wire clk;  // clock signal 
	 
clkgen clkgen_inst ( 
         .CLK_IN1(clk50), // external 50 MHz clock from pin
         .CLK_OUT1(clk) ); // new clock signal
	 
//always @(posedge CLK_OUT1) 
always @(posedge clk) 
  begin
//    if (ena1) begin
    cnt <= cnt+1;
//    end
	 LEDS[7] <= cnt[WIDTH];
    LEDS[6] <= cnt[(WIDTH-1)];
    LEDS[5] <= cnt[(WIDTH-2)];
    LEDS[4:0] <= cnt[26:22];
	 PORTF10 <= cnt[21];
  end

endmodule
