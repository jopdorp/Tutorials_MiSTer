module Multiplier(
	input[63:0] a, b,
	output[31:0] out
);
	assign out = (a * b) >>> 20;
endmodule