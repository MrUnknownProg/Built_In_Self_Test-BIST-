`timescale 1ns / 1ps

module addr_gen #(
    parameter ADDR_WIDTH = 8
)(
    input  wire                  clk_i,
    input  wire                  rst_i,

    // Address control
    input  wire                  addr_en_i,
    input  wire                  addr_rst_i,

    // Direction
    // 1'b1 = upward   : 0 -> MAX
    // 1'b0 = downward : MAX -> 0
    input  wire                  addr_dir_i,

    output reg  [ADDR_WIDTH-1:0] addr_o,
    output wire                  addr_done_o
);

    localparam [ADDR_WIDTH-1:0] MAX_ADDR =
                            {ADDR_WIDTH{1'b1}};

    // =========================================================
    // ADDRESS REGISTER
    // =========================================================

    always @(posedge clk_i) begin

        if (rst_i) begin

            addr_o <= {ADDR_WIDTH{1'b0}};

        end
        else if (addr_rst_i) begin

            // Start address depends on direction
            if (addr_dir_i)
                addr_o <= {ADDR_WIDTH{1'b0}};
            else
                addr_o <= MAX_ADDR;

        end
        else if (addr_en_i) begin

            if (addr_dir_i) begin

                // UP: 0 -> MAX
                if (addr_o != MAX_ADDR)
                    addr_o <= addr_o + 1'b1;

            end
            else begin

                // DOWN: MAX -> 0
                if (addr_o != {ADDR_WIDTH{1'b0}})
                    addr_o <= addr_o - 1'b1;

            end

        end

    end

    // =========================================================
    // END-OF-ADDRESS INDICATOR
    // =========================================================

    assign addr_done_o =
            addr_dir_i ?
            (addr_o == MAX_ADDR) :
            (addr_o == {ADDR_WIDTH{1'b0}});

endmodule