module Testbench;
    reg clk, reset;
    wire [31:0] pc, instruction;
    wire [31:0] read_data1, read_data2, alu_result;
    wire zero;

    // Instantiate the MIPS Datapath
    MIPS_Datapath uut(.clk(clk), .reset(reset));

    // Clock generation
    initial begin
        clk = 0; forever #5 clk = ~clk; // 10 time units per clock cycle
    end

    // Test sequence
    initial begin
        // Dumpfile for waveform analysis
        $dumpfile("testbench.vcd");
        $dumpvars(0, Testbench);

        reset = 1; #10;    // Apply reset
        reset = 0;         // Release reset

        // Test case 1: ADD R3, R1, R2 (Arithmetic)
        uut.rf.registers[1] = 32'd10; // R1 = 10
        uut.rf.registers[2] = 32'd20; // R2 = 20
        // Preload memory
        uut.imem.preload(0, 8'h00);  // Initialize instruction memory
        uut.imem.preload(1, 8'h20);
        uut.imem.preload(2, 8'h10);
        uut.imem.preload(3, 8'h20);
        #20;

        // Test case 2: AND R3, R1, R2 (Logical - AND)
        uut.rf.registers[1] = 32'hFFFFFFFF; // R1 = all 1s
        uut.rf.registers[2] = 32'h0F0F0F0F; // R2 = pattern
        // Preload memory
        uut.imem.preload(4, 8'h00);  // Initialize instruction memory
        uut.imem.preload(5, 8'h20);
        uut.imem.preload(6, 8'h10);
        uut.imem.preload(7, 8'h20);
        #20;

        // Test case 3: OR R3, R1, R2 (Logical - OR)
        uut.rf.registers[1] = 32'hF0F0F0F0; // R1 = pattern
        uut.rf.registers[2] = 32'h0F0F0F0F; // R2 = inverse pattern
        // Preload memory
        uut.imem.preload(8, 8'h00);  // Initialize instruction memory
        uut.imem.preload(9, 8'h25);
        uut.imem.preload(10, 8'h10);
        uut.imem.preload(11, 8'h25);
        #20;

        // Test case 4: SLT R3, R1, R2 (Set Less Than)
        uut.rf.registers[1] = 32'd15; // R1 = 15
        uut.rf.registers[2] = 32'd20; // R2 = 20
        

        uut.imem.preload(12, 8'h00);  // Initialize instruction memory
        uut.imem.preload(13, 8'h2A);
        uut.imem.preload(14, 8'h10);
        uut.imem.preload(15, 8'h2A);
        #20;

        // Test case 5: LW R3, 4(R1) (Load)
        uut.dmem.memory[4] = 8'hA5;  // Memory content at address 4
        uut.dmem.memory[5] = 8'hA5;
        uut.dmem.memory[6] = 8'hA5;
        uut.dmem.memory[7] = 8'hA5;
        uut.rf.registers[1] = 32'd0; // Base address
        

        uut.imem.preload(16, 8'h8c);  // Initialize instruction memory
        uut.imem.preload(17, 8'h23);
        uut.imem.preload(18, 8'h00);
        uut.imem.preload(19, 8'h04);
        #20;

        // Test case 6: SW R3, 8(R2) (Store)
        uut.rf.registers[3] = 32'hDEADBEEF; // Data to store
        uut.rf.registers[2] = 32'd0; // Base address
        
        uut.imem.preload(20, 8'hAC);  // Initialize instruction memory
        uut.imem.preload(21, 8'h23);
        uut.imem.preload(22, 8'h00);
        uut.imem.preload(23, 8'h08);
        #20;

        $finish; // End simulation
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0d PC=%0d Instruction=%h", $time, uut.pc, uut.imem.memory[uut.pc >> 2]);
    end
endmodule
