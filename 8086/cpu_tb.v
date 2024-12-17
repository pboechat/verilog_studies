`include "cpu.v"
`include "isa.vh"

module cpu_tb;
    reg clk_val, reset_val;
    wire clk, reset;
    reg[2047:0] mem;
    reg[7:0] data_in;
    wire[7:0] data_out;

    initial 
    begin
        clk_val = 1'b0;
        reset_val = 1'b1;
    end

    // 1 cycle = 2 time units
    always #1 clk_val = ~clk_val;
    assign clk = clk_val;
    assign reset = reset_val;

    cpu cpu_1(
        .clk(clk), 
        .reset(reset), 
        .mem(mem),
        .data_in(data_in),
        .data_out(data_out)
    );
        
    initial
    begin        
        #2 reset_val = 1'b0; // 1 cycle

        assign mem[7:0] = `IN;
        assign mem[15:8] = `OUT;
        assign mem[23:16] = `HLT;
        assign data_in = 42;

        #8; // 4 cycles

        $display("[%t] %d", $time, data_out);

        if (data_out != 42) 
        begin
            $display("[%t] data_out is %b, expected %b", $time, data_out, 42);
            $stop;
        end

        $finish;
    end
endmodule