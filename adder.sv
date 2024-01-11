// Author: Alex Ghandhi

/* Simple parameterized adder unit.

Inputs:
    a: SIZE bit input
    b: SIZE bit input

Outputs:
    out: SIZE-bit output
    overflow: 1 if overflow occurred

Parameters:
    SIZE: bit length of inputs
*/
module adder #(
    parameter SIZE = 1
) (
    a,
    b,
    out,
    overflow
);

    // IO Declaration
    input logic [SIZE-1:0] a, b;
    output logic [SIZE-1:0] out;
    output logic overflow;

    // Store the result with an extra bit - this allows for overflow checking
    logic [SIZE:0] result;

    // Declare the outputs
    assign {overflow, out} = {1'b0, a} + {1'b0, b};

endmodule  // adder
