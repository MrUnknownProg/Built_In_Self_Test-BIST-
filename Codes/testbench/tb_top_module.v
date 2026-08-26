`timescale 1ns / 1ps

module tb_top_mbist;

    // =========================================================
    // DUT INPUTS
    // =========================================================
    reg clk_i_0;
    reg rst_i_0;
    reg start_i_0;
    reg fault_en_i_0;

    // =========================================================
    // DUT OUTPUTS
    // =========================================================
    wire done_o_0;
    wire [7:0] fail_count_o_0;
    wire fail_flag_o_0;

    // =========================================================
    // SAVE RESULTS FROM EACH TEST
    // =========================================================
    reg case1_fail;
    reg [7:0] case1_count;

    reg case2_fail;
    reg [7:0] case2_count;

    // =========================================================
    // DUT
    // =========================================================
    top_mbist uut (
        .clk_i_0        (clk_i_0),
        .done_o_0       (done_o_0),
        .fail_count_o_0 (fail_count_o_0),
        .fail_flag_o_0  (fail_flag_o_0),
        .fault_en_i_0   (fault_en_i_0),
        .rst_i_0        (rst_i_0),
        .start_i_0      (start_i_0)
    );

    // =========================================================
    // CLOCK
    // 10 ns period
    // =========================================================
    always #5 clk_i_0 = ~clk_i_0;

    // =========================================================
    // TIME FORMAT
    // =========================================================
    initial begin
        $timeformat(-9, 2, " ns", 10);
    end

    // =========================================================
    // MBIST RUN TASK
    // =========================================================
    task run_mbist;
    begin

        // Start pulse
        @(posedge clk_i_0);

        start_i_0 = 1'b1;

        $display("");
        $display("MBIST START");
        $display("--------------------------------------------");
        $display("INPUTS:");
        $display("  rst_i_0      = %b", rst_i_0);
        $display("  start_i_0    = %b", start_i_0);
        $display("  fault_en_i_0 = %b", fault_en_i_0);
        $display("--------------------------------------------");

        @(posedge clk_i_0);

        start_i_0 = 1'b0;

        $display("START PULSE RELEASED");
        $display("  start_i_0 = %b", start_i_0);

        // Wait until MBIST finishes
        wait(done_o_0 == 1'b1);

        @(posedge clk_i_0);

    end
    endtask

    // =========================================================
    // MAIN TEST
    // =========================================================
    initial begin

        // -----------------------------------------------------
        // INITIAL CONDITIONS
        // -----------------------------------------------------

        clk_i_0      = 1'b0;
        rst_i_0      = 1'b1;
        start_i_0    = 1'b0;
        fault_en_i_0 = 1'b0;

        case1_fail  = 1'b0;
        case1_count = 8'd0;

        case2_fail  = 1'b0;
        case2_count = 8'd0;


        // =====================================================
        // RESET
        // =====================================================

        $display("");
        $display("============================================");
        $display("             MBIST TEST START");
        $display("============================================");

        $display("");
        $display("RESET");
        $display("--------------------------------------------");
        $display("  rst_i_0      = %b", rst_i_0);
        $display("  start_i_0    = %b", start_i_0);
        $display("  fault_en_i_0 = %b", fault_en_i_0);
        $display("--------------------------------------------");

        #20;

        rst_i_0 = 1'b0;

        @(posedge clk_i_0);

        // =====================================================
        // CASE 1: NO FAULT
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display("       CASE 1: NO FAULT");
        $display("============================================");

        // Fault disabled
        fault_en_i_0 = 1'b0;

        $display("");
        $display("BEFORE MBIST");
        $display("--------------------------------------------");
        $display("INPUTS:");
        $display("  rst_i_0      = %b", rst_i_0);
        $display("  start_i_0    = %b", start_i_0);
        $display("  fault_en_i_0 = %b", fault_en_i_0);
        $display("  Fault status = DISABLED");
        $display("--------------------------------------------");

        // Run MBIST
        run_mbist();

        // -----------------------------------------------------
        // CASE 1 OUTPUT
        // -----------------------------------------------------

        $display("");
        $display("CASE 1 OUTPUT");
        $display("--------------------------------------------");
        $display("  done_o_0       = %b", done_o_0);
        $display("  fail_flag_o_0  = %b", fail_flag_o_0);
        $display("  fail_count_o_0 = %d", fail_count_o_0);
        $display("--------------------------------------------");

        // Save Case 1 result
        case1_fail  = fail_flag_o_0;
        case1_count = fail_count_o_0;

        // Check
        if ((fail_flag_o_0 == 1'b0) &&
            (fail_count_o_0 == 8'd0)) begin

            $display("RESULT: PASS");
            $display("No fault detected.");

        end
        else begin

            $display("RESULT: FAIL");
            $display("Unexpected fault detected.");

        end


        // =====================================================
        // RESET BEFORE CASE 2
        // =====================================================

        $display("");
        $display("============================================");
        $display("       RESET BEFORE CASE 2");
        $display("============================================");

        rst_i_0      = 1'b1;
        start_i_0    = 1'b0;
        fault_en_i_0 = 1'b0;

        @(posedge clk_i_0);
        @(posedge clk_i_0);

        rst_i_0 = 1'b0;

        @(posedge clk_i_0);


        // =====================================================
        // CASE 2: FAULT ENABLED
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display("       CASE 2: FAULT ENABLED");
        $display("============================================");

        // -----------------------------------------------------
        // BEFORE FAULT
        // -----------------------------------------------------

        $display("");
        $display("BEFORE FAULT ENABLE");
        $display("--------------------------------------------");
        $display("INPUTS:");
        $display("  rst_i_0      = %b", rst_i_0);
        $display("  start_i_0    = %b", start_i_0);
        $display("  fault_en_i_0 = %b", fault_en_i_0);
        $display("  Fault status = DISABLED");
        $display("--------------------------------------------");

        // -----------------------------------------------------
        // ENABLE FAULT
        // -----------------------------------------------------

        fault_en_i_0 = 1'b1;

        $display("");
        $display("FAULT ENABLED");
        $display("--------------------------------------------");
        $display("  fault_en_i_0 = %b", fault_en_i_0);
        $display("  Fault status = ENABLED");
        $display("--------------------------------------------");

        // Run MBIST
        run_mbist();

        // -----------------------------------------------------
        // CASE 2 OUTPUT
        // -----------------------------------------------------

        $display("");
        $display("CASE 2 OUTPUT");
        $display("--------------------------------------------");
        $display("  done_o_0       = %b", done_o_0);
        $display("  fail_flag_o_0  = %b", fail_flag_o_0);
        $display("  fail_count_o_0 = %d", fail_count_o_0);
        $display("--------------------------------------------");

        // Save Case 2 result
        case2_fail  = fail_flag_o_0;
        case2_count = fail_count_o_0;

        // Check
        if ((fail_flag_o_0 == 1'b1) &&
            (fail_count_o_0 > 8'd0)) begin

            $display("RESULT: PASS");
            $display("Injected fault detected correctly.");

        end
        else begin

            $display("RESULT: FAIL");
            $display("Injected fault was NOT detected.");

        end


        // =====================================================
        // FINAL SUMMARY
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display("             FINAL SUMMARY");
        $display("============================================");

        // -----------------------------------------------------
        // CASE 1 SUMMARY
        // -----------------------------------------------------

        $display("");
        $display("CASE 1: FAULT DISABLED");
        $display("--------------------------------------------");
        $display("  fail_flag  = %b", case1_fail);
        $display("  fail_count = %d", case1_count);

        if ((case1_fail == 1'b0) &&
            (case1_count == 8'd0)) begin

            $display("  STATUS     = PASS");

        end
        else begin

            $display("  STATUS     = FAIL");

        end

        // -----------------------------------------------------
        // CASE 2 SUMMARY
        // -----------------------------------------------------

        $display("");
        $display("CASE 2: FAULT ENABLED");
        $display("--------------------------------------------");
        $display("  fail_flag  = %b", case2_fail);
        $display("  fail_count = %d", case2_count);

        if ((case2_fail == 1'b1) &&
            (case2_count > 8'd0)) begin

            $display("  STATUS     = PASS");

        end
        else begin

            $display("  STATUS     = FAIL");

        end

        // -----------------------------------------------------
        // OVERALL RESULT
        // -----------------------------------------------------

        $display("");
        $display("--------------------------------------------");

        if ((case1_fail == 1'b0) &&
            (case1_count == 8'd0) &&
            (case2_fail == 1'b1) &&
            (case2_count > 8'd0)) begin

            $display("OVERALL RESULT = PASS");

        end
        else begin

            $display("OVERALL RESULT = FAIL");

        end

        $display("--------------------------------------------");

        $display("");
        $display("============================================");
        $display("          MBIST TEST COMPLETED");
        $display("============================================");
        $display("");

        #20;

        $finish;

    end

    // =========================================================
    // CONTINUOUS MONITOR
    // =========================================================

    initial begin

        $monitor(
            "TIME=%t | START=%b | DONE=%b | FAULT_EN=%b | FAIL=%b | COUNT=%0d",
            $time,
            start_i_0,
            done_o_0,
            fault_en_i_0,
            fail_flag_o_0,
            fail_count_o_0
        );

    end

    // =========================================================
    // MBIST COMPLETION TIME
    // =========================================================

    always @(posedge done_o_0) begin

        $display("");
        $display(
            ">>> MBIST COMPLETED AT TIME = %t <<<",
            $time
        );
        $display("");

    end

endmodule