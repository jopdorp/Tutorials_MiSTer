module Synthesizer(
    input clk,
    input[31:0] clock_speed_divided_by_32,
    input filter_enabled,
    input[2:0] cutoff,
    input[31:0] voice_volumes[7:0],
    input[31:0] frequencies[7:0],
    output shortint out
);
	wire[63:0] CLOCK_FREQUENCY = clock_speed_divided_by_32 <<< 20;

    int square_value;
    int mixed_sample;

    int wave_length_integer;
    int combined;
    int combined_result;

    int voice_samples[7:0];
    int voice_counters[7:0];

    initial begin
      for(int i = 0; i < 7; i++) begin
         voice_samples[i] = -1 <<< 20;
         voice_counters[i] = 1;
      end
    end
    
    int set_sample;
    int set_counter;
    int out_counter;

    longint volume;

    wire[63:0] sample;
    assign sample = square_value;


    Multiplier apply_vol_saw(sample, volume, mixed_sample);

    Square square_oscilator(
        .clk(clk),
        .set(1'b1),
        .set_sample(set_sample),
        .set_counter(set_counter),
        .wave_length(wave_length_integer),
        .counter(out_counter),
        .out(square_value)
    );

    reg[1:0] step = 0;

    reg[2:0] voice = 0;

    always @(posedge clk) begin
        step <= step + 1;
        if (step == 0) begin
            if(voice == 0)begin
            end
            prepare_voice(voice);
        end 

        if (step == 2) begin
            mix_voices(voice);
            voice <= voice + 1;
        end

        if (step == 3 && voice == 0) begin
            set_output(voice);
        end
    end

    task prepare_voice(reg[2:0] index);
        set_sample <= voice_samples[index];
        set_counter <= voice_counters[index];
        wave_length_integer <= CLOCK_FREQUENCY / frequencies[index];
        volume <= voice_volumes[index];
    endtask

    task mix_voices(reg[2:0] index);
        voice_samples[index] <= square_value;
        voice_counters[index] <= out_counter;
        combined <= (index == 0) ? mixed_sample : combined + mixed_sample;
    endtask

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