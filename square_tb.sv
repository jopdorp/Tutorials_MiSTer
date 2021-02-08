module osc_tb;
   localparam longint CLOCK_FREQUENCY = 220 <<< 20;

   reg clk = 0;


   reg set = 0;
   int set_sample;
   int set_counter;
   int out_counter;
   int square_value;

   int wave_length_integer = get_wave_length(55 <<< 20); 

   Square square_generator(clk, set, set_sample, set_counter, wave_length_integer, out_counter, square_value);

   initial begin
      foreach (voice_samples[i]) begin
         voice_samples[i] = 1 <<< 20;
         voice_counters[i] = 1;
      end
      
      test_single_voice();
      test_two_voices();
   end

   int voice_samples[1:0];
   int voice_counters[1:0];
   int voice_wave_lengths[1:0];

   int expected_values[1:0];

   task test_two_voices;
      set = 1;
      voice_wave_lengths[0] = get_wave_length(55 <<< 20);
      voice_wave_lengths[1] = get_wave_length(110 <<< 20);
      expected_values[0] = 1 <<< 20;
      expected_values[1] = -1 <<< 20;
      run_and_assert_two_voices();
      expected_values[0] = -1 <<< 20;
      expected_values[1] = 1 <<< 20;
      run_and_assert_two_voices();
      expected_values[1] = -1 <<< 20;
      run_and_assert_two_voices();
      expected_values[1] = 1 <<< 20;
      expected_values[0] = 1 <<< 20;
      run_and_assert_two_voices();
      expected_values[1] = -1 <<< 20;
      run_and_assert_two_voices();
      expected_values[1] = 1 <<< 20;
      expected_values[0] = -1 <<< 20;
      run_and_assert_two_voices();
   endtask


   function int get_wave_length(int frequency);
      return CLOCK_FREQUENCY / frequency;
   endfunction

   task run_and_assert_two_voices;
      foreach (voice_samples[i]) begin
         #(i*4);
         #1 clk = !clk;
         #1 clk = !clk;
         set_sample <= voice_samples[i];
         set_counter <= voice_counters[i];
         wave_length_integer <= voice_wave_lengths[i];

         #1 clk = !clk;
         #1 clk = !clk;
         voice_samples[i] <= square_value;
         voice_counters[i] <= out_counter;

         assert (square_value == expected_values[i]) else begin
            $error ("wave_length_integer is: %d , The counter is:%d , The square_value is:%d , The value expected is:%d", wave_length_integer, voice_counters[i], square_value, expected_values[i]);
         end
         #1;
      end
      
   endtask

   task test_single_voice;
      wave_length_integer = get_wave_length(55 <<< 20);
      run_and_assert(-1 <<< 20);
      run_and_assert(1 <<< 20);
      run_and_assert(1 <<< 20);
      run_and_assert(-1 <<< 20);
      run_and_assert(-1 <<< 20);
      run_and_assert(1 <<< 20);
      wave_length_integer = get_wave_length(110 <<< 20);
      run_and_assert(-1 <<< 20);
      run_and_assert(1 <<< 20);
      run_and_assert(-1 <<< 20);
      wave_length_integer = get_wave_length(55 <<< 20);
      run_and_assert(-1 <<< 20);
      run_and_assert(1 <<< 20);
      run_and_assert(1 <<< 20);
      run_and_assert(-1 <<< 20);
      run_and_assert(-1 <<< 20);
      run_and_assert(1 <<< 20);
   endtask

   task run_and_assert(int expected_value);
      #1 clk = !clk;
      #1 clk = !clk;
      #1;
      assert (square_value == expected_value) else begin
         $error ("The square_value is:%d , The value expected is:%d",square_value,expected_value);
      end
   endtask
endmodule