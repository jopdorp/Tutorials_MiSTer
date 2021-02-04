module Keyboard(input clk, input pressed, input[7:0] code, output int frequencies[7:0], output int voice_volumes[7:0]);
	int ratios_left[12:0];
	int ratios_right[12:0];
	int ratios [12:0];
	longint first, second;

	int note_frequencies[12:0];

	initial begin
		for (int i = 0; i < 7; i++) begin: init_volumes
			voice_volumes[i] <= 0;
			frequencies[i] <= 0;
		end
		set_ratios();
	end


	function get_freq(byte index);
	  return (ratios_left[index] <<< 0)/ (ratios_right[index]) * 110;
	endfunction

	int new_freq;

	reg done = 0;
	
	always @(posedge clk) begin
		casex(code)
			'h15: new_freq = note_frequencies[0]; // Q
			'h16: new_freq = note_frequencies[1]; // 2
			'h1D: new_freq = note_frequencies[2]; // W
			'h26: new_freq = note_frequencies[3]; // 3
			'h24: new_freq = note_frequencies[4]; // E
			'h2D: new_freq = note_frequencies[5]; // R
			'h2E: new_freq = note_frequencies[6]; // 5
			'h2C: new_freq = note_frequencies[7]; // T
			'h36: new_freq = note_frequencies[8]; // 6
			'h35: new_freq = note_frequencies[9]; // Y
			'h3D: new_freq = note_frequencies[10]; // 7
			'h3C: new_freq = note_frequencies[11]; // U
			'h43: new_freq = note_frequencies[12]; // I
		endcase


		done = 0;
		for (int i = 0; i < 7; i++)begin: set_voice
			if(!done)begin
				if(pressed)begin
					if(voice_volumes[i] == 0)begin
						voice_volumes[i] <= 1 <<< 20;
						frequencies[i] <= new_freq;
						done = 1;
					end	
				end else begin
					if(frequencies[i] == new_freq)begin
						voice_volumes[i] <= 0;
					end
				end
			end
		end
	end

	task set_ratios;
		note_frequencies[0] = (110 <<< 20) * 1;
		note_frequencies[1] = (110 <<< 20) * 16 / 15;
		note_frequencies[2] = (110 <<< 20) * 9 / 8;
		note_frequencies[3] = (110 <<< 20) * 6 / 5;
		note_frequencies[4] = (110 <<< 20) * 5 / 4;
		note_frequencies[5] = (110 <<< 20) * 4 / 3;
		note_frequencies[6] = (110 <<< 20) * 45 / 32;
		note_frequencies[7] = (110 <<< 20) * 3 / 2;
		note_frequencies[8] = (110 <<< 20) * 8 / 5;
		note_frequencies[9] = (110 <<< 20) * 5 / 3;
		note_frequencies[10] = (110 <<< 20) * 16 / 9;
		note_frequencies[11] = (110 <<< 20) * 15 / 8;
		note_frequencies[12] = (110 <<< 20) * 2 / 1;
	endtask
endmodule