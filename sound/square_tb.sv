`ifndef saw
	`include "saw.sv"
`endif

`ifndef square
	`include "Square.sv"
`endif

module square_tb;

   localparam longint CLOCK_FREQUENCY = 24000000 <<< 20;
   localparam length = CLOCK_FREQUENCY >>> 20;
   localparam START_FREQUENCY = 55 <<< 20;
   localparam UPPER_FREQUENCY = 1000 <<< 20;

   bit clk = 0;

   int frequency = START_FREQUENCY;

   wire[31:0] wave_length_integer;
   assign wave_length_integer = CLOCK_FREQUENCY / frequency;

   int square_value;
   square square_generator(clk, wave_length_integer, square_value);
   int saw_value;
   saw saw_generator(clk, wave_length_integer, saw_value);

   int file;
   task generate_sound_csv(string generator_type);
      file = $fopen({generator_type,".csv"}, "wb");
      $fwrite(file,"%s\n", "value");


      for (int i = 0; i < length / 500; i = i + 1) begin
         if (i % 50 == 0) begin
            frequency = frequency * 1.01;
         end
         if (frequency >= UPPER_FREQUENCY) begin
            frequency = START_FREQUENCY;
         end

         if (generator_type == "saw") begin
            #1 $fwrite(file,"%d\n", saw_value >>> 6);
         end
         if (generator_type == "square") begin
            #1 $fwrite(file,"%d\n", square_value >>> 6);
         end

         for(int j = 0; j < 500; j = j + 1)begin
            #1 clk = !clk;
            #1 clk = !clk;
         end
      end
      $fclose(file);
   endtask

   initial begin
      generate_sound_csv("square");
      generate_sound_csv("saw");
   end

endmodule
