// =============================================================================
// Module: tb_riscv_core.v
// Project: 32-Bit RISC-V CPU Core Verification
// Description: Directed testbench pre-loading assembly instructions and verifying
//              register execution results in simulation.
// =============================================================================

`timescale 1ns / 1ps

module tb_riscv_core;

    reg clk;
    reg rst_n;

    // Instantiate the CPU Core (DUT)
    riscv_core u_dut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // 100 MHz Clock Generation (Period = 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        $display("=========================================================");
        $display("   STARTING 32-BIT RISC-V CPU SIMULATION TESTBENCH       ");
        $display("=========================================================");

        // Pre-load Machine Code into Instruction Memory:
        // Instruction 0 (PC = 0): ADDI x1, x0, 5  --> Machine code: 32'h00500093
        u_dut.u_imem.mem[0] = 32'h00500093;

        // Instruction 1 (PC = 4): ADDI x2, x0, 10 --> Machine code: 32'h00A00113
        u_dut.u_imem.mem[1] = 32'h00A00113;

        // Instruction 2 (PC = 8): ADD  x3, x1, x2 --> Machine code: 32'h002081B3
        u_dut.u_imem.mem[2] = 32'h002081B3;

        // Step 1: Apply Reset
        rst_n = 0;
        #15;
        rst_n = 1;
        $display("[%0t ns] Reset Released! CPU Begins Fetching...", $time);

        // Step 2: Let CPU execute the 3 instructions across clock cycles
        // Cycle 1: Executes ADDI x1, x0, 5
        @(posedge clk);
        #1;
        $display("[%0t ns] Executed Inst 0: PC = 0x%08h | x1 = %0d (Expected: 5)", 
                 $time, u_dut.pc, u_dut.u_regfile.rf[1]);

        // Cycle 2: Executes ADDI x2, x0, 10
        @(posedge clk);
        #1;
        $display("[%0t ns] Executed Inst 1: PC = 0x%08h | x2 = %0d (Expected: 10)", 
                 $time, u_dut.pc, u_dut.u_regfile.rf[2]);

        // Cycle 3: Executes ADD x3, x1, x2 (5 + 10)
        @(posedge clk);
        #1;
        $display("[%0t ns] Executed Inst 2: PC = 0x%08h | x3 = %0d (Expected: 15)", 
                 $time, u_dut.pc, u_dut.u_regfile.rf[3]);

        // Step 3: Self-Checking Assertion
        #10;
        $display("---------------------------------------------------------");
        if (u_dut.u_regfile.rf[3] == 32'd15) begin
            $display(">>> TEST PASSED: CPU Successfully calculated 5 + 10 = 15! <<<");
            $display(">>> All Registers, ALU, PC, and Decoder Verified!         <<<");
        end
        else begin
            $display(">>> TEST FAILED: x3 has unexpected value %0d <<<", u_dut.u_regfile.rf[3]);
        end
        $display("=========================================================");

        #20;
        $finish;
    end

endmodule
