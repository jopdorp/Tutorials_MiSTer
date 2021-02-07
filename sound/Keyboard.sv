module Keyboard(input clk, input[10:0] ps2_key, output int frequencies[7:0], output int voice_volumes[7:0]);
	localparam TOP_NOTE = 31;
	localparam GROUND_NOTE_FREQ = 55 <<< 20;
	int ratios_left[TOP_NOTE:0];
	int ratios_right[TOP_NOTE:0];
	int ratios [TOP_NOTE:0];
	longint first, second;

	int note_frequencies[TOP_NOTE:0];

	initial begin
		for (int i = 0; i < 7; i++) begin: init_volumes
			voice_volumes[i] <= 0;
			frequencies[i] <= 0;
		end
		set_ratios();
		note_number <= 0;
	end

	byte note_number;
	wire       pressed = ps2_key[9];
	wire [8:0] code    = ps2_key[8:0];
	wire new_state = ps2_key[10];
	reg[2:0] selected_voice = 0;

	always @(posedge clk) begin
		reg old_state;
		old_state <= new_state;
		
		if(old_state != new_state) begin
			set_note_number_blocking();
			if(pressed)begin
				voice_volumes[selected_voice] <= 1 <<< 20;
				frequencies[selected_voice] <= note_frequencies[note_number];
				set_next_voice();
			end else begin
				for (int i = 0; i < 7; i++)begin: stop_note
					if(frequencies[i] == note_frequencies[note_number])begin
						voice_volumes[i] <= 0;
					end
				end
			end
		end
	end

	task set_next_voice;
		begin
			for (reg[2:0] i = 0; i < 7; i++)begin: set_voice
				if(!voice_volumes[i])begin
					selected_voice <= i;
				end
			end
		end
	endtask
	
	task set_note_number_blocking;
		casex(code)
			'h01A: note_number = 0; // z
			'h01B: note_number = 1; // s
			'h022: note_number = 2; // x
			'h023: note_number = 3; // d
			'h021: note_number = 4; // c
			'h02A: note_number = 5; // v
			'h034: note_number = 6; // g
			'h032: note_number = 7; // b
			'h033: note_number = 8; // h
			'h031: note_number = 9; // n
			'h03B: note_number = 10; // j
			'h03A: note_number = 11; // m
			'h041: note_number = 12; // ,
			'h04B: note_number = 13; // l 
			'h049: note_number = 14; // .
			'h04C: note_number = 15; // ;
			'h04A: note_number = 16; // /
			'h015: note_number = 12; // Q
			'h01E: note_number = 13; // 2
			'h01D: note_number = 14; // W
			'h026: note_number = 15; // 3
			'h024: note_number = 16; // E
			'h02D: note_number = 17; // R
			'h02E: note_number = 18; // 5
			'h02C: note_number = 19; // T
			'h036: note_number = 20; // 6
			'h035: note_number = 21; // Y
			'h03D: note_number = 22; // 7
			'h03C: note_number = 23; // U
			'h043: note_number = 24; // I
			'h046: note_number = 25; // 9
			'h044: note_number = 26; // o
			'h045: note_number = 27; // 0
			'h04D: note_number = 28; // p
			'h054: note_number = 29; // [
			'h055: note_number = 30; // =
			'h05B: note_number = 31; // ]
		endcase
	endtask

	task set_ratios;
		note_frequencies[0] = GROUND_NOTE_FREQ * 1;
		note_frequencies[1] = GROUND_NOTE_FREQ * 16 / 15;
		note_frequencies[2] = GROUND_NOTE_FREQ * 9 / 8;
		note_frequencies[3] = GROUND_NOTE_FREQ * 6 / 5;
		note_frequencies[4] = GROUND_NOTE_FREQ * 5 / 4;
		note_frequencies[5] = GROUND_NOTE_FREQ * 4 / 3;
		note_frequencies[6] = GROUND_NOTE_FREQ / 32 * 45;
		note_frequencies[7] = GROUND_NOTE_FREQ * 3 / 2;
		note_frequencies[8] = GROUND_NOTE_FREQ * 8 / 5;
		note_frequencies[9] = GROUND_NOTE_FREQ * 5 / 3;
		note_frequencies[10] = GROUND_NOTE_FREQ * 16 / 9;
		note_frequencies[11] = GROUND_NOTE_FREQ * 15 / 8;
		note_frequencies[12] = note_frequencies[0] <<< 1;
		note_frequencies[13] = note_frequencies[1] <<< 1;
		note_frequencies[14] = note_frequencies[2] <<< 1;
		note_frequencies[15] = note_frequencies[3] <<< 1;
		note_frequencies[16] = note_frequencies[4] <<< 1;
		note_frequencies[17] = note_frequencies[5] <<< 1;
		note_frequencies[18] = note_frequencies[6] <<< 1;
		note_frequencies[19] = note_frequencies[7] <<< 1;
		note_frequencies[20] = note_frequencies[8] <<< 1;
		note_frequencies[21] = note_frequencies[9] <<< 1;
		note_frequencies[22] = note_frequencies[10] <<< 1;
		note_frequencies[23] = note_frequencies[11] <<< 1;
		note_frequencies[24] = note_frequencies[0] <<< 2;
		note_frequencies[25] = note_frequencies[1] <<< 2;
		note_frequencies[26] = note_frequencies[2] <<< 2;
		note_frequencies[27] = note_frequencies[3] <<< 2;
		note_frequencies[28] = note_frequencies[4] <<< 2;
		note_frequencies[29] = note_frequencies[5] <<< 2;
		note_frequencies[30] = note_frequencies[6] <<< 2;
		note_frequencies[31] = note_frequencies[7] <<< 2;
	endtask
endmodule