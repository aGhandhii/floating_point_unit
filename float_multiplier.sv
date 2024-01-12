// Author: Alex Ghandhi

/* Floating-Point Multiplier Unit

Calculates the product of two normalized floats

Inputs:
    a: first input float
    b: second input float

Outputs:
    out: product of input floats
    overflow: raised if overflow occurred
    underflow: raised if underflow occurred
    inexact: raised if truncation occurred

Parameters:
    FLOAT_SIZE: bit-length of floating point value
    EXPONENT_SIZE: bit-length of exponent portion
    MANTISSA_SIZE: bit-length of mantissa portion
    BIAS: bias for exponent
*/
module float_multiplier #(
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
    logic [EXPONENT_SIZE-1:0] bias;
    assign bias = BIAS[EXPONENT_SIZE-1:0];

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

    // The exponent and mantissa calculations share some intermediate values
    // This has to do with normalization, as multiplying the mantissas
    //     (1.M) * (1.M)
    // can result in a value (1 <= value < 4), so the exponent might need to
    // be adjusted in this scenario. In this case, we also shift the resulting
    // mantissa such that the result remains in normalized format (1.M)

    // Intermediate logic
    logic [EXPONENT_SIZE-1:0] exponentAdd_o, biasSub_o, exponentShiftMux_o;
    logic [((MANTISSA_SIZE+1)*2)-1:0] mantissaMult_o;
    logic [1:0] adder_overflow;

    // Declare mux input ports
    logic [EXPONENT_SIZE-1:0] exponentShiftMux_i[1:0];
    assign exponentShiftMux_i[0] = 0;
    assign exponentShiftMux_i[1] = 1;
    logic [MANTISSA_SIZE-1:0] calcMantissaMux_i[1:0];
    assign calcMantissaMux_i[0] = mantissaMult_o[(2*MANTISSA_SIZE)-1:MANTISSA_SIZE];
    assign calcMantissaMux_i[1] = mantissaMult_o[(2*MANTISSA_SIZE):MANTISSA_SIZE+1];

    // CALCULATE EXPONENT
    adder #(
        .SIZE(EXPONENT_SIZE)
    ) exponentAdd (
        .a(exponent_a),
        .b(exponent_b),
        .out(exponentAdd_o),
        .overflow(adder_overflow[0])
    );
    subtractor #(
        .SIZE(EXPONENT_SIZE)
    ) biasSub (
        .a(exponentAdd_o),
        .b(bias),
        .out(biasSub_o),
        .underflow(underflow)
    );
    adder #(
        .SIZE(EXPONENT_SIZE)
    ) calcExponent (
        .a(biasSub_o),
        .b(exponentShiftMux_o),
        .out(exponent_out),
        .overflow(adder_overflow[1])
    );

    // CALCULATE MANTISSA
    multiplier #(
        .SIZE(MANTISSA_SIZE + 1)
    ) mantissaMult (
        .a  ({1'b1, mantissa_a}),
        .b  ({1'b1, mantissa_b}),
        .out(mantissaMult_o)
    );
    mux #(
        .DATA_SIZE  (EXPONENT_SIZE),
        .SELECT_SIZE(1)
    ) exponentShiftMux (
        .in  (exponentShiftMux_i),
        .port(mantissaMult_o[((MANTISSA_SIZE+1)*2)-1]),
        .out (exponentShiftMux_o)
    );
    mux #(
        .DATA_SIZE  (MANTISSA_SIZE),
        .SELECT_SIZE(1)
    ) calcMantissaMux (
        .in  (calcMantissaMux_i),
        .port(mantissaMult_o[((MANTISSA_SIZE+1)*2)-1]),
        .out (mantissa_out)
    );


    // Set control signals
    always_comb begin
        overflow = adder_overflow[0] | adder_overflow[1];

        // Check if truncation occurred in multiplier result
        if (mantissaMult_o[((MANTISSA_SIZE+1)*2)-1]) begin
            // MSB is a 1, check the bottom half bits
            inexact = (mantissaMult_o[MANTISSA_SIZE:0] != 0);
        end else begin
            // MSB is not 1, check bottom half minus 1 bits, since
            // we do not need to adjust the exponent
            inexact = (mantissaMult_o[MANTISSA_SIZE-1:0] != 0);
        end
    end

endmodule  // float_multiplier


/* Testbench for the float multiplier

We will use 32-bit 'float' values for testing.
*/
module float_multiplier_tb ();

    parameter DELAY = 100;

    // IO Replication
    logic [31:0] a, b;
    logic [31:0] out;
    logic overflow, underflow, inexact;

    float_multiplier #(
        .FLOAT_SIZE(32),
        .EXPONENT_SIZE(8),
        .MANTISSA_SIZE(23),
        .BIAS(127)
    ) dut (
        .*
    );

    // Test
    integer i;
    initial begin

        $display("Generating Input Floats");
        for (i = 0; i < 20; i++) begin : testSign
            a = $urandom();
            b = $urandom();
            #(DELAY);
            assert (out[31] == a[31] ^ b[31]);
        end

        $stop();
    end

endmodule  // float_multiplier_tb
