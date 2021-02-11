module Keyboard(input clk, input int clock_frequency, input[10:0] ps2_key, output int frequencies[TOP_VOICE:0], output int voice_volumes[TOP_VOICE:0]);
	`include "get_note_number.sv"
	`include "set_note_frequencies_pythagorean.sv"
	`include "multiply.sv"
	`include "divide.sv"

	localparam GROUND_NOTE_FREQ = 55 <<< 20;
	localparam TOP_NOTE = 31;
	localparam TOP_VOICE = 7;
	int ratios [TOP_NOTE:0];
	int note_frequencies[TOP_NOTE:0];
	int envelope_counts[7:0];
	int envelope_lengths[1:0];
	int envelope_diff_per_cycle[1:0];
	reg is_playing[TOP_VOICE:0];

	byte note_number;
	assign note_number = get_note_number(ps2_key[8:0]);
	
	reg[2:0] selected_voice = 0;

	initial begin
		for (int i = 0; i < TOP_VOICE; i++) begin: init_volumes
			voice_volumes[i] <= 0;
			frequencies[i] <= 0;
			envelope_counts[i] <= 0;
			is_playing[i] <= 0;
		end
		set_note_frequencties();
		set_envelope();
	end

	task set_envelope;
		envelope_lengths[0] = clock_frequency /  100;
		envelope_lengths[1] = clock_frequency;
		envelope_diff_per_cycle[0] = (1 <<< 20) / envelope_lengths[0];
		envelope_diff_per_cycle[1] = (1 <<< 20) / envelope_lengths[1];
	endtask

	always @(posedge clk) begin
		reg old_state;
		old_state <= ps2_key[10];
		
		if (old_state != ps2_key[10] && note_number != -1) begin
			update_voices();
		end

		for(reg[2:0] i = 0; i < TOP_VOICE; i++)begin
			update_envelope_for(i);
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
		selected_voice <= get_next_voice();
	endtask

	task stop_note;
		for (int i = 0; i < TOP_VOICE; i++) begin
			if (frequencies[i] == note_frequencies[note_number]) begin
				voice_volumes[i] <= 0;
				is_playing[i] <= 0;
			end
		end
	endtask

	function reg[2:0] get_next_voice;
		reg[2:0] next_voice;
		next_voice = 0;
		for (reg[2:0] i = 0; i < TOP_VOICE; i++)begin
			if (voice_volumes[i] == 0 && i != selected_voice) begin
				next_voice = i;
			end
		end
		return next_voice;
	endfunction
	
	
	task update_envelope_for(reg[2:0] voice);
		if (is_playing[voice]) begin
			if (envelope_counts[voice] < envelope_lengths[0]) begin
				envelope_counts[voice] <= envelope_counts[voice] + 1;
				voice_volumes[voice] <= voice_volumes[voice] + envelope_diff_per_cycle[0];
			end else if (envelope_counts[voice] < envelope_lengths[1]) begin
				envelope_counts[voice] <= envelope_counts[voice] + 1;
				voice_volumes[voice] <= voice_volumes[voice] - envelope_diff_per_cycle[1];
			end
		end
	endtask

endmodule