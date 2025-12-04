`timescale 1ns/1ns

module Mux32(
    input [31:0] op1,
    input [31:0] op2,
    input sel,
    output [31:0] res
);
    assign res = (sel) ? op2 : op1;

endmodule

module Mux5(
    input [4:0] op1,
    input [4:0] op2,
    input sel,
    output [4:0] res
);
    assign res = (sel) ? op2 : op1;

endmodule

