// Author: Alex Ghandhi

/* Simple parameterized subtractor unit.

Inputs:
    a: SIZE bit input
    b: SIZE bit input

Outputs:
    out: SIZE-bit output
    underflow: 1 if underflow occurred

Parameters:
    SIZE: bit length of inputs
*/
module subtractor #(
    parameter SIZE = 1
) (
    a,
    b,
    out,
    underflow
);

    // IO Declaration
    input logic [SIZE-1:0] a, b;
    output logic [SIZE-1:0] out;
    output logic underflow;

    // Declare the outputs
    assign out = a - b;
    assign underflow = out > a;

endmodule  // subtractor
