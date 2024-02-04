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

    // The exponent and mantissa calculations share some intermediate values
    // This has to do with normalization, as multiplying the mantissas
    //     (1.M) * (1.M)
    // can result in a value (1 <= value < 4), so the exponent might need to
    // be adjusted in this scenario. In this case, we also shift the resulting
    // mantissa such that the result remains in normalized format (1.M)

    // Intermediate logic
    logic flow_bit;
    logic [EXPONENT_SIZE+1:0] exponentAdd_o, biasSub_o, exponentShiftMux_o;
    logic [((MANTISSA_SIZE+1)*2)-1:0] mantissaMult_o;

    // Declare mux input ports
    logic [EXPONENT_SIZE+1:0] exponentShiftMux_i[1:0];
    assign exponentShiftMux_i[0] = 0;
    assign exponentShiftMux_i[1] = 1;
    logic [MANTISSA_SIZE-1:0] calcMantissaMux_i[1:0];
    assign calcMantissaMux_i[0] = mantissaMult_o[(2*MANTISSA_SIZE)-1:MANTISSA_SIZE];
    assign calcMantissaMux_i[1] = mantissaMult_o[(2*MANTISSA_SIZE):MANTISSA_SIZE+1];

    // CALCULATE EXPONENT
    // Add the exponents - extra 2 bits to prevent overflow
    assign exponentAdd_o = {2'b00, exponent_a} + {2'b00, exponent_b};

    // Subtract the bias from the result
    assign biasSub_o = exponentAdd_o - bias;

    // Adjust exponent as needed and check for over/underflow
    assign {underflow, flow_bit, exponent_out} = biasSub_o + exponentShiftMux_o;
    assign overflow = flow_bit & ~underflow;

    // CALCULATE MANTISSA
    assign mantissaMult_o = {1'b1, mantissa_a} * {1'b1, mantissa_b};
    mux #(
        .DATA_SIZE  (EXPONENT_SIZE + 2),
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


    // Check for an inexact result
    always_comb begin
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

Tests both 32-bit 'Single' and 64-bit 'Double' floating point precisions
*/
module float_multiplier_tb ();

    parameter DELAY = 100;

    // IO Replication, single-precision
    logic [31:0] a_sp, b_sp;
    logic [31:0] out_sp;
    logic overflow_sp, underflow_sp, inexact_sp;

    float_multiplier #(
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

    float_multiplier #(
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

        $display("\nTEST MULTIPLY BY 1 FOR SINGLE PRECISION\n");
        for (i = 0; i < 10; i++) begin : multByOneSingle
            a_sp = $urandom();
            b_sp = 32'b0_01111111_00000000000000000000000;
            #(DELAY);
            assert (out_sp == a_sp);
            a_sp = 32'b0_01111111_00000000000000000000000;
            b_sp = $urandom();
            #(DELAY);
            assert (out_sp == b_sp);
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

        $display("\nTEST MULTIPLY BY 1 FOR DOUBLE PRECISION");
        for (i = 0; i < 10; i++) begin : multByOneDouble
            a_dp[63:32] = $urandom();
            a_dp[31:0] = $urandom();
            b_dp = 64'b0_01111111111_0000000000000000000000000000000000000000000000000000;
            #(DELAY);
            assert (out_dp == a_dp);
            a_dp = 64'b0_01111111111_0000000000000000000000000000000000000000000000000000;
            b_dp[63:32] = $urandom();
            b_dp[31:0] = $urandom();
            #(DELAY);
            assert (out_dp == b_dp);
        end

        $stop();
    end

endmodule  // float_multiplier_tb
