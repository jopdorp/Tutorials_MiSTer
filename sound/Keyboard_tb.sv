module KeyboardTestBench;

	reg clk = 0;
	reg[7:0] key_code = 'h15;
	reg is_pressed = 0;
	
	wire[31:0] frequencies[7:0];
	wire[31:0] voice_volumes[7:0];
	
	int exp_voice_volumes[7:0];
	int exp_frequencies[7:0];

	Keyboard keyboard(
		.clk(clk),
		.pressed(is_pressed),
		.code(key_code),
		.frequencies(frequencies),
		.voice_volumes(voice_volumes)
	);
	
	task run_and_assert;
	    run_clock();
		assert (
			voice_volumes[0] == exp_voice_volumes[0] && exp_frequencies[0] == frequencies[0] && 
			voice_volumes[1] == exp_voice_volumes[1] && exp_frequencies[1] == frequencies[1]) else begin
			$error("0 actual: %d %d expected: %d %d", voice_volumes[0], frequencies[0], exp_voice_volumes[0], exp_frequencies[0]);
			$error("1 actual: %d %d expected: %d %d", voice_volumes[1], frequencies[1], exp_voice_volumes[1], exp_frequencies[1]);
		end
		#1;
	endtask

	initial begin
		for(int i = 0; i < 7; i++)begin
			exp_voice_volumes[i] = 0;
			exp_frequencies[i] = 0;
		end

		run_and_assert();
		is_pressed = 1;
		exp_frequencies[0] = 115343360;
		exp_voice_volumes[0] = 1 <<< 20;
		run_and_assert();
		is_pressed = 0;
		exp_voice_volumes[0] = 0;
		run_and_assert();
		is_pressed = 1;
		key_code = 'h2C;
		exp_frequencies[0] = 173015040;
		exp_voice_volumes[0] = 1 <<< 20;
		run_and_assert();
		is_pressed = 1;
		key_code = 'h16;
		exp_frequencies[1] = 123032917;
		exp_voice_volumes[1] = 1 <<< 20;
		run_and_assert();
		key_code = 'h2C;
		is_pressed = 0;
		exp_voice_volumes[0] = 0;
		run_and_assert();
		key_code = 'h16;
		exp_voice_volumes[1] = 0;
		run_and_assert();

	end

	task run_clock;
		#1 clk = !clk;
		#1 clk = !clk;
	endtask
	
endmodule
