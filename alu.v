// =============================================================================
// Module: alu.v
// Project: 32-Bit RISC-V CPU Core
// Description: 32-bit Arithmetic Logic Unit supporting arithmetic, logical,
//              shift, and comparison operations. Generates zero_flag for branches.
// =============================================================================

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_control,
    output reg  [31:0] alu_result,
    output wire        zero_flag
);

    always @(*) begin
        alu_result = 32'h00000000; // Default: latch prevention

        case (alu_control)
            4'b0000: alu_result = a + b;                        // ADD
            4'b0001: alu_result = a - b;                        // SUB
            4'b0010: alu_result = a & b;                        // AND
            4'b0011: alu_result = a | b;                        // OR
            4'b0100: alu_result = a ^ b;                        // XOR
            4'b0101: alu_result = a << b[4:0];                  // SLL (Shift Left Logical)
            4'b0110: alu_result = a >> b[4:0];                  // SRL (Shift Right Logical)
            4'b0111: alu_result = (a < b) ? 32'd1 : 32'd0;      // SLT (Set Less Than)
            default: alu_result = 32'h00000000;
        endcase
    end

    // Zero flag used for conditional branches (e.g. BEQ)
    assign zero_flag = (alu_result == 32'h00000000);

endmodule
