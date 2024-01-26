// Author: Alex Ghandhi

/* Leading Zero Counter - 2 bit input

Inputs:
    in: 2-bit input

Outputs:
    out: 2-bit output
*/
module clz_2 (
    input  logic [1:0] in,
    output logic [1:0] out
);

    // Logic for zero count
    assign out[1] = ~(in[1]) & ~(in[0]);
    assign out[0] = (~in[1]) & in[0];

endmodule  // clz_2


// Testbench
module clz_2_tb ();

    logic [1:0] in, out;

    clz_2 dut (.*);

    integer i;
    initial begin
        for (i = 0; i < 4; i++) begin : testCLZ_2bit
            in = i[1:0];
            #(10);
            $display("input %b has %d leading zeros", in, out);
        end

        $stop();
    end

endmodule  // clz_2_tb
