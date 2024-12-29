`include "cpu.v"
`include "isa.vh"

// testbed for move operations
module mov_cpu_tb;
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
        assign mem[`PROG_START + 00 +: 8] = `IN;                // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `MOVB | `AL_ID;     // move 8-bit immediate to AL
        assign mem[`PROG_START + 16 +: 8] = 8'h08;              // 8-bit immediate
        assign mem[`PROG_START + 24 +: 8] = `OUT;               // write AL to data output channel
        assign mem[`PROG_START + 32 +: 8] = 0;                  // raise an UII

        assign data_in = 8'h2A; // set data input channel

        #10; // run for 5 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h08);
        if (data_out != 8'h08) 
        begin
            $stop;
        end

        // set reset high
        reset_val = 1'b1;

        #2; // run for 1 cycle

        // set reset low
        reset_val = 1'b0;

        // setup program
        assign mem[`PROG_START + 00 +: 8] = `IN;                                // read from data input channel into AL
        assign mem[`PROG_START + 08 +: 8] = `MOVRB;                             // move reg-to-reg (byte)
        assign mem[`PROG_START + 16 +: 8] = {2'b11, `AL_ID, `CL_ID};            // CL <= AL
        assign mem[`PROG_START + 24 +: 8] = `MOVB | `AL_ID;                     // move 8-bit immediate to AL
        assign mem[`PROG_START + 32 +: 8] = 8'h00;                              // 8-bit immediate
        assign mem[`PROG_START + 40 +: 8] = `MOVRB;                             // move reg-to-reg (byte)
        assign mem[`PROG_START + 48 +: 8] = {2'b11, `CL_ID, `AL_ID};            // AL <= CL
        assign mem[`PROG_START + 56 +: 8] = `OUT;                               // write AL to data output channel
        assign mem[`PROG_START + 64 +: 8] = 0;                                  // raise an UII

        assign data_in = 8'h2A; // set data input channel

        #14; // run for 7 cycles

        // query data output channel
        $display("[cpu_tb     ] - T(%t) - data_out(h%h), expected(h%h)", $time, data_out, 8'h2A);
        if (data_out != 8'h2A) 
        begin
            $stop;
        end

        $finish;
    end
endmodule