	
function byte get_note_number(reg[8:0] code);
	casex(code)
		'h01A: return 0; // z
		'h01B: return 1; // s
		'h022: return 2; // x
		'h023: return 3; // d
		'h021: return 4; // c
		'h02A: return 5; // v
		'h034: return 6; // g
		'h032: return 7; // b
		'h033: return 8; // h
		'h031: return 9; // n
		'h03B: return 10; // j
		'h03A: return 11; // m
		'h041: return 12; // ,
		'h04B: return 13; // l 
		'h049: return 14; // .
		'h04C: return 15; // ;
		'h04A: return 16; // /
		'h015: return 12; // Q
		'h01E: return 13; // 2
		'h01D: return 14; // W
		'h026: return 15; // 3
		'h024: return 16; // E
		'h02D: return 17; // R
		'h02E: return 18; // 5
		'h02C: return 19; // T
		'h036: return 20; // 6
		'h035: return 21; // Y
		'h03D: return 22; // 7
		'h03C: return 23; // U
		'h043: return 24; // I
		'h046: return 25; // 9
		'h044: return 26; // o
		'h045: return 27; // 0
		'h04D: return 28; // p
		'h054: return 29; // [
		'h055: return 30; // =
		'h05B: return 31; // ]
		default: return -1;
	endcase
endfunction