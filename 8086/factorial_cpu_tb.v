`include "cpu.v"
`include "isa.vh"

// testbed for FACTORIAL
module factorial_cpu_tb;
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

    `include "asm.vh"
        
    integer FLoop;

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
        ORG(`PROG_START);
        IN;                 // read data input channel into AL
        CBW;                // fill AH with AL sign bit
        MOVR(CX, AX);       // CX <= AX
        MOV(AX, 'h01);      // move h01 to AX
        FLoop `LABEL;       // FLoop
        MOVR(BX, AX);       // BX <= AX
        MOVR(AX, CX);       // AX <= CX
        MUL(BX);            // DX,AX <= AX * BX
        LOOP(FLoop);        // decrement CX and loop to FLoop while not zero
        MOVR(AX, BX);       // AX <= BX
        OUT;                // write AL to data output channel
        UII;                // raise an UII

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