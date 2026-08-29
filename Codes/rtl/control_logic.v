`timescale 1ns / 1ps

module control_logic #(
    parameter ADDR_WIDTH = 10
)(
    input wire clk_i,
    input wire rst_i,

    input wire start_i,
    input wire addr_done_i,

    output reg addr_en_o,
    output reg addr_rst_o,
    output reg we_o,
    output reg compare_en_o,
    output reg done_o,

    // ---------------------------------------------------------
    // March pattern selection
    // ---------------------------------------------------------
    output reg [1:0] pattern_sel_o,

    // ---------------------------------------------------------
    // Address direction
    //
    // 1 = upward
    // 0 = downward
    // ---------------------------------------------------------
    output reg addr_dir_o
);

    // =========================================================
    // STATES
    // =========================================================

    parameter IDLE         = 3'b000;
    parameter INIT         = 3'b001;
    parameter WRITE        = 3'b010;
    parameter READ_SETUP   = 3'b011;
    parameter READ_WAIT    = 3'b100;
    parameter READ_COMPARE = 3'b101;
    parameter DONE         = 3'b110;

    reg [2:0] state;
    reg [2:0] next_state;


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
    // NEXT STATE LOGIC
    // =========================================================

    always @(*) begin

        next_state = state;

        case (state)

            // -------------------------------------------------
            // Wait for MBIST start
            // -------------------------------------------------

            IDLE: begin

                if (start_i)
                    next_state = INIT;
                else
                    next_state = IDLE;

            end


            // -------------------------------------------------
            // Initialize address generator
            // -------------------------------------------------

            INIT:
                next_state = WRITE;


            // -------------------------------------------------
            // March write
            // -------------------------------------------------

            WRITE: begin

                if (addr_done_i)
                    next_state = READ_SETUP;
                else
                    next_state = WRITE;

            end


            // -------------------------------------------------
            // Setup read
            // -------------------------------------------------

            READ_SETUP:
                next_state = READ_WAIT;


            // -------------------------------------------------
            // BRAM read latency
            // -------------------------------------------------

            READ_WAIT:
                next_state = READ_COMPARE;


            // -------------------------------------------------
            // Compare read data
            // -------------------------------------------------

            READ_COMPARE: begin

                if (addr_done_i)
                    next_state = DONE;
                else
                    next_state = READ_WAIT;

            end


            // -------------------------------------------------
            // IMPORTANT:
            //
            // DONE now accepts another START.
            //
            // This allows MBIST to run again after repair.
            // -------------------------------------------------

            DONE: begin

                if (start_i)
                    next_state = INIT;
                else
                    next_state = DONE;

            end


            default:
                next_state = IDLE;

        endcase

    end


    // =========================================================
    // OUTPUT LOGIC
    // =========================================================

    always @(*) begin

        // -----------------------------------------------------
        // Defaults
        // -----------------------------------------------------

        addr_en_o     = 1'b0;
        addr_rst_o    = 1'b0;
        we_o          = 1'b0;
        compare_en_o  = 1'b0;
        done_o        = 1'b0;

        pattern_sel_o = 2'b00;
        addr_dir_o    = 1'b1;


        case (state)

            // -------------------------------------------------
            // INIT
            // -------------------------------------------------

            INIT: begin

                addr_rst_o = 1'b1;

            end


            // -------------------------------------------------
            // WRITE
            // -------------------------------------------------

            WRITE: begin

                addr_en_o = 1'b1;
                we_o      = 1'b1;

                pattern_sel_o = 2'b00;

                addr_dir_o = 1'b1;

            end


            // -------------------------------------------------
            // READ SETUP
            // -------------------------------------------------

            READ_SETUP: begin

                addr_rst_o = 1'b1;

            end


            // -------------------------------------------------
            // READ
            // -------------------------------------------------

            READ_WAIT: begin

                addr_en_o = 1'b1;

                pattern_sel_o = 2'b00;

                addr_dir_o = 1'b1;

            end


            // -------------------------------------------------
            // COMPARE
            // -------------------------------------------------

            READ_COMPARE: begin

                compare_en_o = 1'b1;

                pattern_sel_o = 2'b00;

                addr_dir_o = 1'b1;

            end


            // -------------------------------------------------
            // DONE
            // -------------------------------------------------

            DONE: begin

                done_o = 1'b1;

            end

        endcase

    end

endmodule