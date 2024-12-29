`include "isa.vh"

module cpu(clk, reset, irq, mem, data_in, data_out);
    input wire clk;
    input wire reset;
    input wire[7:0] irq;
    input wire [255:0] mem;
    input wire [7:0] data_in;
    output reg [7:0] data_out;

    reg run_flg;                // run flag
    reg int_flg;                // interrupt flag
    reg C_flg;                  // carry flag
    reg A_flg;                  // aux carry flag
    reg[7:0] ret_ptr;           // return pointer
    reg[2:0] ret_flgs;          // {int_flg,C_flg,A_flg}
    reg[7:0] IP;                // instruction pointer
    reg[15:0] reg_file[0:31];   // register file

    always@(posedge(clk))
    begin
        if (reset) 
        begin
            $display("[cpu        ] - T(%t) - RESET", $time);
            IP <= `PROG_START;
            `AL <= 0;
            run_flg <= 1;
            int_flg <= 1;
        end 
        else 
        begin
            if (irq) // IRQ
            begin
                $display("[cpu        ] - T(%t) - IRQ(h%h)", $time, irq);
                ret_ptr <= IP;
                IP <= irq;
                ret_flgs <= {int_flg, C_flg, A_flg};
                int_flg <= 0;
            end
            else
            begin
                if (run_flg) 
                begin
                    casez (mem[IP +: 8])
                        `ADDB:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - ADDB", $time, IP);
                            `AL <= `AL + mem[IP + 8 +: 8];
                            IP <= IP + 16;
                        end
                        `ADDW:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - ADDW", $time, IP);
                            `AX <= `AX + {mem[IP + 16 +: 8], mem[IP + 8 +: 8]};
                            IP <= IP + 24;
                        end
                        `ORB:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - ORB", $time, IP);
                            `AL <= `AL | mem[IP + 8 +: 8];
                            IP <= IP + 16;
                        end
                        `ADDW:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - ORW", $time, IP);
                            `AX <= `AX | {mem[IP + 16 +: 8], mem[IP + 8 +: 8]};
                            IP <= IP + 24;
                        end
                        `ANDB:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - ANDB", $time, IP);
                            `AL <= `AL & mem[IP + 8 +: 8];
                            IP <= IP + 16;
                        end
                        `ANDW:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - ANDW", $time, IP);
                            `AX <= `AX & {mem[IP + 16 +: 8], mem[IP + 8 +: 8]};
                            IP <= IP + 24;
                        end
                        `SUBB:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - SUBB", $time, IP);
                            `AL <= `AL - mem[IP + 8 +: 8];
                            IP <= IP + 16;
                        end
                        `SUBW:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - SUBW", $time, IP);
                            `AX <= `AX - {mem[IP + 16 +: 8], mem[IP + 8 +: 8]};
                            IP <= IP + 24;
                        end
                        `XORB:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - XORB", $time, IP);
                            `AL <= `AL ^ mem[IP + 8 +: 8];
                            IP <= IP + 16;
                        end
                        `XORW:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - XORW", $time, IP);
                            `AX <= `AX ^ {mem[IP + 16 +: 8], mem[IP + 8 +: 8]};
                            IP <= IP + 24;
                        end
                        `INCW_PFX:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - INCW???", $time, IP);
                            reg_file[mem[IP +: 2]] <= reg_file[mem[IP +: 2]] + 1;
                            IP <= IP + 8;
                        end
                        `DECW_PFX:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - DECW???", $time, IP);
                            reg_file[mem[IP +: 2]] <= reg_file[mem[IP +: 2]] - 1;
                            IP <= IP + 8;
                        end
                        `MOVRB:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - MOVRB", $time, IP);
                            if (mem[IP + 14 +: 2] != 2'b11) 
                            begin 
                                $display("ERROR: invalid MOVRB mode (b%b)", mem[IP + 14 +: 2]); 
                                $stop;
                            end
                            reg_file[mem[IP + 8 +: 3]][7:0] <= reg_file[mem[IP + 11 +: 3]][7:0];
                            IP <= IP + 16;
                        end
                        `MOVRW:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - MOVRW", $time, IP);
                            if (mem[IP + 14 +: 2] != 2'b11) 
                            begin 
                                $display("ERROR: invalid MOVRW mode (b%b)", mem[IP + 14 +: 2]); 
                                $stop;
                            end
                            reg_file[mem[IP + 8 +: 3]] <= reg_file[mem[IP + 11 +: 3]];
                            IP <= IP + 16;
                        end
                        `NOP:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - NOP", $time, IP);
                            IP <= IP + 8;
                        end
                        `CBW:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - CBW", $time, IP);
                            `AH <= `AX[7] ? 8'hFF : 0;
                            IP <= IP + 8;
                        end
                        `MOVB_PFX:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - MOVB???", $time, IP);
                            reg_file[mem[IP +: 2]] <= mem[IP + 8 +: 8];
                            IP <= IP + 16;
                        end
                        `MOVW_PFX:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - MOVW???", $time, IP);
                            reg_file[mem[IP +: 2]] <= {mem[IP + 16 +: 8], mem[IP + 8 +: 8]};
                            IP <= IP + 24;
                        end
                        `INT: // software interrupt request
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - INT", $time, IP);
                            ret_ptr <= IP;
                            IP <= `PROG_START; // FIXME: for now, go back to program start
                            ret_flgs <= {int_flg, C_flg, A_flg};
                            int_flg <= 0;
                        end
                        `IRET:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - IRET", $time, IP);
                            {int_flg, C_flg, A_flg} <= ret_flgs;
                            IP <= ret_ptr;
                        end
                        `LOOP:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - LOOP(h%h)", $time, IP, `CX);
                            `CX <= `CX - 1;
                            IP <= `CX == 1 ? IP + 16 : IP + mem[IP + 8 +: 8] + 16;
                        end
                        `IN:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - IN", $time, IP);
                            `AL <= data_in;
                            IP <= IP + 8;
                        end
                        `OUT:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - OUT", $time, IP);
                            data_out <= `AL;
                            IP <= IP + 8;
                        end
                        `HLT:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - HLT", $time, IP);
                            run_flg <= 0;
                        end
                        `MULB:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - MULB", $time, IP);
                            if (mem[IP + 14 +: 2] != 2'b11)
                            begin
                                $display("ERROR: invalid mode prefix (b%b)", mem[IP + 14 +: 2]);
                                $stop;
                            end
                            if (mem[IP + 11 +: 3] != 3'b100)
                            begin
                                $display("ERROR: invalid mode (b%b)", mem[IP + 11 +: 3]);
                                $stop;
                            end
                            `AL <= `AL * reg_file[mem[IP + 8 +: 3]][7:0];
                            IP <= IP + 16;
                        end
                        `MULW:
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - MULW", $time, IP);
                            if (mem[IP + 14 +: 2] != 2'b11)
                            begin
                                $display("ERROR: invalid mode prefix (b%b)", mem[IP + 14 +: 2]);
                                $stop;
                            end
                            if (mem[IP + 11 +: 3] != 3'b100) // TODO: unsigned multiply only
                            begin
                                $display("ERROR: invalid mode (b%b)", mem[IP + 11 +: 3]);
                                $stop;
                            end
                            {`DX,`AX} <= `AX * reg_file[mem[IP + 8 +: 3]];
                            IP <= IP + 16;
                        end
                        default: // undefined instruction
                        begin
                            $display("[cpu        ] - T(%t) - IP(h%h) - UI(b%b)", $time, IP, mem[IP +: 8]);
                            IP <= `UII;
                        end
                    endcase
                end
            end
        end
    end
endmodule