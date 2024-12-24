`include "cpu.v"
`include "isa.vh"

module cpu_tb;
    reg clk_val, reset_val;
    reg [7:0] irq_val;
    wire clk, reset;
    wire [7:0] irq;
    reg[2047:0] mem;
    reg[7:0] data_in;
    wire[7:0] data_out;

    initial 
    begin
        clk_val = 1'b0;
        reset_val = 1'b1;
        irq_val = 8'h00;
    end

    // 1 cycle = 2 time units
    always #1 clk_val = ~clk_val;
    assign clk = clk_val;
    assign reset = reset_val;
    assign irq = irq_val;

    cpu cpu_1(
        .clk(clk), 
        .reset(reset), 
        .irq(irq),
        .mem(mem),
        .data_in(data_in),
        .data_out(data_out)
    );
        
    initial
    begin        
        // setup system memory
        assign mem[`MEM_START +: 8] = `HLT;
        assign mem[`UII +: 8] = `HLT;
        assign mem[8'h20 +: 8] = `IRET; // arbitrary hw irq handler
        assign mem[`PROG_START +: 8] = `IN;
        assign mem[`PROG_START + 8 +: 8] = `OUT;
        assign mem[`PROG_START + 16 +: 8] = 0; // undefined instruction

        // set data_in
        assign data_in = 42;

        #2 reset_val = 1'b0; // 1 cycle

        #4 irq_val = 8'h20; // 2 cycles

        $display("[cpu_tb     ] - T(%t) - IRQ(h20)", $time);

        #2 irq_val = 8'h00; // 1 cycle

        #8; // 4 cycles

        // query data_out
        $display("[cpu_tb     ] - T(%t) - data_out is %d", $time, data_out);

        if (data_out[7:0] != 42) 
        begin
            $display("[cpu_tb     ] - T(%t) - data_out is %d, expected %d", $time, data_out[7:0], 42);
            $stop;
        end

        $finish;
    end
endmodule