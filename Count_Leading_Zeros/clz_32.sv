// Author: Alex Ghandhi

/* Leading Zero Counter - 32 bit input

Inputs:
    in: 32-bit input

Outputs:
    out: 6-bit output
*/
module clz_32 (
    input  logic [31:0] in,
    output logic [ 5:0] out
);

    // Store CLZ counts for input halves
    logic [4:0] clz_high, clz_low;

    // Obtain CLZ counts
    clz_16 highCount (
        .in (in[31:16]),
        .out(clz_high)
    );
    clz_16 lowCount (
        .in (in[15:0]),
        .out(clz_low)
    );

    // Determine the output
    assign out = clz_high[4] ? {1'b0, clz_high} + {1'b0, clz_low} : {1'b0, clz_high};

endmodule  // clz_32


// Testbench
module clz_32_tb ();
    logic [31:0] in;
    logic [ 5:0] out;

    clz_32 dut (.*);

    integer i;
    initial begin
        in = 32'd0;
        #(10);
        assert (out == 6'b100000);
        $display("input %b has %d leading zeros", in, out);

        for (i = 0; i < 32; i++) begin : testCLZ_32bit
            in = 32'd1 << i;
            #(10);
            assert (out == 31 - i);
            $display("input %b has %d leading zeros", in, out);
        end

        $stop();
    end

endmodule  // clz_32_tb
