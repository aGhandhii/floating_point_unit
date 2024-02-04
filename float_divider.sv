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
    // Needed to double the length of mantissa and normal bit for division
    logic [MANTISSA_SIZE-1:0] mantissa_a_extension;
    assign mantissa_a_extension = 0;
    // The quotient will be contained in the lower bits
    logic [(2*(MANTISSA_SIZE+1))-1:0] mantissaDiv_o;
    logic flow_bit;

    // Mux for normalization decrement to exponent
    logic [EXPONENT_SIZE+1:0] exponentShiftMux_i[1:0];
    assign exponentShiftMux_i[0] = 0;
    assign exponentShiftMux_i[1] = 1;
    // If decrementing the exponent, we also mux to shift the mantissa
    logic [MANTISSA_SIZE-1:0] mantissaShiftMux_i[1:0];
    assign mantissaShiftMux_i[0] = mantissaDiv_o[MANTISSA_SIZE-1:0];
    assign mantissaShiftMux_i[1] = {mantissaDiv_o[MANTISSA_SIZE-2:0], 1'b0};

    // CALCULATE EXPONENT
    // Subtract the exponents and re-add the bias
    assign exponentSub_o = {2'b00, exponent_a} - {2'b00, exponent_b};
    assign biasAdd_o = exponentSub_o + bias;

    // Adjust the exponent if needed, also check for over/underflow
    assign {underflow, flow_bit, exponent_out} = biasAdd_o - exponentShiftMux_o;
    assign overflow = flow_bit & ~underflow;

    // CALCULATE MANTISSA

    // When dividing the mantissas, since the floating-point values are in
    // normalized format, their values range in [1, 2), so the quotient is
    // fixed in the range 0.5 < q < 2.
    //
    // Our first mantissa is extended with MANTISSA_SIZE extra zeroes so that
    // our division result can store the quotient in its lower bits.
    //
    // Because of this, we can gurantee that either the MSB or MSB-1 of the
    // quotient's lower bits will be a 1. In the case that the MSB is a zero,
    // we need to decrement the exponent by 1, and perform a left-shift on the
    // mantissa to normalize the result. Otherwise, we can leave the exponent
    // and quotient as-is.
    assign mantissaDiv_o = {1'b1, mantissa_a, mantissa_a_extension} / {1'b1, mantissa_b};
    mux #(
        .DATA_SIZE  (EXPONENT_SIZE + 2),
        .SELECT_SIZE(1)
    ) exponentShiftMux (
        .in  (exponentShiftMux_i),
        .port(~mantissaDiv_o[MANTISSA_SIZE]),
        .out (exponentShiftMux_o)
    );
    mux #(
        .DATA_SIZE  (MANTISSA_SIZE),
        .SELECT_SIZE(1)
    ) mantissaShiftMux (
        .in  (mantissaShiftMux_i),
        .port(~mantissaDiv_o[MANTISSA_SIZE]),
        .out (mantissa_out)
    );

endmodule  // float_divider


/* Testbench for the float divider

Tests both 32-bit 'Single' and 64-bit 'Double' floating point precisions
*/
module float_divider_tb ();

    parameter DELAY = 100;

    // IO Replication, single-precision
    logic [31:0] a_sp, b_sp;
    logic [31:0] out_sp;
    logic overflow_sp, underflow_sp, inexact_sp;

    float_divider #(
        .FLOAT_SIZE(32),
        .EXPONENT_SIZE(8),
        .MANTISSA_SIZE(23),
        .BIAS(127)
    ) dut_sp (
        .a(a_sp),
        .b(b_sp),
        .out(out_sp),
        .overflow(overflow_sp),
        .underflow(underflow_sp),
        .inexact(inexact_sp)
    );

    // IO Replication, double-precision
    logic [63:0] a_dp, b_dp;
    logic [63:0] out_dp;
    logic overflow_dp, underflow_dp, inexact_dp;

    float_divider #(
        .FLOAT_SIZE(64),
        .EXPONENT_SIZE(11),
        .MANTISSA_SIZE(52),
        .BIAS(1023)
    ) dut_dp (
        .a(a_dp),
        .b(b_dp),
        .out(out_dp),
        .overflow(overflow_dp),
        .underflow(underflow_dp),
        .inexact(inexact_dp)
    );

    // Test
    integer i;
    initial begin

        $display("TESTING SINGLE-PRECISION VALUES");
        for (i = 0; i < 20; i++) begin : testSinglePrecision
            a_sp = $urandom();
            b_sp = $urandom();
            #(DELAY);
            assert (out_sp[31] == a_sp[31] ^ b_sp[31]);
            $display("a: %e\nb: %e\na*b: %e", $bitstoshortreal(a_sp),
                     $bitstoshortreal(b_sp), $bitstoshortreal(out_sp));
            if (overflow_sp | underflow_sp | inexact_sp) begin
                $display("%s%s%s", overflow_sp ? "OVERFLOW " : "",
                         underflow_sp ? "UNDERFLOW" : " ",
                         inexact_sp ? "INEXACT" : "");
            end
        end

        $display("\nTEST DIVIDE BY 1 FOR SINGLE PRECISION\n");
        for (i = 0; i < 10; i++) begin : divByOneSingle
            a_sp = $urandom();
            b_sp = 32'b0_01111111_00000000000000000000000;
            #(DELAY);
            assert (out_sp == a_sp);
        end

        $display("TESTING DOUBLE-PRECISION VALUES");
        for (i = 0; i < 20; i++) begin : testDoublePrecision
            a_dp[63:32] = $urandom();
            a_dp[31:0]  = $urandom();
            b_dp[63:32] = $urandom();
            b_dp[31:0]  = $urandom();
            #(DELAY);
            assert (out_dp[63] == a_dp[63] ^ b_dp[63]);
            $display("a: %e\nb: %e\na*b: %e", $bitstoreal(a_dp),
                     $bitstoreal(b_dp), $bitstoreal(out_dp));
            if (overflow_dp | underflow_dp | inexact_dp) begin
                $display("%s%s%s", overflow_dp ? "OVERFLOW " : "",
                         underflow_dp ? "UNDERFLOW" : " ",
                         inexact_dp ? "INEXACT" : "");
            end
        end

        $display("\nTEST DIVIDE BY 1 FOR DOUBLE PRECISION");
        for (i = 0; i < 10; i++) begin : divByOneDouble
            a_dp[63:32] = $urandom();
            a_dp[31:0] = $urandom();
            b_dp = 64'b0_01111111111_0000000000000000000000000000000000000000000000000000;
            #(DELAY);
            assert (out_dp == a_dp);
        end

        $stop();
    end

endmodule  // float_divider_tb
