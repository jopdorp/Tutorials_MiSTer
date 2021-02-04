module Saw(input clk, input[31:0] wave_length, output[31:0] out);
    longint counter = 0;

    wire[63:0] wave_length_fixed_point;
    assign wave_length_fixed_point = wave_length;
    wire[31:0] saw_intermediate;
    Divider saw_val(counter <<< 20, wave_length_fixed_point <<< 20, saw_intermediate);
    assign out = saw_intermediate * 2 - (1 <<< 20);

    always @(posedge clk) begin
        if(counter >= wave_length) begin
            counter <= 0;            
        end else begin
            counter <= counter + 1;
        end
    end

endmodule
