`timescale 1ns / 1ps

module control_logic #(
    parameter ADDR_WIDTH = 8
)(
    input wire clk_i,
    input wire rst_i,
    input wire start_i,
    input wire addr_done_i,

    output reg addr_en_o,
    output reg addr_rst_o,

    // 1 = UP
    // 0 = DOWN
    output reg addr_dir_o,

    output reg we_o,
    output reg compare_en_o,

    output reg done_o,

    output reg [1:0] pattern_sel_o
);

    // =========================================================
    // STATES
    // =========================================================

    localparam IDLE          = 5'd0;

    localparam M0_SETUP      = 5'd1;
    localparam M0_WRITE      = 5'd2;

    localparam M1_SETUP      = 5'd3;
    localparam M1_READ_REQ   = 5'd4;
    localparam M1_COMPARE    = 5'd5;
    localparam M1_WRITE      = 5'd6;

    localparam M2_SETUP      = 5'd7;
    localparam M2_READ_REQ   = 5'd8;
    localparam M2_COMPARE    = 5'd9;
    localparam M2_WRITE      = 5'd10;

    localparam M3_SETUP      = 5'd11;
    localparam M3_READ_REQ   = 5'd12;
    localparam M3_COMPARE    = 5'd13;
    localparam M3_WRITE      = 5'd14;

    localparam M4_SETUP      = 5'd15;
    localparam M4_READ_REQ   = 5'd16;
    localparam M4_COMPARE    = 5'd17;
    localparam M4_WRITE      = 5'd18;

    localparam M5_SETUP      = 5'd19;
    localparam M5_READ_REQ   = 5'd20;
    localparam M5_COMPARE    = 5'd21;

    localparam DONE          = 5'd22;

    reg [4:0] state;
    reg [4:0] next_state;

    // =========================================================
    // STATE REGISTER
    // =========================================================

    always @(posedge clk_i) begin

        if (rst_i)
            state <= IDLE;
        else
            state <= next_state;

    end

    // =========================================================
    // NEXT STATE
    // =========================================================

    always @(*) begin

        next_state = state;

        case (state)

            IDLE:
                if (start_i)
                    next_state = M0_SETUP;


            // =================================================
            // M0: ↑ W0
            // =================================================

            M0_SETUP:
                next_state = M0_WRITE;

            M0_WRITE:
                if (addr_done_i)
                    next_state = M1_SETUP;
                else
                    next_state = M0_WRITE;


            // =================================================
            // M1: ↑ R0 W1
            // =================================================

            M1_SETUP:
                next_state = M1_READ_REQ;

            M1_READ_REQ:
                next_state = M1_COMPARE;

            M1_COMPARE:
                next_state = M1_WRITE;

            M1_WRITE:
                if (addr_done_i)
                    next_state = M2_SETUP;
                else
                    next_state = M1_READ_REQ;


            // =================================================
            // M2: ↑ R1 W0
            // =================================================

            M2_SETUP:
                next_state = M2_READ_REQ;

            M2_READ_REQ:
                next_state = M2_COMPARE;

            M2_COMPARE:
                next_state = M2_WRITE;

            M2_WRITE:
                if (addr_done_i)
                    next_state = M3_SETUP;
                else
                    next_state = M2_READ_REQ;


            // =================================================
            // M3: ↓ R0 W1
            // =================================================

            M3_SETUP:
                next_state = M3_READ_REQ;

            M3_READ_REQ:
                next_state = M3_COMPARE;

            M3_COMPARE:
                next_state = M3_WRITE;

            M3_WRITE:
                if (addr_done_i)
                    next_state = M4_SETUP;
                else
                    next_state = M3_READ_REQ;


            // =================================================
            // M4: ↓ R1 W0
            // =================================================

            M4_SETUP:
                next_state = M4_READ_REQ;

            M4_READ_REQ:
                next_state = M4_COMPARE;

            M4_COMPARE:
                next_state = M4_WRITE;

            M4_WRITE:
                if (addr_done_i)
                    next_state = M5_SETUP;
                else
                    next_state = M4_READ_REQ;


            // =================================================
            // M5: ↑ R0
            // =================================================

            M5_SETUP:
                next_state = M5_READ_REQ;

            M5_READ_REQ:
                next_state = M5_COMPARE;

            M5_COMPARE:
                if (addr_done_i)
                    next_state = DONE;
                else
                    next_state = M5_READ_REQ;


            // =================================================
            // DONE
            // =================================================

            DONE:
                next_state = DONE;


            default:
                next_state = IDLE;

        endcase

    end

    // =========================================================
    // OUTPUT LOGIC
    // =========================================================

    always @(*) begin

        // Defaults
        addr_en_o     = 1'b0;
        addr_rst_o    = 1'b0;
        addr_dir_o    = 1'b1;

        we_o          = 1'b0;
        compare_en_o  = 1'b0;

        done_o        = 1'b0;

        pattern_sel_o = 2'b00;

        case (state)

            // =================================================
            // M0: ↑ W0
            // =================================================

            M0_SETUP: begin

                addr_rst_o    = 1'b1;
                addr_dir_o    = 1'b1;

                pattern_sel_o = 2'b00;

            end

            M0_WRITE: begin

                addr_dir_o    = 1'b1;
                we_o          = 1'b1;
                pattern_sel_o = 2'b00;

                if (!addr_done_i)
                    addr_en_o = 1'b1;

            end


            // =================================================
            // M1: ↑ R0 W1
            // =================================================

            M1_SETUP: begin

                addr_rst_o    = 1'b1;
                addr_dir_o    = 1'b1;

            end

            M1_READ_REQ: begin

                addr_dir_o    = 1'b1;
                pattern_sel_o = 2'b00;

            end

            M1_COMPARE: begin

                addr_dir_o    = 1'b1;
                pattern_sel_o = 2'b00;
                compare_en_o  = 1'b1;

            end

            M1_WRITE: begin

                addr_dir_o    = 1'b1;
                pattern_sel_o = 2'b01;
                we_o          = 1'b1;

                if (!addr_done_i)
                    addr_en_o = 1'b1;

            end


            // =================================================
            // M2: ↑ R1 W0
            // =================================================

            M2_SETUP: begin

                addr_rst_o    = 1'b1;
                addr_dir_o    = 1'b1;

            end

            M2_READ_REQ: begin

                addr_dir_o    = 1'b1;
                pattern_sel_o = 2'b01;

            end

            M2_COMPARE: begin

                addr_dir_o    = 1'b1;
                pattern_sel_o = 2'b01;
                compare_en_o  = 1'b1;

            end

            M2_WRITE: begin

                addr_dir_o    = 1'b1;
                pattern_sel_o = 2'b00;
                we_o          = 1'b1;

                if (!addr_done_i)
                    addr_en_o = 1'b1;

            end


            // =================================================
            // M3: ↓ R0 W1
            // =================================================

            M3_SETUP: begin

                addr_rst_o    = 1'b1;
                addr_dir_o    = 1'b0;

            end

            M3_READ_REQ: begin

                addr_dir_o    = 1'b0;
                pattern_sel_o = 2'b00;

            end

            M3_COMPARE: begin

                addr_dir_o    = 1'b0;
                pattern_sel_o = 2'b00;
                compare_en_o  = 1'b1;

            end

            M3_WRITE: begin

                addr_dir_o    = 1'b0;
                pattern_sel_o = 2'b01;
                we_o          = 1'b1;

                if (!addr_done_i)
                    addr_en_o = 1'b1;

            end


            // =================================================
            // M4: ↓ R1 W0
            // =================================================

            M4_SETUP: begin

                addr_rst_o    = 1'b1;
                addr_dir_o    = 1'b0;

            end

            M4_READ_REQ: begin

                addr_dir_o    = 1'b0;
                pattern_sel_o = 2'b01;

            end

            M4_COMPARE: begin

                addr_dir_o    = 1'b0;
                pattern_sel_o = 2'b01;
                compare_en_o  = 1'b1;

            end

            M4_WRITE: begin

                addr_dir_o    = 1'b0;
                pattern_sel_o = 2'b00;
                we_o          = 1'b1;

                if (!addr_done_i)
                    addr_en_o = 1'b1;

            end


            // =================================================
            // M5: ↑ R0
            // =================================================

            M5_SETUP: begin

                addr_rst_o    = 1'b1;
                addr_dir_o    = 1'b1;

            end

            M5_READ_REQ: begin

                addr_dir_o    = 1'b1;
                pattern_sel_o = 2'b00;

            end

            M5_COMPARE: begin

                addr_dir_o    = 1'b1;
                pattern_sel_o = 2'b00;
                compare_en_o  = 1'b1;

                if (!addr_done_i)
                    addr_en_o = 1'b1;

            end


            // =================================================
            // DONE
            // =================================================

            DONE: begin

                done_o = 1'b1;

            end

        endcase

    end

endmodule