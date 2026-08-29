`timescale 1ns / 1ps

module tb_top_mbist;

    // =========================================================
    // INPUTS
    // =========================================================

    reg clk_i_0;
    reg rst_i_0;
    reg start_i_0;
    reg fault_en_i_0;
    reg repair_reset_i_0;


    // =========================================================
    // OUTPUTS
    // =========================================================

    wire done_o_0;

    wire [7:0] fail_count_o_0;
    wire       fail_flag_o_0;

    wire [9:0] fault_addr_o;
    wire       fault_addr_valid_o;

    wire [9:0] repair_count_o_0;
    wire       repair_full_o_0;

    wire [9:0] repaired_logical_addr_o_0;
    wire [9:0] repaired_physical_addr_o_0;
    wire       repaired_valid_o_0;


    // =========================================================
    // SAVED RESULTS
    // =========================================================

    reg [7:0] baseline_count;
    reg [7:0] fault_count;
    reg [7:0] post_repair_count;

    reg [9:0] detected_fault_addr;
    reg [9:0] repaired_logical_addr;
    reg [9:0] repaired_physical_addr;


    // =========================================================
    // DUT
    // =========================================================

    top_mbist uut
    (
        .clk_i_0
            (clk_i_0),

        .done_o_0
            (done_o_0),

        .fail_count_o_0
            (fail_count_o_0),

        .fail_flag_o_0
            (fail_flag_o_0),

        .fault_en_i_0
            (fault_en_i_0),

        .fault_addr_o
            (fault_addr_o),

        .fault_addr_valid_o
            (fault_addr_valid_o),

        .repair_count_o_0
            (repair_count_o_0),

        .repair_full_o_0
            (repair_full_o_0),

        .repair_reset_i_0
            (repair_reset_i_0),

        .repaired_logical_addr_o_0
            (repaired_logical_addr_o_0),

        .repaired_physical_addr_o_0
            (repaired_physical_addr_o_0),

        .repaired_valid_o_0
            (repaired_valid_o_0),

        .rst_i_0
            (rst_i_0),

        .start_i_0
            (start_i_0)
    );


    // =========================================================
    // CLOCK
    // =========================================================

    initial begin

        clk_i_0 = 1'b0;

        forever #5 clk_i_0 = ~clk_i_0;

    end


    // =========================================================
    // TIME FORMAT
    // =========================================================

    initial begin

        $timeformat(
            -9,
            2,
            " ns",
            12
        );

    end


    // =========================================================
    // COMPLETE RESET
    // =========================================================
    //
    // Clears both:
    // 1. MBIST
    // 2. Repair table
    //
    // Used only at beginning.
    // =========================================================

    task complete_reset;

        begin

            rst_i_0          = 1'b1;
            repair_reset_i_0 = 1'b1;
            start_i_0        = 1'b0;

            repeat(3)
                @(posedge clk_i_0);

            rst_i_0          = 1'b0;
            repair_reset_i_0 = 1'b0;

            @(posedge clk_i_0);

        end

    endtask


    // =========================================================
    // MBIST RESET ONLY
    // =========================================================
    //
    // Clears MBIST state but preserves repair table.
    // =========================================================

    task mbist_reset_only;

        begin

            rst_i_0 = 1'b1;

            repeat(2)
                @(posedge clk_i_0);

            rst_i_0 = 1'b0;

            @(posedge clk_i_0);

        end

    endtask


    // =========================================================
    // START MBIST
    // =========================================================

    task run_mbist;

        begin

            @(posedge clk_i_0);

            start_i_0 = 1'b1;

            $display("");
            $display(">>> MBIST START <<<");
            $display("TIME          = %t", $time);
            $display("FAULT_EN      = %b", fault_en_i_0);
            $display("REPAIR_RESET  = %b", repair_reset_i_0);

            @(posedge clk_i_0);

            start_i_0 = 1'b0;

            $display(">>> START RELEASED <<<");

            wait(done_o_0 == 1'b1);

            @(posedge clk_i_0);

        end

    endtask


    // =========================================================
    // PRINT MBIST RESULT
    // =========================================================

    task print_result;

        begin

            $display("");
            $display("--------------------------------------------");
            $display("              MBIST RESULT");
            $display("--------------------------------------------");

            $display("DONE             = %b",
                     done_o_0);

            $display("FAIL FLAG        = %b",
                     fail_flag_o_0);

            $display("FAIL COUNT       = %0d",
                     fail_count_o_0);

            $display("FAULT ADDRESS    = %0d",
                     fault_addr_o);

            $display("REPAIR COUNT     = %0d",
                     repair_count_o_0);

            $display("REPAIR FULL      = %b",
                     repair_full_o_0);

            $display("--------------------------------------------");

        end

    endtask


    // =========================================================
    // MAIN TEST
    // =========================================================

    initial begin

        // -----------------------------------------------------
        // Initialize
        // -----------------------------------------------------

        baseline_count       = 0;
        fault_count          = 0;
        post_repair_count    = 0;

        detected_fault_addr  = 0;

        repaired_logical_addr  = 0;
        repaired_physical_addr = 0;


        rst_i_0          = 1'b1;
        start_i_0        = 1'b0;
        fault_en_i_0     = 1'b0;
        repair_reset_i_0 = 1'b1;


        // =====================================================
        // HEADER
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display("       MBIST + MEMORY REPAIR TEST");
        $display("============================================");

        $display("");
        $display("MEMORY CONFIGURATION");
        $display("--------------------------------------------");
        $display("DATA WIDTH       = 32 bits");
        $display("ADDRESS WIDTH    = 10 bits");
        $display("TOTAL PHYSICAL   = 1024");
        $display("NORMAL MEMORY    = 0 - 255");
        $display("SPARE MEMORY     = 256 - 1023");
        $display("SPARE LOCATIONS  = 768");
        $display("--------------------------------------------");


        // =====================================================
        // COMPLETE RESET
        // =====================================================

        complete_reset;


        // =====================================================
        // TEST 1
        // BASELINE
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display(" TEST 1 : BASELINE / FAULT OFF");
        $display("============================================");

        fault_en_i_0 = 1'b0;

        $display("");
        $display("INPUTS");
        $display("--------------------------------------------");
        $display("RST          = %b", rst_i_0);
        $display("START        = %b", start_i_0);
        $display("FAULT_EN     = %b", fault_en_i_0);
        $display("REPAIR_RESET = %b", repair_reset_i_0);
        $display("--------------------------------------------");

        run_mbist;

        print_result;

        baseline_count = fail_count_o_0;


        if ((fail_flag_o_0 == 1'b0) &&
            (fail_count_o_0 == 0)) begin

            $display("TEST 1 STATUS = PASS");

        end
        else begin

            $display("TEST 1 STATUS = FAIL");

        end


        // =====================================================
        // TEST 2
        // FAULT DETECTION
        // =====================================================

        mbist_reset_only;

        fault_en_i_0 = 1'b1;


        $display("");
        $display("");
        $display("============================================");
        $display(" TEST 2 : FAULT ON / DETECTION");
        $display("============================================");

        $display("");
        $display("INPUTS");
        $display("--------------------------------------------");
        $display("FAULT_EN     = %b", fault_en_i_0);
        $display("REPAIR_RESET = %b", repair_reset_i_0);
        $display("EXPECTED FAULT ADDRESS = 10");
        $display("--------------------------------------------");


        run_mbist;

        print_result;

        fault_count = fail_count_o_0;


        if ((fail_flag_o_0 == 1'b1) &&
            (fail_count_o_0 > 0)) begin

            $display("TEST 2 STATUS = PASS");
            $display("Fault successfully detected.");

        end
        else begin

            $display("TEST 2 STATUS = FAIL");
            $display("Fault was not detected.");

        end


        // =====================================================
        // TEST 3
        // FAULT LOCATION
        // =====================================================

        detected_fault_addr = fault_addr_o;


        $display("");
        $display("");
        $display("============================================");
        $display(" TEST 3 : FAULT LOCATION IDENTIFICATION");
        $display("============================================");

        $display("");
        $display("EXPECTED FAULT ADDRESS = 10");
        $display("DETECTED FAULT ADDRESS = %0d",
                 detected_fault_addr);


        if (detected_fault_addr == 10) begin

            $display("TEST 3 STATUS = PASS");
            $display("Correct faulty location identified.");

        end
        else begin

            $display("TEST 3 STATUS = FAIL");

        end


        // =====================================================
        // TEST 4
        // REPAIR ALLOCATION
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display(" TEST 4 : REPAIR ALLOCATION");
        $display("============================================");

        // Wait for repair controller output
        repeat(2)
            @(posedge clk_i_0);


        $display("");
        $display("REPAIR INFORMATION");
        $display("--------------------------------------------");

        $display("REPAIR COUNT       = %0d",
                 repair_count_o_0);

        $display("REPAIR FULL        = %b",
                 repair_full_o_0);

        $display("REPAIRED VALID     = %b",
                 repaired_valid_o_0);

        $display("REPAIRED LOGICAL   = %0d",
                 repaired_logical_addr_o_0);

        $display("REPAIRED PHYSICAL  = %0d",
                 repaired_physical_addr_o_0);

        $display("--------------------------------------------");


        repaired_logical_addr =
            repaired_logical_addr_o_0;

        repaired_physical_addr =
            repaired_physical_addr_o_0;


        if ((repair_count_o_0 == 1) &&
            (repaired_valid_o_0 == 1'b1) &&
            (repaired_logical_addr_o_0 == 10) &&
            (repaired_physical_addr_o_0 == 256)) begin

            $display("TEST 4 STATUS = PASS");
            $display("");
            $display("Repair mapping:");
            $display("Logical 10 -> Physical 256");

        end
        else begin

            $display("TEST 4 STATUS = FAIL");

        end


        // =====================================================
        // TEST 5
        // VERIFY REPAIR INFORMATION
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display(" TEST 5 : REPAIR VERIFICATION");
        $display("============================================");

        $display("");
        $display("REPAIRED VALID     = %b",
                 repaired_valid_o_0);

        $display("LOGICAL ADDRESS    = %0d",
                 repaired_logical_addr_o_0);

        $display("PHYSICAL ADDRESS   = %0d",
                 repaired_physical_addr_o_0);

        $display("REPAIR COUNT       = %0d",
                 repair_count_o_0);

        $display("--------------------------------------------");


        if ((repaired_valid_o_0 == 1'b1) &&
            (repaired_logical_addr_o_0 == 10) &&
            (repaired_physical_addr_o_0 == 256)) begin

            $display("TEST 5 STATUS = PASS");
            $display("10 -> 256 repair mapping confirmed.");

        end
        else begin

            $display("TEST 5 STATUS = FAIL");

        end


        // =====================================================
        // TEST 6
        // MBIST RESET WITHOUT REPAIR RESET
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display(" TEST 6 : REPAIR RETENTION");
        $display("============================================");

        $display("");
        $display("Resetting MBIST...");
        $display("Repair reset remains LOW.");
        $display("Therefore repair must remain active.");
        $display("");


        mbist_reset_only;


        $display("AFTER MBIST RESET");
        $display("--------------------------------------------");

        $display("REPAIR COUNT      = %0d",
                 repair_count_o_0);

        $display("REPAIRED VALID    = %b",
                 repaired_valid_o_0);

        $display("REPAIRED LOGICAL  = %0d",
                 repaired_logical_addr_o_0);

        $display("REPAIRED PHYSICAL = %0d",
                 repaired_physical_addr_o_0);

        $display("--------------------------------------------");


        if ((repair_count_o_0 == 1) &&
            (repaired_valid_o_0 == 1'b1) &&
            (repaired_logical_addr_o_0 == 10) &&
            (repaired_physical_addr_o_0 == 256)) begin

            $display("TEST 6 STATUS = PASS");
            $display("Repair information survived MBIST reset.");

        end
        else begin

            $display("TEST 6 STATUS = FAIL");
            $display("Repair information was lost.");

        end


        // =====================================================
        // TEST 7
        // POST-REPAIR MBIST
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display(" TEST 7 : POST-REPAIR MBIST");
        $display("============================================");

        $display("");
        $display("IMPORTANT TEST CONDITION");
        $display("--------------------------------------------");
        $display("FAULT_EN     = 1");
        $display("REPAIR_RESET = 0");
        $display("Repair mapping retained.");
        $display("--------------------------------------------");

        $display("");
        $display("Expected:");
        $display("Logical address 10");
        $display("        |");
        $display("        v");
        $display("Physical address 256");
        $display("");
        $display("The physical faulty address 10 should");
        $display("therefore be bypassed.");
        $display("");


        run_mbist;

        print_result;


        post_repair_count =
            fail_count_o_0;


        // =====================================================
        // FINAL TEST RESULT
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display(" TEST 8 : FINAL REPAIR VERIFICATION");
        $display("============================================");

        $display("");
        $display("BEFORE REPAIR");
        $display("--------------------------------------------");
        $display("FAIL COUNT      = %0d",
                 fault_count);

        $display("FAULT ADDRESS   = %0d",
                 detected_fault_addr);

        $display("--------------------------------------------");


        $display("");
        $display("REPAIR");
        $display("--------------------------------------------");

        $display("LOGICAL ADDRESS = %0d",
                 repaired_logical_addr);

        $display("PHYSICAL ADDRESS= %0d",
                 repaired_physical_addr);

        $display("--------------------------------------------");


        $display("");
        $display("AFTER REPAIR");
        $display("--------------------------------------------");

        $display("FAIL COUNT      = %0d",
                 post_repair_count);

        $display("FAIL FLAG       = %b",
                 fail_flag_o_0);

        $display("--------------------------------------------");


        if ((fault_count > 0) &&
            (detected_fault_addr == 10) &&
            (repaired_logical_addr == 10) &&
            (repaired_physical_addr == 256) &&
            (post_repair_count == 0) &&
            (fail_flag_o_0 == 1'b0)) begin

            $display("");
            $display("============================================");
            $display("      POST-REPAIR MBIST = PASS");
            $display("============================================");

            $display("");
            $display("Fault was detected at address 10.");
            $display("Address 10 was remapped to spare 256.");
            $display("Repair survived MBIST reset.");
            $display("Fault remained enabled.");
            $display("Post-repair FAIL COUNT = 0.");
            $display("");
            $display("FAULTY MEMORY LOCATION SUCCESSFULLY");
            $display("BYPASSED.");
            $display("");

        end
        else begin

            $display("");
            $display("============================================");
            $display("      POST-REPAIR MBIST = FAIL");
            $display("============================================");

            $display("");
            $display("Expected:");
            $display("Initial fail count > 0");
            $display("Fault address      = 10");
            $display("Spare address      = 256");
            $display("Final fail count   = 0");
            $display("");

        end


        // =====================================================
        // FINAL SUMMARY
        // =====================================================

        $display("");
        $display("");
        $display("============================================");
        $display("              FINAL SUMMARY");
        $display("============================================");

        $display("");
        $display("BASELINE");
        $display("  Fail Count = %0d",
                 baseline_count);

        $display("");
        $display("FAULT DETECTION");
        $display("  Fail Count = %0d",
                 fault_count);

        $display("  Fault Address = %0d",
                 detected_fault_addr);

        $display("");
        $display("REPAIR");
        $display("  Logical Address = %0d",
                 repaired_logical_addr);

        $display("  Physical Address = %0d",
                 repaired_physical_addr);

        $display("  Repair Count = %0d",
                 repair_count_o_0);

        $display("");
        $display("POST-REPAIR MBIST");
        $display("  Fail Count = %0d",
                 post_repair_count);

        $display("  Fail Flag = %b",
                 fail_flag_o_0);

        $display("");
        $display("============================================");


        #100;

        $finish;

    end


    // =========================================================
    // FAULT EVENT MONITOR
    // =========================================================

    always @(posedge fault_addr_valid_o) begin

        $display("");
        $display("********************************************");
        $display("          FAULT DETECTION EVENT");
        $display("********************************************");

        $display("TIME          = %t",
                 $time);

        $display("FAULT ADDRESS = %0d",
                 fault_addr_o);

        $display("FAIL COUNT    = %0d",
                 fail_count_o_0);

        $display("********************************************");
        $display("");

    end


    // =========================================================
    // REPAIR ALLOCATION EVENT
    // =========================================================

    always @(posedge repaired_valid_o_0) begin

        $display("");
        $display("********************************************");
        $display("          REPAIR ALLOCATION EVENT");
        $display("********************************************");

        $display("TIME              = %t",
                 $time);

        $display("LOGICAL ADDRESS   = %0d",
                 repaired_logical_addr_o_0);

        $display("PHYSICAL ADDRESS  = %0d",
                 repaired_physical_addr_o_0);

        $display("REPAIR COUNT      = %0d",
                 repair_count_o_0);

        $display("********************************************");
        $display("");

    end


    // =========================================================
    // MBIST DONE EVENT
    // =========================================================

    always @(posedge done_o_0) begin

        $display("");
        $display(">>> MBIST COMPLETED <<<");

        $display("TIME       = %t",
                 $time);

        $display("FAIL FLAG  = %b",
                 fail_flag_o_0);

        $display("FAIL COUNT = %0d",
                 fail_count_o_0);

        $display("");

    end

endmodule