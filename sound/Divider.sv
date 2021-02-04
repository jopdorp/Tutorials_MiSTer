module Divider(
	input[63:0] a, b,
	output[31:0] out
);
	assign out = (a <<< 20 )/ b;
endmodule