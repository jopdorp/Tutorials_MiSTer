module synthesizer_tb;

   bit clk = 0;
   shortint synth_out;

   int frequencies[7:0];
   int voice_volumes[7:0];
   localparam int clock_speed_divided_by_32 = 48000;
   localparam longint length = (clock_speed_divided_by_32 >>> 20) / 4;

   reg[2:0] cutoff = 0;

   Synthesizer synth(clk, clock_speed_divided_by_32, 1'b1, cutoff, voice_volumes, frequencies, synth_out);

   int file, i;

   int ratios [12:0];

   longint first, second;
   int divided;
   Divider ratio_divider(first, second, divided);
   longint firstm, secondm;
   int multiplied;
   Multiplier frequency_multiplier(firstm, secondm, multiplied);

   initial begin
      for(int i = 0; i < 7; i++)begin
         voice_volumes[i] <= 1 <<< 20;
         frequencies[i] <= 1;
      end
   end
   
   task set_division(int a, b);
      first = a;
      second = b;
   endtask

   task generate_tone(int tone_length, byte tone, reg [2:0] new_cutoff, int new_detune);
      cutoff = new_cutoff;
      for (i = 0; i < length * tone_length; i=i+1) begin
        firstm <= 110 <<< 20;
        secondm <= ratios[tone];
        #1;
        for(int i=0; i<8;i++)begin
            frequencies[i] <= multiplied * (2^(i%3));
        end
        #1;
        $fwrite(file,"%d\n", synth_out);
        for(int i = 0; i < 32; i++)begin
            #(i*3);
            #1 clk = !clk;
            #1 clk = !clk;
        end
      end
   endtask

   int ratios_left[12:0];
   int ratios_right[12:0];

   initial begin
      set_ratios();
      for (int i = 13; i >= 0; i--) begin
         #1 set_division(ratios_left[i] <<< 20, ratios_right[i] <<< 20);
         #1 ratios[i] = divided;
      end
         
      file = $fopen("synthesizer_song.csv","wb");
      $fwrite(file,"%s\n", "value");

      #1;
      generate_tone(0.5, 0, 1, 0);
      generate_tone(0.5, 7, 1, 0);
      generate_tone(0.5, 3, 2, 0);
      generate_tone(0.5, 2, 2, 0);
      generate_tone(0.5, 0, 3, 0);
      generate_tone(0.5, 12, 3, 0);
      generate_tone(0.5, 8, 4, 0);
      generate_tone(0.5, 7, 4,0 );
      generate_tone(0.5, 0, 5, 0);
      generate_tone(0.5, 7, 5, 0);
      generate_tone(0.5, 3, 6, 0);
      generate_tone(0.5, 2, 6, 0);
      generate_tone(2, 0, 7, 0);

      $fclose(file);      
   end

   task set_ratios;
      ratios_left[0] = 1;
      ratios_left[1] = 16;
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
