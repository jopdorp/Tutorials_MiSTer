module synthesizer_tb;
   localparam int clock_speed = 96000;
   reg clk = 0;

   shortint sample;

   int voice_volumes[7:0];
   int frequencies[7:0];

   Synthesizer synth(
    .clk(clk),
    .clock_speed_divided_by_16(clock_speed),
    .filter_enabled(1'b0),
    .cutoff(3'd4),
    .voice_volumes(voice_volumes),
    .frequencies(frequencies),
    .out(sample)
   );

   initial begin
      foreach(voice_volumes[i])begin
         voice_volumes[i] = 0;
         frequencies[i] = 55 <<< 20;    
      end
      voice_volumes[0] = 1 <<< 20;
      test_single_voice();
   end
   
   task test_single_voice;
      frequencies[0] = 55 <<< 20;
      run_and_assert(-1 <<< 14);
      run_and_assert(-1 <<< 14);
      run_and_assert(1 <<< 14);
      run_and_assert(1 <<< 14);
      run_and_assert(-1 <<< 14);
      run_and_assert(-1 <<< 14);
      frequencies[0] = 110 <<< 20;
      run_and_assert(1 <<< 14);
      run_and_assert(-1 <<< 14);
      run_and_assert(1 <<< 14);
      run_and_assert(-1 <<< 14);
      frequencies[0] = 55 <<< 20;
      run_and_assert(-1 <<< 14);
      run_and_assert(1 <<< 14);
      run_and_assert(1 <<< 14);
      run_and_assert(-1 <<< 14);
      run_and_assert(-1 <<< 14);
      frequencies[1] = 110 <<< 20;
      voice_volumes[0] = 0;
      voice_volumes[1] = 1 <<< 19;
      run_and_assert(-1 <<< 13);
      run_and_assert(1 <<< 13);
      voice_volumes[0] = 1 <<< 19;
      run_and_assert(-1 <<< 14);
      run_and_assert(0 <<< 14);
      run_and_assert(0);
      run_and_assert(1 <<< 14);
      run_and_assert(-1 <<< 14);
      run_and_assert(0);
   endtask

   task run_and_assert(shortint expected_sample);
      for(int i = 0; i < 16 * (clock_speed / 220); i++)begin
         #(i*3);
         #1 clk = !clk;
         #1 clk = !clk;
      end
      #1;
      assert (sample == expected_sample) else begin
         $error ("The square_value is:%d , The value expected is:%d", sample, expected_sample);
      end
   endtask
endmodule