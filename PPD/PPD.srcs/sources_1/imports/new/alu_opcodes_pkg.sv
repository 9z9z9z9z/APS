`timescale 1ns / 1ps

package alu_opcodes_pkg;
//RESULTS
    parameter ALU_ADD  = 5'b00000; // +
    parameter ALU_SUB  = 5'b01000; // -
    parameter ALU_SLL  = 5'b00001; // <<
    parameter ALU_SLTS = 5'b00010; // < (signed)
    parameter ALU_SLTU = 5'b00011; // < (unsigned)
    parameter ALU_XOR = 5'b00100; // XOR
    parameter ALU_SRL  = 5'b00101; // >>
    parameter ALU_SRA  = 5'b01101; // >>>
    parameter ALU_OR  = 5'b00110; // OR
    parameter ALU_AND = 5'b00111; // AND
// FLAGS
    parameter ALU_EQ   = 5'b11000; // ==
    parameter ALU_NE   = 5'b11001; // !=
    parameter ALU_LTS  = 5'b11100; // >
    parameter ALU_GES  = 5'b11101; // >=
    parameter ALU_LTU  = 5'b11110; // <
    parameter ALU_GEU  = 5'b11111; // <=
endpackage
