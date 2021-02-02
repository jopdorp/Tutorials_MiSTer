`define fixed_point_math 1
// Fixed point at 20th bit from the right
module Multiplier(
	input[63:0] a, b,
	output[31:0] out
);
	assign out = (a * b) >>> 20;
endmodule

module Divider(
	input[63:0] a, b,
	output[31:0] out
);
	assign out = (a <<< 20 )/ b;
endmodule
