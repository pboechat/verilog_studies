// RS flip-flop in dataflow style
module rs_flip_flop_df(set, reset, out);
    input wire set;
    input wire reset;
    output wire out;

    wire q, q_bar;

    assign q = ~(set & q_bar);
    assign q_bar = ~(reset & q);
    assign out = q;
endmodule

// RS flip-flop in behavioral style
module rs_flip_flop_bh(set, reset, out);
    input wire set;
    input wire reset;
    output wire out;

    reg q, q_bar;

    initial begin
        q_bar = 1;
    end

    assign out = q;

    always@(set,reset)
    begin
        q = ~(set & q_bar);
        q_bar = ~(reset & q);
    end
endmodule