// Author: Alex Ghandhi

/* Simple parameterized multiplier unit.

This generates a combination circuit, there will be lots of internal logic,
but the result will not rely on a clock

Inputs:
    a: SIZE bit input
    b: SIZE bit input

Outputs:
    out: 2xSIZE-bit output

Parameters:
    SIZE: bit length of inputs
*/
module multiplier #(
    parameter SIZE = 1
) (
    a,
    b,
    out
);

    // IO Declaration
    input logic [SIZE-1:0] a, b;
    output logic [SIZE*2-1:0] out;

    // Declare the output
    assign out = a * b;

endmodule  // multiplier
