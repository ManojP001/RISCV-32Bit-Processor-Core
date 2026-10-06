// =============================================================================
// Module: imm_gen.v
// Project: 32-Bit RISC-V CPU Core
// Description: Extracts immediate fields from the instruction and performs
//              sign-extension to 32 bits for I-type, S-type, and B-type formats.
// =============================================================================

module imm_gen (
    input  wire [31:0] instruction,
    output reg  [31:0] imm_out
);

    wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        imm_out = 32'h00000000; // Default: latch prevention

        case (opcode)
            // I-Type: Arithmetic with immediate (ADDI) and Load (LW)
            7'b0010011, 7'b0000011: begin
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-Type: Store Word (SW)
            7'b0100011: begin
                imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-Type: Conditional Branch (BEQ)
            7'b1100011: begin
                imm_out = {{19{instruction[31]}}, instruction[31], instruction[7], 
                           instruction[30:25], instruction[11:8], 1'b0};
            end

            default: begin
                imm_out = 32'h00000000;
            end
        endcase
    end

endmodule
