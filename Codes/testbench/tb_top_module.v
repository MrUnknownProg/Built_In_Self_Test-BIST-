`timescale 1ns/1ps

module tb_top_mbist;

    reg clk_i_0;
    reg rst_i_0;
    reg start_i_0;
    reg fault_en_i_0;

    wire done_o_0;
    wire fail_flag_o_0;
    wire [7:0] fail_count_o_0;

    integer baseline_count;
    integer fault_count;
    integer remap_count;

    // ------------------------------------------------
    // DUT
    // ------------------------------------------------
    top_mbist uut (
        .clk_i_0        (clk_i_0),
        .rst_i_0        (rst_i_0),
        .start_i_0      (start_i_0),
        .fault_en_i_0   (fault_en_i_0),
        .done_o_0       (done_o_0),
        .fail_flag_o_0  (fail_flag_o_0),
        .fail_count_o_0 (fail_count_o_0)
    );

    // ------------------------------------------------
    // CLOCK
    // ------------------------------------------------
    initial begin
        clk_i_0 = 0;

        forever #5 clk_i_0 = ~clk_i_0;
    end

    // ------------------------------------------------
    // START MBIST TASK
    // ------------------------------------------------
    task run_mbist;
        begin

            // Start pulse
            @(posedge clk_i_0);
            start_i_0 = 1;

            @(posedge clk_i_0);
            start_i_0 = 0;

            // Wait for completion
            wait(done_o_0 == 1);

            // Small delay so outputs are stable
            @(posedge clk_i_0);

            $display("--------------------------------------------");
            $display("MBIST RESULT");
            $display("DONE  = %0d", done_o_0);
            $display("FAIL  = %0d", fail_flag_o_0);
            $display("COUNT = %0d", fail_count_o_0);
            $display("--------------------------------------------");

        end
    endtask


    // ------------------------------------------------
    // MAIN TEST
    // ------------------------------------------------
    initial begin

        start_i_0    = 0;
        rst_i_0      = 1;
        fault_en_i_0 = 0;

        // Reset
        repeat(2) @(posedge clk_i_0);

        rst_i_0 = 0;

        // ====================================================
        // TEST 1 : FAULT OFF
        // ====================================================

        $display("");
        $display("============================================");
        $display(" TEST 1 : FAULT OFF - BASELINE");
        $display("============================================");

        fault_en_i_0 = 0;

        run_mbist();

        baseline_count = fail_count_o_0;

        $display("");
        $display("BASELINE COUNT = %0d", baseline_count);


        // ====================================================
        // RESET
        // ====================================================

        rst_i_0 = 1;

        repeat(2) @(posedge clk_i_0);

        rst_i_0 = 0;


        // ====================================================
        // TEST 2 : FAULT ON
        // ====================================================

        $display("");
        $display("============================================");
        $display(" TEST 2 : FAULT ON");
        $display("============================================");

        fault_en_i_0 = 1;

        run_mbist();

        fault_count = fail_count_o_0;

        $display("");
        $display("FAULT COUNT = %0d", fault_count);


        if (fault_count > baseline_count)
            $display("PASS: Fault successfully detected.");
        else
            $display("FAIL: Fault was not detected.");


        // ====================================================
        // RESET
        // ====================================================

        rst_i_0 = 1;

        repeat(2) @(posedge clk_i_0);

        rst_i_0 = 0;


        // ====================================================
        // REMAPPING
        // ====================================================

        $display("");
        $display("============================================");
        $display(" REMAPPING FAULTY MEMORY");
        $display("============================================");

        // IMPORTANT:
        // This is where your DUT must perform the remapping.
        //
        // Example:
        //
        // faulty logical address -> spare physical address
        //
        // This CANNOT be achieved merely by changing
        // fault_en_i_0 in the testbench.


        // ====================================================
        // TEST 3 : FAULT OFF AFTER REMAPPING
        // ====================================================

        $display("");
        $display("============================================");
        $display(" TEST 3 : AFTER REMAPPING");
        $display("============================================");

        /*
         * For a real remapping test, the physical faulty
         * memory must still be faulty.
         *
         * The logical address should now access the spare.
         */

        fault_en_i_0 = 0;

        run_mbist();

        remap_count = fail_count_o_0;

        $display("");
        $display("REMAP COUNT = %0d", remap_count);


        // ====================================================
        // FINAL CHECK
        // ====================================================

        $display("");
        $display("============================================");
        $display(" REMAPPING VERIFICATION");
        $display("============================================");

        $display("Baseline count : %0d", baseline_count);
        $display("Fault count    : %0d", fault_count);
        $display("Remap count    : %0d", remap_count);

        if ((fault_count > baseline_count) &&
            (remap_count < fault_count)) begin

            $display("");
            $display("PASS: Fault count decreased after remapping.");
            $display("Remapping appears to be working.");

        end
        else begin

            $display("");
            $display("FAIL: Fault count did not decrease.");
            $display("Remapping is NOT verified.");

        end

        $display("");
        $display("============================================");

        #100;
        $finish;

    end

endmodule