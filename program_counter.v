// =============================================================================
// Module: program_counter.v
// Project: 32-Bit RISC-V CPU Core
// Description: Holds the memory address of the current instruction to execute.
//              Resets to 0x00000000 and updates to next_pc on every clock edge.
// =============================================================================

module program_counter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h00000000;
        end
        else begin
            pc <= next_pc;
        end
    end

endmodule
