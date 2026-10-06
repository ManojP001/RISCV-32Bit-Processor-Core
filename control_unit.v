// =============================================================================
// Module: control_unit.v
// Project: 32-Bit RISC-V CPU Core
// Description: Main Control Unit (The Brain). Decodes 7-bit opcode into control
//              signals governing register writes, memory access, multiplexers,
//              and ALU operation types.
// =============================================================================

module control_unit (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        branch,
    output reg  [1:0] alu_op
);

    always @(*) begin
        // 1. Defaults at top (Guarantees 100% Latch-Free Hardware!)
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        alu_op     = 2'b00;

        case (opcode)
            // R-Type (ADD, SUB, AND, OR, XOR, SLL, SRL, SLT)
            7'b0110011: begin
                reg_write  = 1'b1; // Write result back to register file
                alu_src    = 1'b0; // 2nd ALU input comes from Register (rs2)
                alu_op     = 2'b10; // R-type ALU operation
            end

            // I-Type (ADDI)
            7'b0010011: begin
                reg_write  = 1'b1; // Write result back to register file
                alu_src    = 1'b1; // 2nd ALU input comes from Immediate generator
                alu_op     = 2'b10; // Arithmetic ALU operation
            end

            // Load Word (LW - Read from RAM)
            7'b0000011: begin
                reg_write  = 1'b1; // Save loaded word into register file
                alu_src    = 1'b1; // Calculate RAM address: rs1 + imm
                mem_to_reg = 1'b1; // Data sent to reg file comes from RAM, not ALU!
                alu_op     = 2'b00; // ADD operation for address calculation
            end

            // Store Word (SW - Write to RAM)
            7'b0100011: begin
                alu_src    = 1'b1; // Calculate RAM address: rs1 + imm
                mem_write  = 1'b1; // Enable RAM write!
                alu_op     = 2'b00; // ADD operation for address calculation
            end

            // Branch if Equal (BEQ - Conditional Jump)
            7'b1100011: begin
                branch     = 1'b1; // Evaluate conditional branch
                alu_src    = 1'b0; // Compare rs1 and rs2 in ALU
                alu_op     = 2'b01; // Subtract in ALU to check equality
            end

            default: begin
                // Defaults already set safely at the top!
            end
        endcase
    end

endmodule
