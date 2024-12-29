// opcodes
`define ADDB        8'b00000100        // ADD immediate (Byte) to AL
`define ADDW        8'b00000101        // ADD immediate (Word) to AX
`define ORB         8'b00001100        // OR AL with immediate (Byte)
`define ORW         8'b00001101        // OR AX with immediate (Word)
`define ANDB        8'b00100100        // AND AL with immediate (Byte)
`define ANDW        8'b00100101        // AND AX with immediate (Word)
`define SUBB        8'b00101100        // SUBtract immediate (Byte) from AL
`define SUBW        8'b00101101        // SUBtract immediate (Word) from AX
`define XORB        8'b00110100        // XOR AL with immediate (Byte)
`define XORW        8'b00110101        // XOR AX with immediate (Word)
`define INCW        8'b01000000        // INCrement [base]
`define INCW_PFX    8'b01000???        // INCrement (???) by one
`define DECW        8'b01001000        // DECrement [base]
`define DECW_PFX    8'b01001???        // DECrement (???) by one
`define MOVRB       8'b10001000        // MOVe Regiter-to-register or register-to-memory (Byte)
`define MOVRW       8'b10001001        // MOVe Regiter-to-register or register-to-memory (Word)
`define NOP         8'b10010000        // No-OP
`define CBW         8'b10011000        // Convert accumulator from Byte to Word by filling AH with the sign bit of AL
`define MOVB        8'b10110000        // MOVe immediate (byte) [base]
`define MOVB_PFX    8'b10110???        // MOVe immediate (byte) to (???)
`define MOVW        8'b10111000        // MOVe immediate (word) [base]
`define MOVW_PFX    8'b10111???        // MOVe immediate (word) to (???)
`define INT         8'b11001100        // raise a software INTerrupt
`define IRET        8'b11001111        // RETurn from an Interrupt handler
`define LOOP        8'b11100010        // LOOP to IP address displacement (immediate) till CX is zero
`define IN          8'b11101100        // read from the data INput channel to AL
`define OUT         8'b11101110        // write AL to the data OUTput channel
`define HLT         8'b11110100        // HaLT the CPU execution
`define MULB        8'b11110110        // MULtiply AL with another register and store result in AX (Byte)
`define MULW        8'b11110111        // MULtiply AX with another register and store result in DX (high-word) and AX (low-word) (Word)
// 16-bit register IDs
`define AX_ID       3'b000              // AX ID
`define CX_ID       3'b001              // CX ID
`define DX_ID       3'b010              // DX ID
`define BX_ID       3'b011              // BX ID
`define SP_ID       3'b100              // SP ID
`define BP_ID       3'b101              // BP ID
`define SI_ID       3'b110              // SI ID
`define DI_ID       3'b111              // DI ID
// 8-bit register IDs
`define AL_ID       3'b000              // AL ID
`define CL_ID       3'b001              // CL ID
`define DL_ID       3'b010              // DL ID
`define BL_ID       3'b011              // BL ID
`define AH_ID       3'b100              // AH ID
`define CH_ID       3'b101              // CH ID
`define DH_ID       3'b110              // DH ID
`define BH_ID       3'b111              // BH ID
// register file aliases
`define AX reg_file[3'b000]             // Accumulator register
`define AL reg_file[3'b000][7:0]        // Accumulator register Low-byte
`define AH reg_file[3'b000][15:8]       // Accumulator register High-byte
`define CX reg_file[3'b001]             // Count register
`define CL reg_file[3'b001][7:0]        // Count register Low-byte
`define CH reg_file[3'b001][15:8]       // Count register High-byte
`define DX reg_file[3'b010]             // Data register
`define DL reg_file[3'b010][7:0]        // Data register Low-byte
`define DH reg_file[3'b010][15:8]       // Data register High-byte
`define BX reg_file[3'b011]             // Base register
`define BL reg_file[3'b011][7:0]        // Base register Low-byte
`define BH reg_file[3'b011][15:8]       // Base register High-byte
`define SP reg_file[3'b100]             // Stack Pointer register
`define BP reg_file[3'b101]             // Base Pointer register
`define SI reg_file[3'b110]             // Source Index register
`define DI reg_file[3'b111]             // Destination Index register
// memory system key addresses
`define MEM_START   16'h0000            // MEMory START (address 0)
`define UII         16'h0010            // Undefined Instruction Interrupt
`define PROG_START  16'h0030            // PROGram START