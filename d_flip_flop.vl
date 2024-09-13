module d_flip_flop(clk, set, out);
    input wire clk;
    input wire set;
    output wire out;

    reg q;

    assign out = q;

    always@(negedge(clk))
    begin
        q <= set;
    end
endmodule