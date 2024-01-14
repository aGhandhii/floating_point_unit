// Author: Alex Ghandhi

/* Floating-Point Divider Unit

Calculates the quotient of two normalized floats

Inputs:
    a: first input float
    b: second input float

Outputs:
    out: quotient of input floats
    overflow: raised if overflow occurred
    underflow: raised if underflow occurred
    inexact: raised if truncation occurred

Parameters:
    FLOAT_SIZE: bit-length of floating point value
    EXPONENT_SIZE: bit-length of exponent portion
    MANTISSA_SIZE: bit-length of mantissa portion
    BIAS: bias for exponent
*/
module float_divider #(
    parameter FLOAT_SIZE,
    EXPONENT_SIZE,
    MANTISSA_SIZE,
    BIAS
) (
    a,
    b,
    out,
    overflow,
    underflow,
    inexact
);

    // IO Declaration
    input logic [FLOAT_SIZE-1:0] a, b;
    output logic [FLOAT_SIZE-1:0] out;
    output logic overflow, underflow, inexact;

    // Store the bias in the appropriate bitlength for later calculations
    // We add extra bits to check for over/underflow
    logic [EXPONENT_SIZE+1:0] bias;
    assign bias = BIAS[EXPONENT_SIZE+1:0];

    // Float Components for inputs and output
    logic sign_a, sign_b, sign_out;
    logic [EXPONENT_SIZE-1:0] exponent_a, exponent_b, exponent_out;
    logic [MANTISSA_SIZE-1:0] mantissa_a, mantissa_b, mantissa_out;

    // Define the output float
    assign out = {sign_out, exponent_out, mantissa_out};

    // Wire the float inputs to their components
    // format:  [ S | E | M ]
    assign sign_a = a[FLOAT_SIZE-1];
    assign sign_b = b[FLOAT_SIZE-1];
    assign exponent_a = a[FLOAT_SIZE-2:MANTISSA_SIZE];
    assign exponent_b = b[FLOAT_SIZE-2:MANTISSA_SIZE];
    assign mantissa_a = a[MANTISSA_SIZE-1:0];
    assign mantissa_b = b[MANTISSA_SIZE-1:0];

    // CALCULATE SIGN
    xor getSign (sign_out, sign_a, sign_b);

    // Intermediate Logic for exponent/mantissa calculations
    logic [EXPONENT_SIZE+1:0] exponentSub_o, biasAdd_o, exponentShiftMux_o;
    logic [MANTISSA_SIZE-1:0] mantissaDiv_o;  // Double-check the size
    logic flow_bit;

    // Mux for normalization decrement to exponent
    logic [EXPONENT_SIZE+1:0] exponentShiftMux_i[1:0];
    assign exponentShiftMux_i[0] = 0;
    assign exponentShiftMux_i[1] = 1;
    // If decrementing the exponent, we also mux to shift the mantissa
    logic [MANTISSA_SIZE-1:0] mantissaShiftMux_i[1:0];
    assign mantissaShiftMux_i[0] = mantissaDiv_o;
    assign mantissaShiftMux_i[1] = {mantissaDiv_o[MANTISSA_SIZE-3:0], 1'b0};

    // CALCULATE EXPONENT
    // Subtract the exponents and re-add the bias
    assign exponentSub_o = {2'b00, exponent_a} - {2'b00, exponent_b};
    assign biasAdd_o = exponentSub_o + bias;

    // Adjust the exponent if needed, also check for over/underflow
    assign {underflow, flow_bit, exponent_out} = biasAdd_o + exponentShiftMux_o;
    assign overflow = flow_bit & ~underflow;

    // CALCULATE MANTISSA

    // When dividing the mantissas, since the floating-point values are in
    // normalized format, their values range in [1, 2), so the quotient is
    // fixed in the range 0.5 < q < 2.
    // Because of this, we can gurantee that either the MSB or MSB-1 of the
    // quotient will be a 1. In the case that the MSB is a zero, we need to
    // decrement the exponent by 1, and perform a left-shift on the mantissa
    // to normalize the result. Otherwise, we can leave the exponent and
    // quotient as-is.
    assign mantissaDiv_o = {1'b1, mantissa_a} / {1'b1, mantissa_b};
    mux #(
        .DATA_SIZE  (EXPONENT_SIZE + 2),
        .SELECT_SIZE(1)
    ) exponentShiftMux (
        .in  (exponentShiftMux_i),
        .port(~mantissaDiv_o[MANTISSA_SIZE-2]),
        .out (exponentShiftMux_o)
    );
    mux #(
        .DATA_SIZE  (MANTISSA_SIZE),
        .SELECT_SIZE(1)
    ) mantissaShiftMux (
        .in  (mantissaShiftMux_i),
        .port(~mantissaDiv_o[MANTISSA_SIZE-2]),
        .out (mantissa_out)
    );

endmodule  // float_divider
