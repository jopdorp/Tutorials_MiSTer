`ifndef iirLowPassSinglePole

`define iirLowPassSinglePole

module iirLowPassSinglePole
#(
    parameter GAIN = 8,
    parameter WIDTH = 16
) (
    input clk,
    input int in,
    output int out
);

    reg signed [WIDTH+GAIN-1:0] accumulator = 0;

    always @(posedge clk) begin
        accumulator <= accumulator + in - out;
    end
    assign out = accumulator[WIDTH+GAIN-1:GAIN];

endmodule

`endif
