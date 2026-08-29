`timescale 1ns / 1ps

module repair_controller #(
    parameter LOGICAL_ADDR_WIDTH  = 10,
    parameter PHYSICAL_ADDR_WIDTH = 10,
    parameter SPARE_START         = 10'd256,
    parameter SPARE_END           = 10'd1023
)(
    input wire                            clk_i,
    input wire                            rst_i,

    // Fault information from comparator
    input wire                            fault_valid_i,
    input wire [LOGICAL_ADDR_WIDTH-1:0]   fault_addr_i,

    // Address currently being accessed
    input wire [LOGICAL_ADDR_WIDTH-1:0]   lookup_addr_i,

    output reg                            lookup_valid_o,
    output reg [PHYSICAL_ADDR_WIDTH-1:0]  lookup_phys_addr_o,

    output reg                            repair_full_o,
    output reg [PHYSICAL_ADDR_WIDTH-1:0]  repair_count_o
);

    localparam TABLE_DEPTH = 256;

    reg [PHYSICAL_ADDR_WIDTH-1:0]
        repair_table [0:TABLE_DEPTH-1];

    reg repair_valid [0:TABLE_DEPTH-1];

    reg [PHYSICAL_ADDR_WIDTH-1:0] next_spare_addr;

    integer i;

    always @(posedge clk_i) begin

        if (rst_i) begin

            next_spare_addr <= SPARE_START;
            repair_count_o  <= 10'd0;
            repair_full_o   <= 1'b0;

            for (i = 0; i < TABLE_DEPTH; i = i + 1) begin
                repair_valid[i] <= 1'b0;
                repair_table[i] <= 10'd0;
            end

        end

        else if (fault_valid_i) begin

            // Only original logical addresses 0-255
            // are eligible for repair.
            if (fault_addr_i < 10'd256) begin

                if (!repair_valid[fault_addr_i[7:0]]) begin

                    if (next_spare_addr <= SPARE_END) begin

                        repair_valid[fault_addr_i[7:0]] <= 1'b1;

                        repair_table[fault_addr_i[7:0]]
                            <= next_spare_addr;

                        next_spare_addr
                            <= next_spare_addr + 1'b1;

                        repair_count_o
                            <= repair_count_o + 1'b1;

                    end

                    else begin

                        repair_full_o <= 1'b1;

                    end

                end

            end

        end

    end

    always @(*) begin

        if (lookup_addr_i < 10'd256) begin

            lookup_valid_o =
                repair_valid[lookup_addr_i[7:0]];

            if (repair_valid[lookup_addr_i[7:0]]) begin

                lookup_phys_addr_o =
                    repair_table[lookup_addr_i[7:0]];

            end

            else begin

                lookup_phys_addr_o =
                    lookup_addr_i;

            end

        end

        else begin

            lookup_valid_o     = 1'b0;
            lookup_phys_addr_o = lookup_addr_i;
        end

    end

endmodule