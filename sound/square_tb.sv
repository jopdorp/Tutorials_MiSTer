module square_tb;

   localparam longint CLOCK_FREQUENCY = 48000 <<< 20;
   localparam length = CLOCK_FREQUENCY >>> 20;
   localparam START_FREQUENCY = 55 <<< 20;
   localparam UPPER_FREQUENCY = 1000 <<< 20;

   bit clk = 0;

   int frequency = START_FREQUENCY;
 
   wire[31:0] wave_length_integer;
   assign wave_length_integer = CLOCK_FREQUENCY / frequency;

   int square_value;
   Square square_generator(clk, wave_length_integer, square_value);
   int saw_value;
   Saw saw_generator(clk, wave_length_integer, saw_value);
   string generator_types[1:0];

   initial begin
       generator_types[0] = "square";
       generator_types[1] = "saw";      
   end


   int file[1:0];
   int expected_file[1:0];
   int expected, actual;
   int x,y;
   task generate_sound_csv;
      open_files();
      for (int i = 0; i < length; i = i + 1) begin
         if (i % 50 == 0) begin
            frequency = frequency * 1.01;
         end
         if (frequency >= UPPER_FREQUENCY) begin
            frequency = START_FREQUENCY;
         end
         write_samples();
         #1 clk = !clk;
         #1 clk = !clk;
      end
      close_files();
      check_results();
   endtask


   task open_files;
      for (int i = 0; i < 2; i++) begin
         file[i] = $fopen({generator_types[i],".csv"}, "wb");
      end
   endtask

   task write_samples;
      for (int i = 0; i < 2; i++) begin
         if (generator_types[i] == "saw") begin
            #1 $fwrite(file[i],"%d\n", saw_value >>> 6);
         end
         if (generator_types[i] == "square") begin
            #1 $fwrite(file[i],"%d\n", square_value >>> 6);
         end
      end;
   endtask

   task close_files;
      for (int i = 0; i < 2; i++) begin
         $fclose(file[i]);
      end
   endtask


   task check_results;
      for (int i = 0; i < 2; i++) begin
         expected_file[i]  = $fopen ({generator_types[i],".csv.expected"},"r");
         file[i]  = $fopen ({generator_types[i],".csv"},"r");

         while(!$feof(expected_file[i]) || !$feof(file[i]))begin
            x = $fscanf(expected_file[i]," %d ", expected );
            y = $fscanf(file[i]," %d ", actual);
            assert (actual == expected) else begin
               $error ("The value is:%d , The value expected is:%d",actual,expected);
            end
         end
      end
   endtask

   initial begin
      generate_sound_csv();
   end

endmodule
