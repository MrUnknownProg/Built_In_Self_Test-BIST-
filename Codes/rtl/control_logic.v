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
    //
    // WRITE and READ_WAIT are now each split into a SETTLE
    // half (address held, no strobes) and a COMMIT half
    // (address still held, the actual we_o/compare_en_o
    // strobe fires, THEN addr_en_o advances for the *next*
    // address).
    //
    // This exists because repair_controller's repair-table
    // lookup is now a registered (1-cycle) read instead of a
    // combinational one (see repair_controller.v). Every
    // address needs one full settled cycle presented to
    // repair_controller before address_remapper's mux is
    // allowed to consume lookup_valid_o/lookup_phys_addr_o --
    // otherwise the mux pairs THIS cycle's logical address
    // with the PREVIOUS cycle's repair status, which is wrong
    // whenever the address changes every cycle (as WRITE did,
    // and as READ's old addr_en_o-in-READ_WAIT placement did).
    //
    // addr_en_o is deliberately placed in the COMMIT state,
    // AFTER the strobe, so the address that we_o/compare_en_o
    // actually acts on is never the one that just got
    // incremented.
    // =========================================================

    parameter IDLE         = 3'b000;
    parameter INIT         = 3'b001;
    parameter WRITE        = 3'b010; // settle: hold address, let repair lookup catch up
    parameter WRITE_COMMIT = 3'b111; // commit: we_o on the held address, then advance
    parameter READ_SETUP   = 3'b011;
    parameter READ_WAIT    = 3'b100; // settle: hold address, let repair lookup catch up
    parameter READ_COMPARE = 3'b101; // commit: compare_en_o on the held address, then advance
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
            // March write -- settle (repair lookup catches up
            // to the address that WRITE_COMMIT is about to
            // write with)
            // -------------------------------------------------

            WRITE:
                next_state = WRITE_COMMIT;


            // -------------------------------------------------
            // March write -- commit (actual we_o strobe, then
            // advance to the next address)
            // -------------------------------------------------

            WRITE_COMMIT: begin

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
            // Read -- settle (repair lookup catches up; also
            // covers the BRAM's own registered-read latency)
            // -------------------------------------------------

            READ_WAIT:
                next_state = READ_COMPARE;


            // -------------------------------------------------
            // Read -- commit (actual compare_en_o strobe, then
            // advance to the next address)
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
            // WRITE -- settle: address held, nothing strobes.
            // (defaults above already do this -- no case entry
            // needed, listed for clarity)
            // -------------------------------------------------

            WRITE: begin

                pattern_sel_o = 2'b00;
                addr_dir_o    = 1'b1;

            end


            // -------------------------------------------------
            // WRITE_COMMIT -- write the held address, then
            // advance for the next one.
            // -------------------------------------------------

            WRITE_COMMIT: begin

                we_o      = 1'b1;
                addr_en_o = 1'b1;

                pattern_sel_o = 2'b00;
                addr_dir_o    = 1'b1;

            end


            // -------------------------------------------------
            // READ SETUP
            // -------------------------------------------------

            READ_SETUP: begin

                addr_rst_o = 1'b1;

            end


            // -------------------------------------------------
            // READ -- settle: address held, nothing strobes.
            // -------------------------------------------------

            READ_WAIT: begin

                pattern_sel_o = 2'b00;
                addr_dir_o    = 1'b1;

            end


            // -------------------------------------------------
            // READ_COMPARE -- compare the held address, then
            // advance for the next one.
            // -------------------------------------------------

            READ_COMPARE: begin

                compare_en_o = 1'b1;
                addr_en_o    = 1'b1;

                pattern_sel_o = 2'b00;
                addr_dir_o    = 1'b1;

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