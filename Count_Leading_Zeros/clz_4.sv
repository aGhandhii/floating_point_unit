// Author: Alex Ghandhi

/* Leading Zero Counter - 4 bit input

Inputs:
    in: 4-bit input

Outputs:
    out: 3-bit output
*/
module clz_4 (
    input  logic [3:0] in,
    output logic [2:0] out
);

    // Store CLZ counts for input halves
    logic [1:0] clz_high, clz_low;

    // Obtain CLZ counts
    clz_2 highCount (
        .in (in[3:2]),
        .out(clz_high)
    );
    clz_2 lowCount (
        .in (in[1:0]),
        .out(clz_low)
    );

    // Determine the output
    assign out = clz_high[1] ? {1'b0, clz_high} + {1'b0, clz_low} : {1'b0, clz_high};

endmodule  // clz_4


// Testbench
module clz_4_tb ();

    logic [3:0] in;
    logic [2:0] out;

    clz_4 dut (.*);

    integer i;
    initial begin
        for (i = 0; i < 16; i++) begin : testCLZ_4bit
            in = i[3:0];
            #(10);
            $display("input %b has %d leading zeros", in, out);
        end

        $stop();
    end

endmodule  // clz_4_tb
