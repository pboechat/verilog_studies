// opcodes
`define ADDB 8'b00000100        // ADD immediate (byte) to AL
`define ADDW 8'b00000101        // ADD immediate (word) to AX
`define ORB  8'b00001100        // OR AL with immediate (byte)
`define ORW  8'b00001101        // OR AX with immediate (word)
`define ANDB 8'b00100100        // AND AL with immediate (byte)
`define ANDW 8'b00100101        // AND AX with immediate (word)
`define SUBB 8'b00101100        // SUBtract immediate (byte) from AL
`define SUBW 8'b00101101        // SUBtract immediate (word) from AX
`define XORB 8'b00110100        // XOR AL with immediate (byte)
`define XORW 8'b00110101        // XOR AX with immediate (word)
`define INC  8'b01000000        // INCrement AX by one
`define DEC  8'b01001000        // DECrement AX by one
`define HLT  8'b11110100        // HaLT the CPU execution
`define IN   8'b11101100        // read from the data INput channel to AX
`define INT  8'b11001100        // raise a software INTerrupt
`define IRET 8'b11001111        // RETurn from an Interrupt handler
`define NOP  8'b10010000        // No-OP
`define CBW  8'b10011000        // Convert accumulator from Byte to Word by filling AH with the sign bit of AL
`define OUT  8'b11101110        // write AL to the data OUTput channel
// registers
`define AX reg_file[0]          // Accumulator eXtended register
`define AL reg_file[0][7:0]     // Accumulator register Low-byte
`define AH reg_file[0][15:8]    // Accumulator register High-byte
// memory system
`define MEM_START 8'h00         // MEMory START (address 0)
`define UII 8'h10               // Undefined Instruction Interrupt
`define PROG_START 8'h30        // PROGram START