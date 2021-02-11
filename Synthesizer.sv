module Synthesizer(
    input clk,
    input[31:0] clock_speed_divided_by_32,
    input filter_enabled,
    input[2:0] cutoff,
    input[31:0] voice_volumes[7:0],
    input[31:0] frequencies[7:0],
    output shortint out
);
    `include "multiply.sv"

    initial begin
      for(int i = 0; i < 7; i++) begin
         voice_samples[i] = -1 <<< 20;
         voice_counters[i] = 1;
      end
    end
    
    int voice_samples[7:0];
    int voice_counters[7:0];

    int mixed_sample = 0;
    int combined;
    int combined_result;

    wire[31:0] sample;
    OscilatorWires square(clk,1'b1);
    assign sample = square.out;

    Square square_oscilator(
        .clk(clk),
        .set(1'b1),
        .set_sample(square.set_sample),
        .set_counter(square.set_counter),
        .wave_length(square.wave_length),
        .counter(square.counter),
        .out(square.out)
    );

    reg[1:0] step = 0;
    reg[2:0] voice = 0;

    always @(posedge clk) begin
        step <= step + 1;
        if (step == 0) begin
            prepare_voice(voice);
        end 

        if (step == 2) begin
            mix_voices(voice);
            voice <= voice + 1;
        end

        if (step == 3 && voice == 0) begin
            set_output();
        end
    end

    task prepare_voice(reg[2:0] index);
        square.set_sample <= voice_samples[index];
        square.set_counter <= voice_counters[index];
        square.wave_length <= (clock_speed_divided_by_32 <<< 10) / (frequencies[voice] >>> 10);
    endtask

    task mix_voices(reg[2:0] index);
        voice_samples[index] <= square.out;
        voice_counters[index] <= square.counter;
        mixed_sample <= mix_voice(index);
        combined <= (index == 0) ? mixed_sample : combined + mixed_sample;
    endtask

    function int mix_voice(reg[2:0] index);
        return multiply(sample,voice_volumes[index]);
    endfunction

    task set_output;
        combined_result <= combined;
    endtask

    localparam N_FILTERS = 8;
    wire[31:0]  filter_outs[N_FILTERS-1:0];
    genvar i;
    generate
        for (i = 0; i < N_FILTERS; i = i + 1) begin : set_filters
            iirLowPassSinglePole #(i,32) filter0(clk, combined_result <<< 7, filter_outs[i]);
        end
    endgenerate

    assign out = filter_enabled ? filter_outs[cutoff] >>> 16 : combined_result >>> 6;

endmodule

interface OscilatorWires(input clk, input set);
	reg[31:0] set_sample;
	reg[31:0] set_counter;
	reg[31:0] wave_length;
    wire[31:0] counter;
    wire[31:0] out;
endinterface

