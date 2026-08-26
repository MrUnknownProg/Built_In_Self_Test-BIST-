`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2026 10:16:15
// Design Name: 
// Module Name: LFSR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//module lfsr #(
//    parameter WIDTH = 8,
//    parameter SEED  = 8'h1
//)(
//    input  wire                 clk_i,
//    input  wire                 rst_i,
//    input  wire                 en_i,
//    output reg  [WIDTH-1:0]     data_o
//);

//    wire w_feedback;

//    // Feedback taps (simple XOR of MSB & next bit)
//    assign w_feedback = data_o[WIDTH-1] ^ data_o[WIDTH-2];

//    always @(posedge clk_i or posedge rst_i) begin
//        if (rst_i)
//            data_o <= SEED;          // Load seed
//        else if (en_i)
//            data_o <= {data_o[WIDTH-2:0], w_feedback};  // Shift + feedback
//    end

//endmodule

module lbist_misr #(
    parameter WIDTH = 32,
    parameter [WIDTH-1:0] TAPS = 8'b10111000
)(
    input  wire             clk_i,
    input  wire             rst_i,
    input  wire             en_i,

    input  wire [WIDTH-1:0] data_i,

    output reg  [WIDTH-1:0] signature_o
);

    wire w_feedback;

    assign w_feedback = ^(signature_o & TAPS);

    integer i;

    always @(posedge clk_i or posedge rst_i) begin

        if(rst_i)
            signature_o <= {WIDTH{1'b0}};

        else if(en_i) begin

            signature_o[0] <= w_feedback ^ data_i[0];

            for(i=1;i<WIDTH;i=i+1)
                signature_o[i] <= signature_o[i-1] ^ data_i[i];

        end

    end

endmodule