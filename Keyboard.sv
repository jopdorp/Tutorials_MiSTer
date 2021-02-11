module Keyboard(input clk, input[10:0] ps2_key, output shortint frequencies[7:0], output int voice_volumes[7:0]);
	`include "get_note_number.sv"
	`include "set_note_frequencies_pythagorean.sv"

	localparam shortint GROUND_NOTE_FREQ = 55 <<< 5;
	localparam TOP_NOTE = 31;
	shortint note_frequencies[TOP_NOTE:0];

	byte note_number;
	assign note_number = get_note_number(ps2_key[8:0]);
	
	reg[2:0] selected_voice = 0;

	initial begin
		for (int i = 0; i < 7; i++) begin: init_volumes
			voice_volumes[i] <= 0;
			frequencies[i] <= 0;
		end
		set_note_frequencties();
	end

	always @(posedge clk) begin
		reg old_state;
		old_state <= ps2_key[10];
		
		if (old_state != ps2_key[10] && note_number != -1) begin
			update_voices();
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
		voice_volumes[selected_voice] <= 1 <<< 20;
		frequencies[selected_voice] <= note_frequencies[note_number];
		set_next_voice();
	endtask

	task stop_note;
		for (int i = 0; i < 7; i++) begin
			if (frequencies[i] == note_frequencies[note_number]) begin
				voice_volumes[i] <= 0;
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

endmodule