module Square(
	input clk,
	input[31:0] wave_length,
	output[31:0] out
);
	int counter = 0;
	int square_wave_value = -1 <<< 20;
	int half_wave_length_integer;
	assign out = square_wave_value;
	
	always @(posedge clk) begin
	  if (counter >= wave_length / 2) begin
			counter <= 0;
			square_wave_value <= square_wave_value * -1;
	  end else begin
			counter <= counter + 1;
	  end
	end

endmodule