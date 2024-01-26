// Author: Alex Ghandhi

/* Leading Zero Counter - 64 bit input

Inputs:
    in: 64-bit input

Outputs:
    out: 7-bit output
*/
module clz_64 (
    input  logic [63:0] in,
    output logic [ 6:0] out
);

    // Store CLZ counts for input halves
    logic [5:0] clz_high, clz_low;

    // Obtain CLZ counts
    clz_32 highCount (
        .in (in[63:32]),
        .out(clz_high)
    );
    clz_32 lowCount (
        .in (in[31:0]),
        .out(clz_low)
    );

    // Determine the output
    assign out = clz_high[5] ? {1'b0, clz_high} + {1'b0, clz_low} : {1'b0, clz_high};

endmodule  // clz_64


// Testbench
module clz_64_tb ();
    logic [63:0] in;
    logic [ 6:0] out;

    clz_64 dut (.*);

    integer i;
    initial begin
        in = 64'd0;
        #(10);
        assert (out == 7'b1000000);
        $display("input %b has %d leading zeros", in, out);

        for (i = 0; i < 64; i++) begin : testCLZ_64bit
            in = 64'd1 << i;
            #(10);
            assert (out == 63 - i);
            $display("input %b has %d leading zeros", in, out);
        end

        $stop();
    end

endmodule  // clz_64_tb
