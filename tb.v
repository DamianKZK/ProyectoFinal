`timescale 1ns/1ns

module tb();

    reg clk;

    wire[31:0] pcOut;
    wire[31:0] pcIn;
    wire[31:0] instruction;
    wire[4:0] writeRegister;

    wire c_regDst, c_branch, c_memRead, c_memtoReg, c_memWrite, c_aluSrc, c_regWrite, c_jump;
    wire [2:0] aluOp;

    wire zeroFlag;
    wire[31:0] aluZeroRes;

    wire[31:0] bank_writeData;
    wire[31:0] bank_dataOut1;
    wire[31:0] bank_dataOut2;
    wire[31:0] imm32;
    wire[31:0] adderRes;
    wire[31:0] adderIn;
    wire[31:0] jumpRes;
    wire[31:0] aluZeroOp1;
    wire[31:0] memDataOut;
    wire[2:0] aluSelector;

    // --- Cables de Decodificación (Slicing) ---
    wire [5:0]  opcode = instruction[31:26];
    wire [4:0]  rs     = instruction[25:21];
    wire [4:0]  rt     = instruction[20:16];
    wire [4:0]  rd     = instruction[15:11];
    wire [15:0] imm    = instruction[15:0];
    wire [5:0]  funct  = instruction[5:0];
    wire [25:0] target = instruction[25:0]; // Target Address para Jump

    initial begin
        clk <= 1'b0;
    end

    programCounter pc(
        .clk(clk),
        .pcIn(pcIn),
        .pcOut(pcOut)
    );

    adder add(
        .op1(32'd4),
        .op2(pcOut),
        .result(adderRes)
    );

    instructionMemory instMem(
        .address(pcOut),
        .instruction(instruction)
    );

    Mux5 rtOrRd(
        .op1(rt),
        .op2(rd),
        .sel(c_regDst),
        .res(writeRegister)
    );


    Control control(
        .opCode(opcode),
        .regDst(c_regDst), 
        .branch(c_branch), 
        .memRead(c_memRead), 
        .memtoReg(c_memtoReg), 
        .aluOp(aluOp),
        .memWrite(c_memWrite), 
        .aluSrc(c_aluSrc),
        .regWrite(c_regWrite), 
        .jump(c_jump)
    );

    registerBank regBank(
        .clk(clk),
        .readReg1(rs),
        .readReg2(rt),
        .writeReg(writeRegister),
        .writeData(bank_writeData),
        .regWrite(c_regWrite),
        .readData1(bank_dataOut1),
        .readData2(bank_dataOut2)
    );

    signExtend snExtend(
        .inInm(imm),
        .outInm(imm32)
    );

    shiftLeft2 shLeft(
        .inData(imm32),
        .outData(adderIn)
    );

    adder addJump(
        .op1(adderRes),
        .op2(adderIn),
        .result(jumpRes)
    );

    Mux32 sgnExtendOrReadData2(
        .op1(bank_dataOut2),
        .op2(imm32),
        .sel(c_aluSrc),
        .res(aluZeroOp1)
    );

    AluControl aluCtrl(
        .funct(funct),
        .aluOP(aluOp),
        .aluSel(aluSelector)
    );    

    ALUZeroFlag alu(
        .a(aluZeroOp1),
        .b(bank_dataOut1),
        .sel(aluSelector),
        .out(aluZeroRes),
        .zeroFlag(zeroFlag)
    );

    RAM memory(
        .memRead(c_memRead),
        .memWrite(c_memWrite),
        .addrIn(aluZeroRes),
        .dataIn(bank_dataOut2),
        .dataOut(memDataOut)
    );

    Mux32 memDataOrAluResult(
        .op1(aluZeroRes),
        .op2(memDataOut),
        .sel(c_memtoReg),
        .res(bank_writeData)
    );

    assign jumpMuxSelector = c_branch & zeroFlag;

    Mux32 jumpMux(
        .op1(adderRes),
        .op2(jumpRes),
        .sel(jumpMuxSelector),
        .res(pcIn)
    );

    always #50 clk = ~clk;

endmodule