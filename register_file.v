// =============================================================================
// Module: register_file.v
// Project: 32-Bit RISC-V CPU Core
// Description: Dual-read, single-write 32x32-bit Register File.
//              Register x0 is hardwired to 0x00000000 (read gives 0, writes ignored).
// =============================================================================

module register_file (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        w_en,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] w_data,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    output wire [31:0] r_data1,
    output wire [31:0] r_data2
);

    // 32 general-purpose registers, each 32 bits wide
    reg [31:0] rf [0:31];
    integer i;

    // Synchronous write port (protected against writing to x0)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                rf[i] <= 32'h00000000;
            end
        end
        else if (w_en && (rd_addr != 5'b00000)) begin
            rf[rd_addr] <= w_data;
        end
    end

    // Dual asynchronous read ports (x0 is hardwired to 0)
    assign r_data1 = (rs1_addr == 5'b00000) ? 32'h00000000 : rf[rs1_addr];
    assign r_data2 = (rs2_addr == 5'b00000) ? 32'h00000000 : rf[rs2_addr];

endmodule
