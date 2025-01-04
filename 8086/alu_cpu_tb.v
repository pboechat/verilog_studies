`include "cpu.v"
`include "isa.vh"

// testbed for arithmetic and logic operations
module alu_cpu_tb;
    reg clk_val, reset_val;
    wire clk, reset;
    reg[2047:0] mem;
    reg[7:0] data_in;
    wire[7:0] data_out;

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
        IN;                 // read from data input channel into AL
        ADD('h08);          // add h08 to AL
        OUT;                // write AL to data output channel
        UII;                // raise an UII

        assign data_in = 'h2A; // set data input channel

        asm_wait;

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h32);
        if (data_out != 'h32) 
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        ORG(`PROG_START);
        IN;                 // read from data input channel into AL
        SUB('h08);          // subtract h08 from AL
        OUT;                // write AL to data output channel
        UII;                // raise an UII

        assign data_in = 'h2A; // set data input channel

        asm_wait;

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h22);
        if (data_out != 'h22) 
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        ORG(`PROG_START);
        IN;                 // read from data input channel into AL
        OR('b11010101);     // OR AL with b11010101
        OUT;                // write AL to data output channel
        UII;                // raise an UII

        assign data_in = 'b00101010; // set data input channel

        asm_wait;

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(b%b), expected(b%b)", $time, data_out, 8'b11111111);
        if (data_out != 'b11111111) 
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        ORG(`PROG_START);
        IN;                 // read from data input channel into AL
        AND('b00100000);    // AND AL with b00100000
        OUT;                // write AL to data output channel
        UII;                // raise an UII

        assign data_in = 'b00101010; // set data input channel

        asm_wait;

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(b%b), expected(b%b)", $time, data_out, 8'b00100000);
        if (data_out != 'b00100000) 
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        ORG(`PROG_START);
        IN;                 // read from data input channel into AL
        XOR('b00101111);    // XOR AL with b00101111
        OUT;                // write AL to data output channel
        UII;                // raise an UII

        assign data_in = 'b00101010; // set data input channel

        asm_wait;

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(b%b), expected(b%b)", $time, data_out, 8'b00000101);
        if (data_out != 'b00000101)
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        ORG(`PROG_START);
        IN;                 // read from data input channel into AL
        CBW;                // fill AH with AL sign bit
        INC(AX);            // increment AX
        OUT;                // write AL to data output channel
        UII;                // raise an UII

        assign data_in = 'h2A; // set data input channel

        asm_wait;

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h2B);
        if (data_out != 'h2B)
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        ORG(`PROG_START);
        IN;             // read from data input channel into AL
        CBW;            // fill AH with AL sign bit
        DEC(AX);        // decrement AX
        OUT;            // write AL to data output channel
        UII;            // raise an UII

        assign data_in = 'h2A; // set data input channel

        asm_wait;

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h29);
        if (data_out != 'h29)
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        ORG(`PROG_START);
        IN;                 // read from data input channel into AL
        MOV(CL, 'h02);      // move h02 to CL
        MUL(CL);            // AX <= AL * CL
        OUT;                // write AL to data output channel
        UII;                // raise an UII

        assign data_in = 'h08; // set data input channel

        asm_wait;

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h10);
        if (data_out != 'h10)
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        ORG(`PROG_START);
        IN;                 // read from data input channel into AL
        MOV(CL, 'h02);      // move h02 to CL
        MUL(CL);            // AX <= AL * CL
        OUT;                // write AL to data output channel
        UII;                // raise an UII

        assign data_in = 'h81; // set data input channel

        asm_wait;

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h02);
        if (data_out != 'h02)
        begin
            $stop;
        end

        $finish;
    end
endmodule