`timescale 1ns / 1ps

module repair_controller #(
    parameter LOGICAL_ADDR_WIDTH  = 10,
    parameter PHYSICAL_ADDR_WIDTH = 10,

    // Normal memory addresses:
    // 0 to 255
    parameter TABLE_DEPTH         = 256,

    // Spare memory starts at 256
    parameter SPARE_START         = 10'd256,

    // Last physical address for 10-bit address
    parameter PHYSICAL_MAX        = 10'd1023
)(
    input wire clk_i,
    input wire rst_i,

    // ---------------------------------------------------------
    // Separate repair reset
    //
    // rst_i:
    //      resets normal MBIST-related logic
    //
    // repair_reset_i:
    //      clears repair table
    //
    // This allows MBIST to restart while retaining repairs.
    // ---------------------------------------------------------
    input wire repair_reset_i,

    // ---------------------------------------------------------
    // Fault information
    // ---------------------------------------------------------
    input wire [LOGICAL_ADDR_WIDTH-1:0] fault_addr_i,
    input wire                           fault_valid_i,

    // ---------------------------------------------------------
    // Lookup from address generator
    // ---------------------------------------------------------
    input wire [LOGICAL_ADDR_WIDTH-1:0] lookup_addr_i,

    output reg [PHYSICAL_ADDR_WIDTH-1:0] lookup_phys_addr_o,
    output reg                           lookup_valid_o,

    // ---------------------------------------------------------
    // Status
    // ---------------------------------------------------------
    output reg [9:0] repair_count_o,
    output reg        repair_full_o,

    // ---------------------------------------------------------
    // Last repair debug outputs
    // ---------------------------------------------------------
    output reg [LOGICAL_ADDR_WIDTH-1:0]
        repaired_logical_addr_o,

    output reg [PHYSICAL_ADDR_WIDTH-1:0]
        repaired_physical_addr_o,

    output reg
        repaired_valid_o
);

    // =========================================================
    // REPAIR TABLE
    //
    // Only normal logical addresses 0-255 need entries.
    //
    // Each entry stores the physical spare address.
    // =========================================================

    reg [PHYSICAL_ADDR_WIDTH-1:0]
        repair_table [0:TABLE_DEPTH-1];

    reg repair_valid [0:TABLE_DEPTH-1];


    // =========================================================
    // NEXT SPARE ADDRESS
    // =========================================================

    reg [PHYSICAL_ADDR_WIDTH-1:0]
        next_spare_addr;


    integer i;


    // =========================================================
    // REPAIR TABLE WRITE / RESET
    // =========================================================

    always @(posedge clk_i) begin

        // -----------------------------------------------------
        // Dedicated repair reset
        // -----------------------------------------------------
        //
        // This is the ONLY reset that clears the repair table.
        //
        // Therefore normal MBIST restart does not destroy
        // existing repair mappings.
        // -----------------------------------------------------

        if (repair_reset_i) begin

            next_spare_addr <= SPARE_START;

            repair_count_o  <= 10'd0;
            repair_full_o   <= 1'b0;

            repaired_logical_addr_o  <= 10'd0;
            repaired_physical_addr_o <= 10'd0;
            repaired_valid_o         <= 1'b0;

            for (i = 0; i < TABLE_DEPTH; i = i + 1) begin

                repair_table[i] <= {PHYSICAL_ADDR_WIDTH{1'b0}};
                repair_valid[i] <= 1'b0;

            end

        end

        // -----------------------------------------------------
        // Normal operation
        // -----------------------------------------------------

        else begin

            // -------------------------------------------------
            // Detect a new fault
            // -------------------------------------------------

            if (fault_valid_i) begin

                // ------------------------------------------------
                // Only normal memory addresses can be repaired.
                //
                // TABLE_DEPTH = 256
                // therefore valid fault addresses are 0-255.
                // ------------------------------------------------

                if (fault_addr_i < TABLE_DEPTH) begin

                    // --------------------------------------------
                    // Do not allocate another spare if this
                    // logical address has already been repaired.
                    // --------------------------------------------

                    if (!repair_valid[fault_addr_i]) begin

                        // ----------------------------------------
                        // Check spare capacity
                        // ----------------------------------------

                        if (!repair_full_o) begin

                            // ------------------------------------
                            // Store mapping
                            //
                            // Example:
                            //      repair_table[10] = 256
                            // ------------------------------------

                            repair_table[fault_addr_i]
                                <= next_spare_addr;

                            repair_valid[fault_addr_i]
                                <= 1'b1;


                            // ------------------------------------
                            // Debug information
                            // ------------------------------------

                            repaired_logical_addr_o
                                <= fault_addr_i;

                            repaired_physical_addr_o
                                <= next_spare_addr;

                            repaired_valid_o
                                <= 1'b1;


                            // ------------------------------------
                            // Increment repair count
                            // ------------------------------------

                            repair_count_o
                                <= repair_count_o + 10'd1;


                            // ------------------------------------
                            // Allocate next spare
                            // ------------------------------------

                            if (next_spare_addr ==
                                PHYSICAL_MAX) begin

                                repair_full_o <= 1'b1;

                            end
                            else begin

                                next_spare_addr
                                    <= next_spare_addr + 10'd1;

                            end

                        end

                    end

                end

            end

        end

    end


    // =========================================================
    // REPAIR TABLE LOOKUP
    // =========================================================
    //
    // For the current logical address:
    //
    // valid = 1:
    //      return spare address
    //
    // valid = 0:
    //      return original logical address
    //
    // The address remapper uses lookup_valid_o to decide.
    // =========================================================

    always @(*) begin

        if (lookup_addr_i < TABLE_DEPTH) begin

            lookup_valid_o =
                repair_valid[lookup_addr_i];

            lookup_phys_addr_o =
                repair_table[lookup_addr_i];

        end
        else begin

            lookup_valid_o     = 1'b0;
            lookup_phys_addr_o = lookup_addr_i;

        end

    end

endmodule