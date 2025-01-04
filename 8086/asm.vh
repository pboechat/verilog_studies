`define LABEL = (_asm_curr_addr)

integer _asm_base_addr;
integer _asm_curr_addr;

parameter AL = 'b0000 | `AL_ID;
parameter CL = 'b0000 | `CL_ID;
parameter DL = 'b0000 | `DL_ID;
parameter BL = 'b0000 | `BL_ID;
parameter AH = 'b0000 | `AH_ID;
parameter CH = 'b0000 | `CH_ID;
parameter DH = 'b0000 | `DH_ID;
parameter BH = 'b0000 | `BH_ID;
parameter AX = 'b1000 | `AX_ID;
parameter CX = 'b1000 | `CX_ID;
parameter DX = 'b1000 | `DX_ID;
parameter BX = 'b1000 | `BX_ID;

task ORG(input [15:0] base_addr);
begin
    _asm_base_addr = base_addr;
    _asm_curr_addr = base_addr;
end
endtask

task IN;
begin
    mem[_asm_curr_addr +: 8] <= `IN;
    _asm_curr_addr = _asm_curr_addr + 8;
end
endtask

task OUT;
begin
    mem[_asm_curr_addr +: 8] <= `OUT;
    _asm_curr_addr = _asm_curr_addr + 8;
end
endtask

task UII;
begin
    mem[_asm_curr_addr +: 8] <= 0;
    _asm_curr_addr = _asm_curr_addr + 8;
end
endtask

task _ALU_OP(input[7:0] opcode_b, input[7:0] opcode_w, input[15:0] imm);
begin
    if (imm & 'h100) // 16-bit immediate
    begin
        mem[_asm_curr_addr +: 8] <= opcode_w;
        mem[_asm_curr_addr + 8 +: 8] <= imm[7:0];
        mem[_asm_curr_addr + 16 +: 8] <= imm[15:8];
        _asm_curr_addr = _asm_curr_addr + 24;
    end
    else // 8-bit immediate
    begin
        mem[_asm_curr_addr +: 8] <= opcode_b;
        mem[_asm_curr_addr + 8 +: 8] <= imm[7:0];
        _asm_curr_addr = _asm_curr_addr + 16;
    end
end
endtask

task ADD(input[15:0] imm);
begin
    _ALU_OP(`ADDB, `ADDW, imm);
end
endtask

task SUB(input[15:0] imm);
begin
    _ALU_OP(`SUBB, `SUBW, imm);
end
endtask

task AND(input[15:0] imm);
begin
    _ALU_OP(`ANDB, `ANDW, imm);
end
endtask

task OR(input[15:0] imm);
begin
    _ALU_OP(`ORB, `ORW, imm);
end
endtask

task XOR(input[15:0] imm);
begin
    _ALU_OP(`XORB, `XORW, imm);
end
endtask

task CBW;
begin
    mem[_asm_curr_addr +: 8] <= `CBW;
    _asm_curr_addr = _asm_curr_addr + 8;
end
endtask

task INC(input[3:0] reg_id);
begin
    if (reg_id & 'b1000) // 16-bit reg
    begin
        mem[_asm_curr_addr +: 8] <= `INCW | reg_id[2:0];
        _asm_curr_addr = _asm_curr_addr + 8;
    end
    else // 8-bit reg
    begin
        $display("ERROR: cannot INC an 8-bit register!");
        $stop;
    end
end
endtask

task DEC(input[3:0] reg_id);
begin
    if (reg_id & 'b1000) // 16-bit reg
    begin
        mem[_asm_curr_addr +: 8] <= `DECW | reg_id[2:0];
        _asm_curr_addr = _asm_curr_addr + 8;
    end
    else // 8-bit reg
    begin
        $display("ERROR: cannot DEC an 8-bit register!");
        $stop;
    end
end
endtask

// intel syntax
task MOV(input[3:0] dst_id, input[15:0] imm);
begin
    if (dst_id & 'b1000) // 16-bit reg
    begin
        mem[_asm_curr_addr +: 8] <= `MOVW | dst_id[2:0];
        mem[_asm_curr_addr + 8 +: 8] <= imm[7:0];
        mem[_asm_curr_addr + 16 +: 8] <= imm[15:8];
        _asm_curr_addr = _asm_curr_addr + 24;
    end
    else
    begin
        mem[_asm_curr_addr +: 8] <= `MOVB | dst_id[2:0];
        mem[_asm_curr_addr + 8 +: 8] <= imm[7:0];
        _asm_curr_addr = _asm_curr_addr + 16;
    end
end
endtask

// intel syntax
task MOVR(input[3:0] dst_id, input[3:0] src_id);
begin
    if ((dst_id & 'b1000) && (src_id & 'b1000))
    begin
        mem[_asm_curr_addr +: 8] <= `MOVRW;
    end
    else if ((dst_id & 'b1000) == 0 && (src_id & 'b1000) == 0)
    begin
        mem[_asm_curr_addr +: 8] <= `MOVRB;
    end
    else
    begin
        $display("ERROR: cannot MOVR an 8-bit register to a 16-bit register and vice-versa!");
        $stop;
    end
    
    mem[_asm_curr_addr + 8 +: 8] <= {2'b11, src_id[2:0], dst_id[2:0]};
    _asm_curr_addr = _asm_curr_addr + 16;
end
endtask

task MUL(input[3:0] src_id);
begin
    mem[_asm_curr_addr +: 8] <= src_id & 4'b1000 ? `MULW : `MULB;
    mem[_asm_curr_addr + 8 +: 8] <= {5'b11100, src_id[2:0]};
    _asm_curr_addr = _asm_curr_addr + 16;
end
endtask

task LOOP(input integer addr);
reg[15:0] displacement;
begin
    displacement = addr - _asm_curr_addr - 24;
    mem[_asm_curr_addr +: 8] <= `LOOP;
    mem[_asm_curr_addr + 8 +: 8] <= displacement[7:0];
    mem[_asm_curr_addr + 16 +: 8] <= displacement[15:8];
    _asm_curr_addr = _asm_curr_addr + 24;
end
endtask

task asm_wait;
integer t;
begin
    t = ((_asm_curr_addr - _asm_base_addr) / 8) * 2;
    #t;
end
endtask