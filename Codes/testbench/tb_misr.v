`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 20:58:43
// Design Name: 
// Module Name: tb_misr
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


module tb_misr;

    parameter WIDTH = 8;
    parameter TAPS  = 8'b10111000;

    reg                 clk_i;
    reg                 rst_i;
    reg                 en_i;
    reg  [WIDTH-1:0]    data_i;
    wire [WIDTH-1:0]    signature_o;

    // DUT
    lbist_misr #(
        .WIDTH(WIDTH),
        .TAPS(TAPS)
    ) u_dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_i),
        .data_i(data_i),
        .signature_o(signature_o)
    );

    // Clock Generation
    always #5 clk_i = ~clk_i;

    integer i;

    initial begin

        $display("\n========== MISR TEST START ==========\n");

        clk_i  = 0;
        rst_i  = 1;
        en_i   = 0;
        data_i = 0;

        //-------------------------------
        // Reset Test
        //-------------------------------
        #10;
        rst_i = 0;

        #10;

        if(signature_o == 0)
            $display("PASS : Reset Successful -> %b", signature_o);
        else
            $display("FAIL : Reset Failed");

        //-------------------------------
        // Enable MISR
        //-------------------------------
        en_i = 1;

        //-------------------------------
        // Apply Test Patterns
        //-------------------------------
        for(i=0;i<10;i=i+1) begin

            data_i = $random;

            #10;

            $display("Cycle = %0d | Input = %b | Signature = %b",
                        i,
                        data_i,
                        signature_o);

        end

        //-------------------------------
        // Hold Test
        //-------------------------------
        en_i = 0;

        data_i = 8'hFF;

        #20;

        $display("\nHold Test Signature = %b", signature_o);

        //-------------------------------
        // Restart Test
        //-------------------------------
        en_i = 1;

        data_i = 8'hAA;

        #10;

        $display("Restart Signature = %b", signature_o);

        #20;

        $display("\n========== MISR TEST COMPLETE ==========");

        $finish;

    end

endmodule
