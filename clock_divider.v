module clock_divider(in_hz, max_count, out_hz);
    input wire in_hz;
    input wire [31:0] max_count;
    output wire out_hz;

    reg sqr_wave;
    reg [31:0] count;

    initial
    begin
        count = 0;
    end

    assign out_hz = sqr_wave;

    always@(posedge(in_hz))
    begin
        count <= count == max_count ? 1 : count + 1;
        sqr_wave <= count > max_count>>1 ? 1 : 0;
    end
endmodule