// Author: Alex Ghandhi

/* Leading Zero Counter - 16 bit input

Inputs:
    in: 16-bit input

Outputs:
    out: 5-bit output
*/
module clz_16 (
    input  logic [15:0] in,
    output logic [ 4:0] out
);

    // Store CLZ counts for input halves
    logic [3:0] clz_high, clz_low;

    // Obtain CLZ counts
    clz_8 highCount (
        .in (in[15:8]),
        .out(clz_high)
    );
    clz_8 lowCount (
        .in (in[7:0]),
        .out(clz_low)
    );

    // Determine the output
    assign out = clz_high[3] ? {1'b0, clz_high} + {1'b0, clz_low} : {1'b0, clz_high};

endmodule  // clz_16


// Testbench
module clz_16_tb ();
    logic [15:0] in;
    logic [ 4:0] out;

    clz_16 dut (.*);

    integer i;
    initial begin
        in = 16'd0;
        #(10);
        assert (out == 5'b10000);
        $display("input %b has %d leading zeros", in, out);

        for (i = 0; i < 16; i++) begin : testCLZ_16bit
            in = 16'd1 << i;
            #(10);
            assert (out == 15 - i);
            $display("input %b has %d leading zeros", in, out);
        end

        $stop();
    end

endmodule  // clz_16_tb
