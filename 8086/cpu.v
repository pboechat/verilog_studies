`include "isa.vh"

module cpu(clk, reset, mem, data_in, data_out);
    input wire clk;
    input wire reset;
    input wire [2047:0] mem;
    input wire [7:0] data_in;
    output reg [7:0] data_out;

    reg run;
    reg[7:0] IP;
    reg[7:0] AL;

    always@(posedge(clk))
    begin
        if (reset) 
        begin
            IP <= 0;
            AL <= 0;
            run <= 1;
        end 
        else 
        begin
            if (run) 
            begin
                case (mem[(IP * 8) +: 8])
                    `HLT:
                    begin
                        run <= 0;
                    end
                    `IN:
                    begin
                        AL <= data_in[7:0];
                        IP <= IP + 1;
                    end
                    `NOP:
                    begin
                        IP <= IP + 1;
                    end
                    `OUT:
                    begin
                        data_out <= AL;
                        IP <= IP + 1;
                    end
                endcase
            end
        end
    end
endmodule