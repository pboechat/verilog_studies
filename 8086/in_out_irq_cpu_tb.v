`include "cpu.v"
`include "isa.vh"

// testbed for IN/OUT and IRQ
module in_out_cpu_tb;
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
        // setup handlers
        assign mem[`MEM_START +: 8] = `HLT;   // handle invalid flow by halting the CPU
        assign mem[`UII       +: 8] = `HLT;   // handle UII by halting the CPU execution
        assign mem[8'h20      +: 8] = `IRET;  // return from an arbitrary IRQ h20
        
        // set clock high
        clk_val = 1'b0;

        // set reset high
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // set reset low
        reset_val = 1'b0;
        
        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;    // read from data input channel
        assign mem[`PROG_START + +8 +: 8] = `OUT;   // write to data output channel
        assign mem[`PROG_START + 16 +: 8] = 0;      // raise an UII

        assign data_in = 8'h2A; // set data input channel

        #2 irq_val = 8'h20; // run for 1 cycle and set IRQ channel to h20

        #2 irq_val = 8'h00; // run for 1 cycle and clear IRQ channel

        #8; // run for 4 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h2A);
        if (data_out != 8'h2A) 
        begin
            $stop;
        end
        else

        $finish;
    end
endmodule