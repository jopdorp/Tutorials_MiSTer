module Keyboard(input clk, input[10:0] ps2_key, output int frequencies[7:0], output int voice_volumes[7:0]);
	`include "get_note_number.sv"
	`include "set_note_frequencies_pythagorean.sv"

	localparam TOP_NOTE = 31;
	localparam GROUND_NOTE_FREQ = 55 <<< 20;
	int ratios [TOP_NOTE:0];

	byte note_number = -1;
	wire pressed = ps2_key[9];
	wire new_state = ps2_key[10];
	reg[2:0] selected_voice = 0;

	int note_frequencies[TOP_NOTE:0];

	initial begin
		for (int i = 0; i < 7; i++) begin: init_volumes
			voice_volumes[i] <= 0;
			frequencies[i] <= 0;
		end
		set_note_frequencties();
	end

	always @(posedge clk) begin
		reg old_state;
		old_state <= new_state;
		
		if (old_state != new_state) begin
			handle_key_event();
		end
	end

	task handle_key_event;
		note_number = get_note_number(ps2_key[8:0]);
		if(note_number != -1)begin
			update_voices();
		end
	endtask

	task update_voices;
		if (pressed) begin
			start_note();
		end else begin
			stop_note();
		end
	endtask

	task start_note;
		voice_volumes[selected_voice] <= 1 <<< 20;
		frequencies[selected_voice] <= note_frequencies[note_number];
		selected_voice <= get_next_voice();
	endtask

	task stop_note;
		for (int i = 0; i < 7; i++) begin
			if (frequencies[i] == note_frequencies[note_number]) begin
				voice_volumes[i] <= 0;
			end
		end
	endtask

	function reg[2:0] get_next_voice;
		reg[2:0] next_voice;
		next_voice = 0;
		for (reg[2:0] i = 0; i < 7; i++)begin
			if(!voice_volumes[i] && i != selected_voice)begin
				next_voice = i;
			end
		end
		return next_voice;
	endfunction

endmodule