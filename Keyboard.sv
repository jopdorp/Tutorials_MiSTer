module Keyboard(input clk, input[31:0] clock_frequency, input[10:0] ps2_key, output shortint frequencies[7:0], output int voice_volumes_out[7:0]);
	`include "get_note_number.sv"
	`include "set_note_frequencies_pythagorean.sv"

	localparam shortint GROUND_NOTE_FREQ = 55 <<< 5;
	localparam TOP_NOTE = 31;
	shortint note_frequencies[TOP_NOTE:0];
	int envelope_counts[7:0];
	int envelope_lengths[1:0];
	int envelope_diff_per_cycle[1:0];
	reg is_playing[7:0];


	byte note_number;
	assign note_number = get_note_number(ps2_key[8:0]);
	int voice_volumes[7:0];

	reg[2:0] selected_voice = 0;

	initial begin
		for (int i = 0; i < 7; i++) begin: init_volumes
			voice_volumes[i] = 0;
			voice_volumes_out[i] = 0;
			frequencies[i] = 0;
			envelope_counts[i] = 0;
			is_playing[i] = 0;
		end
		set_note_frequencties();
		set_envelope();
	end

	task set_envelope;
		envelope_lengths[0] = clock_frequency / 100;
		envelope_lengths[1] = clock_frequency;
		envelope_diff_per_cycle[0] = 44;
		envelope_diff_per_cycle[1] = 44;
	endtask

	always @(posedge clk) begin
		reg old_state;
		old_state <= ps2_key[10];
		
		if (old_state != ps2_key[10] && note_number != -1) begin
			update_voices();
		end else begin // This is not accurate, actually makes it skip a clock cycle, but it avoids a race condition
			for (byte i = 0; i < 7; i++) begin
				update_envelope_for(i);
				voice_volumes_out[i] <= voice_volumes[i] >>> 10;
			end
		end
	end	

	task update_voices;
		if (ps2_key[9]) begin
			start_note();
		end else begin
			stop_note();
		end
	endtask

	task start_note;
		is_playing[selected_voice] <= 1;
		frequencies[selected_voice] <= note_frequencies[note_number];
		envelope_counts[selected_voice] <= 0;
		voice_volumes[selected_voice] <= 1 <<< 30;
		set_next_voice();
	endtask

	task stop_note;
		for (int i = 0; i < 7; i++) begin
			if (frequencies[i] == note_frequencies[note_number]) begin
				voice_volumes[i] <= 0;
				is_playing[i] <= 0;
			end
		end
	endtask

	task set_next_voice;
		for (reg[2:0] i = 0; i < 7; i++)begin
			if (voice_volumes[i] == 0 && i != selected_voice) begin
				selected_voice <= i;
			end
		end
	endtask

	task update_envelope_for(reg[2:0] voice);
		if (is_playing[voice]) begin
			if (voice_volumes[voice] < 0) begin
				is_playing[voice] <= 0;
				voice_volumes[voice] <= 0;
			end else begin
				voice_volumes[voice] <= voice_volumes[voice] - envelope_diff_per_cycle[1];
			end
		end
	endtask

endmodule