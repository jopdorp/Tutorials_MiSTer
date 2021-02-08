module KeyboardTestBench;

	reg clk = 0;
	reg[7:0] key_code = 'h15;
	reg is_pressed = 0;
	reg ps2_state = 0;
	
	wire[31:0] frequencies[7:0];
	wire[31:0] voice_volumes[7:0];
	
	int exp_voice_volumes[7:0];
	int exp_frequencies[7:0];

	Keyboard keyboard(
		.clk(clk),
		.ps2_key({ps2_state,is_pressed,1'b0,key_code}),
		.frequencies(frequencies),
		.voice_volumes(voice_volumes)
	);
	
	task run_and_assert;
		run_clock();
		for(int i = 0; i < 7; i++)begin
			assert (voice_volumes[i] == exp_voice_volumes[i] && exp_frequencies[i] == frequencies[i]) else begin
				$error("%d actual: %d %d expected: %d %d", i , voice_volumes[i], frequencies[i], exp_voice_volumes[i], exp_frequencies[i]);
			end	
		end
	endtask

	initial begin
		for(int i = 0; i < 7; i++)begin
			exp_voice_volumes[i] = 0;
			exp_frequencies[i] = 0;
		end

		run_and_assert();
		key_code = 'h15;
		is_pressed = 1;
		ps2_state = 1;
		exp_frequencies[0] = 110 <<< 20;
		exp_voice_volumes[0] = 1 <<< 20;
		run_and_assert();
		run_and_assert();
		is_pressed = 1;
		key_code = 'h4A;
		ps2_state = 0;
		exp_frequencies[6] = 144179200;
		exp_voice_volumes[6] = 1 <<< 20;
		run_and_assert();
		key_code = 'h15;
		is_pressed = 0;
		ps2_state = 1;
		exp_voice_volumes[0] = 0;
		run_and_assert();
		ps2_state = 0;
		is_pressed = 0;
		key_code = 'h4A;
		exp_voice_volumes[6] = 0;
		run_and_assert();
	end

	task run_clock;
		#1 clk = !clk;
		#1 clk = !clk;
		#1;
	endtask
	
endmodule
