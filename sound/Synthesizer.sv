`ifndef fixed_point_math
    `include "fixed_point_math.sv"
`endif

`ifndef square
	`include "Square.sv"
`endif

`ifndef saw
	`include "saw.sv"
`endif

`ifndef synthesizer

`define synthesizer 1

module synthesizer(
    input clk,
    input[31:0] volume_square,
    input[31:0] volume_saw,
    input[31:0] frequency,
    input[31:0] detune,
    output[15:0] out
);
	localparam longint CLOCK_FREQUENCY = 24000000 <<< 20;
    
    wire[15:0] wave_length_integer;
	assign wave_length_integer = CLOCK_FREQUENCY / frequency;

	Multiplier detune_freq(frequency, detune, detuned_freq);
	
    square square_oscilator(clk, wave_length_integer, square_value);
	saw saw_oscilator(clk, wave_length_integer, saw_value);

	Multiplier apply_vol_square(square_value,volume_square, mixed_square);
	Multiplier apply_vol_saw(saw_value,volume_saw, mixed_saw);

	assign out = (mixed_square + mixed_saw) >>> 5;
	
endmodule

`endif
