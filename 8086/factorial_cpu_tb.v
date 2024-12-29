`include "cpu.v"
`include "isa.vh"

// testbed for FACTORIAL
module factorial_cpu_tb;
    reg clk_val, reset_val;
    wire clk, reset;
    reg[255:0] mem;
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
        // setup handlers
        assign mem[`MEM_START +: 8] = `HLT;   // handle invalid flow by halting the CPU
        assign mem[`UII       +: 8] = `HLT;   // handle UII by halting the CPU execution
        
        // set clock high
        clk_val = 1'b0;

        // set reset high
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // set reset low
        reset_val = 1'b0;
        
        // setup program
        assign mem[`PROG_START + 000 +: 8] = `IN;                       // read data input channel into AL
        assign mem[`PROG_START + 008 +: 8] = `CBW;                      // fill AH with AL sign bit
        assign mem[`PROG_START + 016 +: 8] = `MOVRW;                    // move reg-to-reg (word)
        assign mem[`PROG_START + 024 +: 8] = {2'b11, `AX_ID, `CX_ID};   // CX <= AX
        assign mem[`PROG_START + 032 +: 8] = `MOVW | `AX_ID;            // move 16-bit immediate to AX
        assign mem[`PROG_START + 040 +: 8] = 8'h01;                     // 8-bit immediate (low-byte)
        assign mem[`PROG_START + 048 +: 8] = 8'h00;                     // 8-bit immediate (high-byte)
        assign mem[`PROG_START + 056 +: 8] = `MOVRW;                    // move reg-to-reg (word)
        assign mem[`PROG_START + 064 +: 8] = {2'b11, `AX_ID, `BX_ID};   // BX <= AX
        assign mem[`PROG_START + 072 +: 8] = `MOVRW;                    // move reg-to-reg (word)
        assign mem[`PROG_START + 080 +: 8] = {2'b11, `CX_ID, `AX_ID};   // AX <= CX
        assign mem[`PROG_START + 088 +: 8] = `MULW;                     // multiply (word)
        assign mem[`PROG_START + 096 +: 8] = {5'b11100, `BX_ID};        // DX,AX <= AX * BX
        assign mem[`PROG_START + 104 +: 8] = `LOOP;                     // loop
        assign mem[`PROG_START + 112 +: 8] = -64;                       // back to the first MOVRW
        assign mem[`PROG_START + 120 +: 8] = `MOVRW;                    // move reg-to-reg (word)
        assign mem[`PROG_START + 128 +: 8] = {2'b11, `BX_ID, `AX_ID};   // AX <= BX
        assign mem[`PROG_START + 136 +: 8] = `OUT;                      // write AL to data output channel
        assign mem[`PROG_START + 144 +: 8] = 0;                         // raise an UII

        assign data_in = 8'h05; // set data input channel

        #64; // run for 32 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h78);
        if (data_out != 8'h78) 
        begin
            $stop;
        end

        $finish;
    end
endmodule