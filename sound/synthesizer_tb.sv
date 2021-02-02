`ifndef synthesizer
	`include "Synthesizer.sv"
`endif

`ifndef fixed_point_math
    `include "fixed_point_math.sv"
`endif

module synthesizer_tb;

   bit clk = 0;
   int synth_out;

   int frequency = 20 <<< 20;
   int saw_volume = 1 <<< 19;
   int square_volume = 1 <<< 19;
   int detune = 0;

   synthesizer synth(clk, square_volume, saw_volume, frequency, detune, synth_out);

   localparam longint length = 24000000 <<< 20;
   int file, i;

   int ratios [12:0];

   int first, second, divided;
   Divider ratio_divider(first, second, divided);
	
	int firstm, secondm, multiplied;
   Multiplier frequency_multiplier(firstm, secondm, multiplied);

   task set_division(int a, b);
      first = a;
      second = b;
   endtask

   task generate_tone(int tone_length, byte tone, reg [2:0] new_cutoff, real new_detune);
      saw_volume <= 0.4;
      square_volume <= 0.4;
      for (i = 0; i< (length >>> 20) * tone_length; i=i+1) begin
			firstm <= 110 <<< 20;
			secondm <= ratios[tone];
			#1;
         frequency <= multiplied;
         #1;
         $fwrite(file,"%d\n", synth_out);
			for(int j = 0; j < 500; j = j + 1)begin
            #1 clk = !clk;
            #1 clk = !clk;
         end
      end
   endtask

   //int n = 10000000000;
   int ratios_left[12:0] = '{1,16,9,6,5,4,45,3,8,5,16,15,2};
   int ratios_right[12:0] = '{1,15,8,5,4,3,32,2,5,3,9,8,1};

   initial begin
      for (int i = 13; i > 0; i--) begin
         #1 set_division(ratios_left[i] <<< 20, ratios_right[i] <<< 20);
         #1 ratios[i] = divided;
      end
      // $display("%d %d %d %d %d", ratios[0], ratios[1], ratios[2], ratios[3], ratios[4]);
         
      file = $fopen("synthesizer_song.csv","wb");
      $fwrite(file,"%s\n", "value");

      #1;
      generate_tone(0.5, 0, 3, 0);
      generate_tone(0.5, 7, 3, 0);
      generate_tone(0.5, 3, 3, 0);
      generate_tone(0.5, 2, 3, 0);
      generate_tone(0.5, 0, 3, 0);
      generate_tone(0.5, 12, 3, 0);
      generate_tone(0.5, 8, 3, 0);
      generate_tone(0.5, 7, 3,0 );
      generate_tone(0.5, 0, 3, 0);
      generate_tone(0.5, 7, 3, 0);
      generate_tone(0.5, 3, 3, 0);
      generate_tone(0.5, 2, 3, 0);
      generate_tone(2, 0, 3, 0);

      $fclose(file);      
   end

endmodule
