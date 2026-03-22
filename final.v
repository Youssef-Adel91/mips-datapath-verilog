// ALU Module: Performs arithmetic and logical operations          
module ALU(input [31:0] a, b, input [3:0] alu_control, output reg [31:0] result, output zero);
    always @(*) begin
        case (alu_control)
            4'b0000: result = a & b; // AND
            4'b0001: result = a | b; // OR
            4'b0010: result = a + b; // ADD
            4'b0110: result = a - b; // SUB
            4'b0111: result = (a < b) ? 1 : 0; // SLT
            4'b1100: result = ~(a | b); // NOR (added)
            default: result = 0;
        endcase
    end
    assign zero = (result == 0); // Set zero flag
endmodule

// Multiplexer Module: Select between two inputs
module MUX2to1(input [31:0] input1, input2, input select, output [31:0] out);
    assign out = (select) ? input2 : input1;
endmodule

// Sign Extend Module: Extends 16-bit immediate to 32 bits
module SignExtend(input [15:0] in, output [31:0] out);
    assign out = {{16{in[15]}}, in};
endmodule

// ALU Control Decoder Module
module ALUControl(input [1:0] ALUOp, input [5:0] funct, output reg [3:0] ALUControl);
    always @(*) begin
        case(ALUOp)
            2'b00: ALUControl = 4'b0010; // ADD (lw/sw)
            2'b01: ALUControl = 4'b0110; // SUB (beq)
            2'b10: begin
                case(funct)
                    6'b100000: ALUControl = 4'b0010; // ADD
                    6'b100010: ALUControl = 4'b0110; // SUB
                    6'b100100: ALUControl = 4'b0000; // AND
                    6'b100101: ALUControl = 4'b0001; // OR
                    6'b101010: ALUControl = 4'b0111; // SLT
                    default: ALUControl = 4'b0000;
                endcase
            end
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule

// Register File Module: Simplified, no control signal
module RegisterFile(input clk,
                    input [4:0] read_reg1, read_reg2, write_reg,  // Register addresses
                    input [31:0] write_data,                     // Data to write
                    output [31:0] read_data1, read_data2);       // Data outputs
    reg [31:0] registers [0:31]; // 32 registers, 32 bits each

    // Continuous reads
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    // Unconditional write on clock rising edge
    always @(posedge clk) begin
        registers[write_reg] <= write_data;
    end
endmodule

// Data Memory Module: Simplified, with byte and halfword support
module DataMemory(input clk, input MemRead, MemWrite, ByteEnable, HalfwordEnable, WordEnable,
                  input [31:0] address, write_data, output reg [31:0] read_data);
    reg [7:0] memory [0:511]; // 512 bytes of memory

    // Memory write (always performed on rising clock edge)
    always @(posedge clk) begin
        if (MemWrite) begin
            if (WordEnable) begin
                memory[address] = write_data[31:24];
                memory[address+1] = write_data[23:16];
                memory[address+2] = write_data[15:8];
                memory[address+3] = write_data[7:0];
            end else if (HalfwordEnable) begin
                memory[address] = write_data[15:8];
                memory[address+1] = write_data[7:0];
            end else if (ByteEnable) begin
                memory[address] = write_data[7:0];
            end
        end
    end

    // Memory read (continuous)
    always @(*) begin
        if (MemRead) begin
            if (WordEnable) begin
                read_data = {memory[address], memory[address+1], memory[address+2], memory[address+3]};
            end else if (HalfwordEnable) begin
                read_data = {16'b0, memory[address], memory[address+1]};
            end else if (ByteEnable) begin
                read_data = {24'b0, memory[address]};
            end
        end else begin
            read_data = 32'b0;
        end
    end
endmodule

module InstructionMemory(input [31:0] address, output [31:0] instruction);
    reg [7:0] memory [0:127]; // 128 bytes of memory

    // Initial memory setup (example instructions already in your code)
    initial begin
        memory[0] = 8'h20; memory[1] = 8'h02; memory[2] = 8'h00; memory[3] = 8'h01; // addi $2, $0, 1
        memory[4] = 8'h20; memory[5] = 8'h03; memory[6] = 8'h00; memory[7] = 8'h02; // addi $3, $0, 2
        // Add more instructions here if necessary
    end

    // Expose memory for initialization in the testbench
    task preload(input integer index, input [7:0] value);
        memory[index] = value;
    endtask

    always @(*) begin
        instruction = {memory[address], memory[address+1], memory[address+2], memory[address+3]};
    end
endmodule


// MIPS Datapath Module
module MIPS_Datapath(input clk, reset);
    reg [31:0] pc;
    wire [31:0] next_pc, instruction, sign_ext_imm, read_data1, read_data2, alu_result, mem_data, write_data;
    wire zero;
    wire [4:0] write_reg;
    wire [3:0] alu_control;
    wire [31:0] alu_input2;
    wire reg_dst, alu_src;

    InstructionMemory imem(.address(pc), .instruction(instruction));
    RegisterFile rf(.clk(clk), .read_reg1(instruction[25:21]), .read_reg2(instruction[20:16]),
                    .write_reg(write_reg), .write_data(write_data),
                    .read_data1(read_data1), .read_data2(read_data2));
    SignExtend se(.in(instruction[15:0]), .out(sign_ext_imm));

    // New MUX and ALUControl
    MUX2to1 alu_mux(.input1(read_data2), .input2(sign_ext_imm), .select(alu_src), .out(alu_input2));
    ALUControl aluctrl(.ALUOp(2'b10), .funct(instruction[5:0]), .ALUControl(alu_control));

    ALU alu(.a(read_data1), .b(alu_input2), .alu_control(alu_control), .result(alu_result), .zero(zero));
    DataMemory dmem(.clk(clk), .MemRead(instruction[31:26] == 6'b100011), .MemWrite(instruction[31:26] == 6'b101011),
                    .ByteEnable(1'b0), .HalfwordEnable(1'b0), .WordEnable(1'b1),
                    .address(alu_result), .write_data(read_data2), .read_data(mem_data));

    assign write_reg = instruction[20:16];
    assign write_data = (instruction[31:26] == 6'b100011) ? mem_data : alu_result;

    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 0;
        else pc <= next_pc;
    end
    assign next_pc = pc + 4;
endmodule
