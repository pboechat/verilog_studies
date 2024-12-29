`include "cpu.v"
`include "isa.vh"

// testbed for arithmetic and logic operations
module alu_cpu_tb;
    reg clk_val, reset_val;
    wire clk, reset;
    reg[255:0] mem;
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
        assign mem[`PROG_START + 00 +: 8] = `IN;    // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `ADDB;  // add 8-bit immediate to AL
        assign mem[`PROG_START + 16 +: 8] = 8'h08;  // 8-bit immediate
        assign mem[`PROG_START + 24 +: 8] = `OUT;   // write AL to data output channel
        assign mem[`PROG_START + 32 +: 8] = 0;      // raise an UII

        assign data_in = 8'h2A; // set data input channel

        #10; // run for 5 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h32);
        if (data_out != 8'h32) 
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;        // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `SUBB;      // subtract 8-bit immediate to AL
        assign mem[`PROG_START + 16 +: 8] = 8'h08;      // 8-bit immediate
        assign mem[`PROG_START + 24 +: 8] = `OUT;       // write AL to data output channel
        assign mem[`PROG_START + 32 +: 8] = 0;          // raise an UII

        assign data_in = 8'h2A; // set data input channel

        #10; // run for 5 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h22);
        if (data_out != 8'h22) 
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;            // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `ORB;           // OR AL with 8-bit immediate
        assign mem[`PROG_START + 16 +: 8] = 8'b11010101;    // 8-bit immediate
        assign mem[`PROG_START + 24 +: 8] = `OUT;           // write AL to data output channel
        assign mem[`PROG_START + 32 +: 8] = 0;              // raise an UII

        assign data_in = 8'b00101010; // set data input channel

        #10; // run for 5 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(b%b), expected(b%b)", $time, data_out, 8'b11111111);
        if (data_out != 8'b11111111) 
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;            // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `ANDB;          // AND AL with 8-bit immediate
        assign mem[`PROG_START + 16 +: 8] = 8'b00100000;    // 8-bit immediate
        assign mem[`PROG_START + 24 +: 8] = `OUT;           // write AL to data output channel
        assign mem[`PROG_START + 32 +: 8] = 0;              // raise an UII

        assign data_in = 8'b00101010; // set data input channel

        #10; // run for 5 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(b%b), expected(b%b)", $time, data_out, 8'b00100000);
        if (data_out != 8'b00100000) 
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;            // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `XORB;          // XOR AL with 8-bit immediate
        assign mem[`PROG_START + 16 +: 8] = 8'b00101111;    // 8-bit immediate
        assign mem[`PROG_START + 24 +: 8] = `OUT;           // write AL to data output channel
        assign mem[`PROG_START + 32 +: 8] = 0;              // raise an UII

        assign data_in = 8'b00101010; // set data input channel

        #10; // run for 5 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(b%b), expected(b%b)", $time, data_out, 8'b00000101);
        if (data_out != 8'b00000101)
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;            // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `CBW;           // fill AH with AL sign bit
        assign mem[`PROG_START + 16 +: 8] = `INCW | `AX_ID; // increment AX
        assign mem[`PROG_START + 24 +: 8] = `OUT;           // write AL to data output channel
        assign mem[`PROG_START + 32 +: 8] = 0;              // raise an UII

        assign data_in = 8'h2A; // set data input channel

        #10; // run for 5 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h2B);
        if (data_out != 8'h2B)
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;            // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `CBW;           // fill AH with AL sign bit
        assign mem[`PROG_START + 16 +: 8] = `DECW | `AX_ID; // decrement AX
        assign mem[`PROG_START + 24 +: 8] = `OUT;           // write AL to data output channel
        assign mem[`PROG_START + 32 +: 8] = 0;              // raise an UII

        assign data_in = 8'h2A; // set data input channel

        #10; // run for 5 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h29);
        if (data_out != 8'h29)
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;                // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `MOVB | `CL_ID;     // move 8-bit immediate to CL
        assign mem[`PROG_START + 16 +: 8] = 8'h02;              // 8-bit immediate
        assign mem[`PROG_START + 24 +: 8] = `MULB;              // multiply (byte)
        assign mem[`PROG_START + 32 +: 8] = {5'b11100, `CL_ID}; // AX <= AL * CL
        assign mem[`PROG_START + 40 +: 8] = `OUT;               // write AL to data output channel
        assign mem[`PROG_START + 48 +: 8] = 0;                  // raise an UII

        assign data_in = 8'h08; // set data input channel

        #12; // run for 6 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h10);
        if (data_out != 8'h10)
        begin
            $stop;
        end

        // reset
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // zero reset
        reset_val = 1'b0;

        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;                // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `MOVB | `CL_ID;     // move 8-bit immediate to CL
        assign mem[`PROG_START + 16 +: 8] = 8'h02;              // 8-bit immediate
        assign mem[`PROG_START + 24 +: 8] = `MULW;              // multiply (word)
        assign mem[`PROG_START + 32 +: 8] = {5'b11100, `CL_ID}; // AX <= AL * CL
        assign mem[`PROG_START + 40 +: 8] = `OUT;               // write AL to data output channel
        assign mem[`PROG_START + 48 +: 8] = 0;                  // raise an UII

        assign data_in = 8'h81; // set data input channel

        #12; // run for 6 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h02);
        if (data_out != 8'h02)
        begin
            $stop;
        end

        $finish;
    end
endmodule