module Square(
	input clk,
	input set,
	input[31:0] set_sample,
	input[31:0] set_counter,
	input[31:0] wave_length,
	output int counter,
	output int out
);
	initial begin
		out = -1 <<< 20;
		counter = 1;
	end

	always @(posedge clk) begin
	  if (should_flip_state()) begin
			out <= get_sample() * -1;
			counter <= 1;
	  end else begin
		  	out <= get_sample();
		  	counter <= get_counter() + 1;
	  end
	end

	function bit should_flip_state;
		return (get_counter() >= wave_length / 2);
	endfunction

	function int get_sample;
		return (set ? set_sample : out);
	endfunction

	function int get_counter;
		return (set ? set_counter : counter);
	endfunction
endmodule