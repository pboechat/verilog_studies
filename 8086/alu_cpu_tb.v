`include "cpu.v"
`include "isa.vh"

// testbed for arithmetic and logic operations
module alu_cpu_tb;
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
        // setup system memory
        assign mem[`MEM_START +: 8] = `HLT; // handle invalid flow by halting the CPU
        assign mem[`UII +: 8] = `HLT; // handle UII by halting the CPU execution
        assign mem[`PROG_START +: 8] = `IN; // read from data input channel into AL
        assign mem[`PROG_START + 8 +: 8] = `CBW; // extend sign bit through AH
        assign mem[`PROG_START + 16 +: 8] = `ADDW; // add immediate to AX
        assign mem[`PROG_START + 24 +: 8] = 8'h08; // immediate low-byte
        assign mem[`PROG_START + 32 +: 8] = 8'h00; // immediate high-byte
        assign mem[`PROG_START + 40 +: 8] = `OUT; // write AL to data output channel
        assign mem[`PROG_START + 48 +: 8] = 0; // raise an UII

        assign data_in = 42; // set data input channel

        #2 reset_val = 1'b0; // run for 1 cycle

        #12; // run for 6 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(%d), espected(50)", $time, data_out);
        if (data_out[7:0] != 50) 
        begin
            $stop;
        end
        else
        begin
            $finish;
        end
    end
endmodule