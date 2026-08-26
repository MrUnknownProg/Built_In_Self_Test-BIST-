`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 20:57:41
// Design Name: 
// Module Name: misr
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

module misr #(
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
