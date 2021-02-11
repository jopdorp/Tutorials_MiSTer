task set_note_frequencties;
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
	for(byte i = 12; i <= TOP_NOTE; i++)begin
		note_frequencies[i] = note_frequencies[i%12] <<< (i / 12);
	end
endtask