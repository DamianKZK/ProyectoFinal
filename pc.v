`timescale 1ns/1ns

module programCounter(
        input clk,
        input reg[31:0] pcIn,
        output reg[31:0] pcOut
    );
    
    initial begin
        pcOut = 32'b0;
    end

    always@(posedge clk) begin
        pcOut = pcIn;
    end

endmodule