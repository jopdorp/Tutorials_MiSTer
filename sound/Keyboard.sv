module Keyboard(input pressed, input[8:0] code, output int frequencies[7:0], voice_volumes);
	int ratios_left[12:0];
	int ratios_right[12:0];
	int ratios [12:0];
	longint first, second;
	wire[31:0] divided;

	initial begin
		for (int i = 0; i < 8; i++) begin: init_volumes
			voice_volumes[i] = 0;
		end
		set_ratios();
	end

    Divider ratio_divider(first, second, divided);

	task set_division(byte index);
      first = ratios_left[index] <<< 20;
      second = ratios_right[index] <<< 20;
    endtask

	always @(posedge clk_audio) begin
		casex(code)
			'h015: set_division(0); // R
			'h016: set_division(1); // F
			'h01D: set_division(2); // D
			'h026: set_division(3); // G
			'h024: set_division(4); // A
			'h02D: set_division(5); // A
			'h02E: set_division(6); // A
			'h02C: set_division(7); // A
			'h036: set_division(8); // A
			'h035: set_division(9); // A
			'h036: set_division(10); // A
			'h03D: set_division(11); // A
			'h03C: set_division(12); // A
		endcase

		for (int i = 0; i < 8; i++)begin: set_voice
			if(pressed)begin
				if(voice_volumes[i] == 0)begin
					voice_volumes[i] <= 1 <<< 20;
					frequencies[i] <= divided * 110;
				end	
			end else begin
				if(frequencies[i] == divided && voice_volumes[i] == 1)begin
					voice_volumes[i] <= 0;
				end
			end
			
		end
	end

	task set_ratios;
		ratios_left[0] = 1;
		ratios_left[1] = 16;;
		ratios_left[2] = 9;
		ratios_left[3] = 6;
		ratios_left[4] = 5;
		ratios_left[5] = 4;
		ratios_left[6] = 45;
		ratios_left[7] = 3;
		ratios_left[8] = 8;
		ratios_left[9] = 5;
		ratios_left[10] = 16;
		ratios_left[11] = 15;
		ratios_left[12] = 2;

		ratios_right[0] = 1;
		ratios_right[1] = 15;
		ratios_right[2] = 8;
		ratios_right[3] = 5;
		ratios_right[4] = 4;
		ratios_right[5] = 3;
		ratios_right[6] = 32;
		ratios_right[7] = 2;
		ratios_right[8] = 5;
		ratios_right[9] = 3;
		ratios_right[10]= 9;
		ratios_right[11]= 8;
		ratios_right[12]= 1;
	endtask
endmodule