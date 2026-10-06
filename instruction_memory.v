// =============================================================================
// Module: instruction_memory.v
// Project: 32-Bit RISC-V CPU Core
// Description: ROM block holding program machine code.
//              Takes byte address from PC and outputs 32-bit instruction word.
// =============================================================================

module instruction_memory (
    input  wire [31:0] pc,
    output wire [31:0] instruction
);

    // 64 instructions of program storage space (32-bit words)
    reg [31:0] mem [0:63];

    // Word-aligned read: drops the lowest 2 byte-offset bits pc[1:0]
    assign instruction = mem[pc[7:2]];

endmodule
