`timescale 1ns / 1ps

module comparator #(
    parameter DATA_WIDTH  = 32,
    parameter ADDR_WIDTH  = 10,
    parameter COUNT_WIDTH = 8
)(
    input wire                   clk_i,
    input wire                   rst_i,

    input wire                   compare_en_i,

    input wire [DATA_WIDTH-1:0]  read_data_i,
    input wire [DATA_WIDTH-1:0]  expected_data_i,

    input wire [ADDR_WIDTH-1:0]  addr_i,

    output reg                   fail_flag_o,
    output reg [COUNT_WIDTH-1:0] fail_count_o,

    output reg [ADDR_WIDTH-1:0]  fault_addr_o,
    output reg                   fault_addr_valid_o
);

    always @(posedge clk_i) begin

        if (rst_i) begin

            fail_flag_o         <= 1'b0;
            fail_count_o        <= {COUNT_WIDTH{1'b0}};
            fault_addr_o        <= {ADDR_WIDTH{1'b0}};
            fault_addr_valid_o  <= 1'b0;

        end

        else begin

            // Default: valid only for one clock when a
            // new fault is detected.
            fault_addr_valid_o <= 1'b0;

            if (compare_en_i) begin

                if (read_data_i != expected_data_i) begin

                    fail_flag_o <= 1'b1;

                    // Saturating counter
                    if (fail_count_o != {COUNT_WIDTH{1'b1}})
                        fail_count_o <= fail_count_o + 1'b1;

                    // Capture first failing address only
                    if (!fail_flag_o) begin

                        fault_addr_o       <= addr_i;
                        fault_addr_valid_o <= 1'b1;

                    end

                end

            end

        end

    end

endmodule