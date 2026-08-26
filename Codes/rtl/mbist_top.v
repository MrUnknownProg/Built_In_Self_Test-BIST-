`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 21:49:35
// Design Name: 
// Module Name: mbist_top
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

module mbist_top (

    input  wire clk_i,
    input  wire rst_i,
    input  wire start_i,

    output wire done_o,
    output wire fail_flag_o
);

    // -----------------------
    // Internal signals
    // -----------------------
    wire [7:0] addr;
    wire addr_done;

    wire [7:0] data;
    wire [7:0] read_data;

    wire addr_en;
    wire addr_rst;
    wire we;
    wire compare_en;

    // -----------------------
    // Address Generator
    // -----------------------
    addr_gen addr_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .addr_en_i(addr_en),
        .addr_rst_i(addr_rst),
        .addr_o(addr),
        .addr_done_o(addr_done)
    );

    // -----------------------
    // Data Generator
    // -----------------------
    data_gen data_inst (
        .pattern_sel_i(2'b00),   // fixed pattern for now
        .addr_i(addr),
        .data_o(data)
    );

    // -----------------------
    // BRAM IP
    // -----------------------
//    blk_mem_gen_0 bram_inst (
//        .clka(clk_i),
//        .ena(1'b1),
//        .wea(we),
//        .addra(addr),
//        .dina(data),

//        .clkb(clk_i),
//        .enb(1'b1),
//        .addrb(addr),
//        .doutb(read_data)
//    );

    // -----------------------
    // Comparator
    // -----------------------
    comparator comp_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .compare_en_i(compare_en),
        .read_data_i(read_data),
        .expected_data_i(data),
        .fail_flag_o(fail_flag_o)
    );

    // -----------------------
    // FSM
    // -----------------------
    control_logic fsm_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(start_i),
        .addr_done_i(addr_done),

        .addr_en_o(addr_en),
        .addr_rst_o(addr_rst),
        .we_o(we),
        .compare_en_o(compare_en),
        .done_o(done_o)
    );

endmodule
