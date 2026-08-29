`timescale 1ns / 1ps

module fault_inject #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10
)(
    input wire [DATA_WIDTH-1:0] data_i,
    input wire [ADDR_WIDTH-1:0] addr_i,
    input wire                  fault_en_i,

    output reg [DATA_WIDTH-1:0] data_o
);

    localparam [ADDR_WIDTH-1:0] FAULT_ADDR = 10'd10;

    always @(*) begin

        // Normal path
        data_o = data_i;

        // Inject fault
        if (fault_en_i) begin

            if (addr_i == FAULT_ADDR)
                data_o = ~data_i;

        end

    end

endmodule