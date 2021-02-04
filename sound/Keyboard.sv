module Keyboard(input clk, input pressed, input[7:0] code, output int frequencies[7:0], voice_volumes);
	int ratios_left[12:0];
	int ratios_right[12:0];
	int ratios [12:0];
	longint first, second;
	wire[31:0] ratio;

	initial begin
		for (int i = 0; i < 7; i++) begin: init_volumes
			voice_volumes[i] = 0;
		end
		set_ratios();
	end

    Divider ratio_divider(first, second, ratio);

	task set_division(byte index);
      first = ratios_left[index] <<< 20;
      second = ratios_right[index] <<< 20;
    endtask

	always @(posedge clk) begin
		casex(code)
			'h15: set_division(0); // Q
			'h16: set_division(1); // 2
			'h1D: set_division(2); // W
			'h26: set_division(3); // 3
			'h24: set_division(4); // E
			'h2D: set_division(5); // R
			'h2E: set_division(6); // 5
			'h2C: set_division(7); // T
			'h36: set_division(8); // 6
			'h35: set_division(9); // Y
			'h3D: set_division(10); // 7
			'h3C: set_division(11); // U
			'h43: set_division(12); // I
		endcase

		for (int i = 0; i < 7; i++)begin: set_voice
			if(pressed)begin
				if(voice_volumes[i] == 0)begin
					voice_volumes[i] <= 1 <<< 20;
					frequencies[i] <= ratio * 110;
				end	
			end else begin
				if(frequencies[i] == ratio && voice_volumes[i] == 1)begin
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