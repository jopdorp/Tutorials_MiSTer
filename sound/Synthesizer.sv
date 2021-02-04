`ifndef fixed_point_math
    `include "fixed_point_math.sv"
`endif

`ifndef square
	`include "Square.sv"
`endif

`ifndef iirLowPassSinglePole
	`include "iirLowPassSinglePole.sv"
`endif


`ifndef saw
	`include "saw.sv"
`endif

`ifndef synthesizer

`define synthesizer 1

module synthesizer(
    input clk,
    input[31:0] clock_speed,
    input[2:0] cutoff,
    input[31:0] volume_square,
    input[31:0] volume_saw,
    input[31:0] frequency[15:0],
    output[15:0] out
);
	wire[63:0] CLOCK_FREQUENCY = clock_speed <<< 20;

    PolyphonicOscilator square_osc();
    PolyphonicOscilator saw_osc();

    int bla[15:0];
    genvar j;
    generate
        for (j = 0; j < 16; j++) begin
            assign bla[j] = frequency[j];
            assign square_osc.wave_length_integer[j] = CLOCK_FREQUENCY / bla[j];
            assign saw_osc.wave_length_integer[j] = square_osc.wave_length_integer[j];

            square square_oscilator(clk, square_osc.wave_length_integer[j], square_osc.value[j]);
            saw saw_oscilator(clk, saw_osc.wave_length_integer[j], saw_osc.value[j]);
        end  
    endgenerate


    always @(posedge clk) begin
        square_osc.combined = 0;
        saw_osc.combined = 0;
        for(byte k = 0; k < 16; k++) begin
            saw_osc.combined = saw_osc.combined + saw_osc.value[k];
            square_osc.combined = square_osc.combined + square_osc.value[k];
        end  
    end

    Multiplier apply_vol_square(square_osc.combined,volume_square >>> 4, saw_osc.mixed);
    Multiplier apply_vol_saw(saw_osc.combined,volume_saw >>> 4, square_osc.mixed);


    localparam N_FILTERS = 8;
    wire[31:0]  filter_outs[N_FILTERS-1:0];
    genvar i;
    generate
        for (i = 0; i < N_FILTERS; i = i + 1) begin
            // convert to unsigned in a better way than << 1
            iirLowPassSinglePole #(i,32) filter0(clk, (square_osc.mixed + saw_osc.mixed) << 1, filter_outs[i]);
        end
    endgenerate
    assign out = filter_outs[cutoff] >>> 7;
    
endmodule

interface PolyphonicOscilator();
    wire[31:0] wave_length_integer[15:0];

    wire[31:0] value[15:0];
    wire[31:0] mixed;

    int combined;
endinterface

`endif
