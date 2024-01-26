// Author: Alex Ghandhi

/* Leading Zero Counter - 8 bit input

Inputs:
    in: 8-bit input

Outputs:
    out: 4-bit output
*/
module clz_8 (
    input  logic [7:0] in,
    output logic [3:0] out
);

    // Store CLZ counts for input halves
    logic [2:0] clz_high, clz_low;

    // Obtain CLZ counts
    clz_4 highCount (
        .in (in[7:4]),
        .out(clz_high)
    );
    clz_4 lowCount (
        .in (in[3:0]),
        .out(clz_low)
    );

    // Determine the output
    assign out = clz_high[2] ? {1'b0, clz_high} + {1'b0, clz_low} : {1'b0, clz_high};

endmodule  // clz_8


// Testbench
module clz_8_tb ();

    logic [7:0] in;
    logic [3:0] out;

    clz_8 dut (.*);

    integer i, j;
    initial begin
        in[7:4] = 4'b0000;
        for (i = 0; i < 16; i++) begin : testCLZ_8bit_4plus
            in[3:0] = i[3:0];
            #(10);
            assert (out >= 4'd4);
            $display("input %b has %d leading zeros", in, out);
        end
        in[7:4] = 4'b0001;
        for (i = 0; i < 16; i++) begin : testCLZ_8bit_3
            in[3:0] = i[3:0];
            #(10);
            assert (out == 4'd3);
            $display("input %b has %d leading zeros", in, out);
        end
        in[7:4] = 4'b0010;
        for (i = 0; i < 16; i++) begin : testCLZ_8bit_2
            in[3:0] = i[3:0];
            #(10);
            assert (out == 4'd2);
            $display("input %b has %d leading zeros", in, out);
        end
        in[7:4] = 4'b0100;
        for (i = 0; i < 16; i++) begin : testCLZ_8bit_1
            in[3:0] = i[3:0];
            #(10);
            assert (out == 4'd1);
            $display("input %b has %d leading zeros", in, out);
        end
        in[7:4] = 4'b1000;
        for (i = 0; i < 16; i++) begin : testCLZ_8bit_0
            in[3:0] = i[3:0];
            #(10);
            assert (out == 4'd0);
            $display("input %b has %d leading zeros", in, out);
        end

        $stop();
    end

endmodule  // clz_8_tb
