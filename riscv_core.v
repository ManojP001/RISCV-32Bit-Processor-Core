// =============================================================================
// Module: riscv_core.v
// Project: 32-Bit RISC-V CPU Core
// Description: Top-level Single-Cycle RISC-V (RV32I) Processor Core.
//              Integrates Program Counter, Instruction Memory, Register File,
//              Immediate Generator, Control Unit, and ALU.
// =============================================================================

module riscv_core (
    input  wire        clk,
    input  wire        rst_n
);

    // -------------------------------------------------------------------------
    // Internal Interconnect Wires
    // -------------------------------------------------------------------------
    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] pc_plus_4;
    wire [31:0] instruction;

    // Control signals from Brain
    wire        reg_write;
    wire        alu_src;
    wire        mem_write;
    wire        mem_to_reg;
    wire        branch;
    wire [1:0]  alu_op;

    // Register File wires
    wire [31:0] r_data1;
    wire [31:0] r_data2;
    wire [31:0] w_data;

    // Immediate and ALU wires
    wire [31:0] imm_ext;
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire        zero_flag;
    reg  [3:0]  alu_control;

    // -------------------------------------------------------------------------
    // 1. Program Counter (PC) Logic
    // -------------------------------------------------------------------------
    assign pc_plus_4 = pc + 32'd4;
    
    // For sequential execution, next_pc is PC + 4
    assign next_pc   = pc_plus_4;

    program_counter u_pc (
        .clk     (clk),
        .rst_n   (rst_n),
        .next_pc (next_pc),
        .pc      (pc)
    );

    // -------------------------------------------------------------------------
    // 2. Instruction Memory (ROM)
    // -------------------------------------------------------------------------
    instruction_memory u_imem (
        .pc          (pc),
        .instruction (instruction)
    );

    // -------------------------------------------------------------------------
    // 3. Main Control Unit (The Brain)
    // -------------------------------------------------------------------------
    control_unit u_control (
        .opcode     (instruction[6:0]),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .alu_op     (alu_op)
    );

    // -------------------------------------------------------------------------
    // 4. Register File (32x32-bit registers)
    // -------------------------------------------------------------------------
    assign w_data = alu_result; // ALU result writes directly back to registers

    register_file u_regfile (
        .clk      (clk),
        .rst_n    (rst_n),
        .w_en     (reg_write),
        .rd_addr  (instruction[11:7]),
        .w_data   (w_data),
        .rs1_addr (instruction[19:15]),
        .rs2_addr (instruction[24:20]),
        .r_data1  (r_data1),
        .r_data2  (r_data2)
    );

    // -------------------------------------------------------------------------
    // 5. Immediate Generator
    // -------------------------------------------------------------------------
    imm_gen u_imm_gen (
        .instruction (instruction),
        .imm_out     (imm_ext)
    );

    // -------------------------------------------------------------------------
    // 6. ALU Control Decoder
    // -------------------------------------------------------------------------
    always @(*) begin
        case (alu_op)
            2'b00: alu_control = 4'b0000; // ADD (for address generation)
            2'b01: alu_control = 4'b0001; // SUB (for branch equality check)
            2'b10: begin                  // R-type / I-type arithmetic
                case (instruction[14:12]) // funct3
                    3'b000: begin
                        // Distinguish ADD vs SUB using instruction[30]
                        if (instruction[6:0] == 7'b0110011 && instruction[30] == 1'b1)
                            alu_control = 4'b0001; // SUB
                        else
                            alu_control = 4'b0000; // ADD
                    end
                    3'b111: alu_control = 4'b0010; // AND
                    3'b110: alu_control = 4'b0011; // OR
                    3'b100: alu_control = 4'b0100; // XOR
                    3'b001: alu_control = 4'b0101; // SLL
                    3'b101: alu_control = 4'b0110; // SRL
                    3'b010: alu_control = 4'b0111; // SLT
                    default: alu_control = 4'b0000;
                endcase
            end
            default: alu_control = 4'b0000;
        endcase
    end

    // -------------------------------------------------------------------------
    // 7. ALU Mux & 32-Bit ALU
    // -------------------------------------------------------------------------
    // Multiplexer: Choose 2nd ALU input from Register (rs2) or Immediate!
    assign alu_input_b = (alu_src == 1'b1) ? imm_ext : r_data2;

    alu u_alu (
        .a           (r_data1),
        .b           (alu_input_b),
        .alu_control (alu_control),
        .alu_result  (alu_result),
        .zero_flag   (zero_flag)
    );

endmodule
