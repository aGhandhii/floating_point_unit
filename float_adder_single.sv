// Author: Alex Ghandhi

/* Single-Precision Floating-Point Multiplier Unit

Calculates the sum of two 32-bit normalized floats

Inputs:
    a: first input float
    b: second input float

Outputs:
    out:        sum of input floats
    inexact:    raised if truncation occurred
    overflow:   raised if overflow occurred
    underflow:  raised if underflow occurred
    zero:       raised if result is zero

Parameters:
    FLOAT_SIZE:     bit-length of floating point value
    EXPONENT_SIZE:  bit-length of exponent portion
    MANTISSA_SIZE:  bit-length of mantissa portion
    BIAS:           bias for exponent
*/
module float_adder_single #(
    parameter FLOAT_SIZE = 32,
    EXPONENT_SIZE = 8,
    MANTISSA_SIZE = 23,
    BIAS = 127
) (
    a,
    b,
    out,
    overflow,
    underflow,
    inexact,
    zero
);

    // IO Declaration
    input logic [FLOAT_SIZE-1:0] a, b;
    output logic [FLOAT_SIZE-1:0] out;
    output logic overflow, underflow, inexact, zero;

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

    // Internal Control Signals
    logic EB_greater, E_equal, MA_greater, MX_greater, sameSign, m_add_adjust;
    logic [1:0] inexact_portions;
    logic [EXPONENT_SIZE:0] E_shamt;
    logic [MANTISSA_SIZE+1:0] mantissa_x, mantissa_y;

    // Logic for Leading Zero fix
    logic [5:0] leadingZeros, leadingZeros_raw;

    // Simple Control Signal Definitions
    assign inexact = |inexact_portions;  // OR the bits together
    assign MA_greater = (mantissa_a > mantissa_b) ? 1'b1 : 1'b0;
    assign MX_greater = (mantissa_x > mantissa_y) ? 1'b1 : 1'b0;
    assign sameSign = ~(sign_a ^ sign_b);

    // Sign Unit
    always_comb begin
        if ((~EB_greater) & (~E_equal)) begin
            sign_out = sign_a;
        end else begin
            if (EB_greater) begin
                sign_out = sign_b;
            end else begin
                if (MA_greater) begin
                    sign_out = sign_a;
                end else begin
                    sign_out = sign_b;
                end
            end
        end
    end  // Sign Unit

    ///////////////////////////
    // EXPONENT CALCULATIONS //
    ///////////////////////////

    // Intermediate Logic
    logic [EXPONENT_SIZE:0] E_base, E_diff_raw, E_m_add;

    // Signal Assignments
    assign E_diff_raw = {1'b0, exponent_a} - {1'b0, exponent_b};
    assign EB_greater = E_diff_raw[EXPONENT_SIZE];
    assign E_equal = (E_diff_raw == 0) ? 1'b1 : 1'b0;
    assign E_shamt = EB_greater ? (~E_diff_raw + 1) : E_diff_raw;
    assign E_base = EB_greater ? {1'b0, exponent_b} : {1'b0, exponent_a};
    assign E_m_add = m_add_adjust ? (E_base + 1) : E_base;
    assign overflow = E_m_add[EXPONENT_SIZE];

    // Final adjustment (handle leading zeros for mantissa subtraction)
    // Currently set for Single-Precision values
    assign {underflow, exponent_out} = E_m_add - {3'b000, leadingZeros};

    ///////////////////////////
    // MANTISSA CALCULATIONS //
    ///////////////////////////

    // EXPONENT ADJUSTMENT STAGE
    // In this stage, we shift the mantissas so that they represent the same
    // exponent, allowing for a simple arithmetic operation in the next stage.
    // Our input a and b will be converted to x and y, representing the order
    // with weight to the value of the input exponent.

    // Intermediate Logic
    logic [MANTISSA_SIZE+1:0] exponentShiftIn, exponentShiftedBits;
    assign exponentShiftIn = EB_greater ? {2'b01, mantissa_a} : {2'b01, mantissa_b};

    // Logic assignments
    assign mantissa_x = EB_greater ? {2'b01, mantissa_b} : {2'b01, mantissa_a};

    // Adjust the lower mantissa by the difference in exponents
    assign mantissa_y = exponentShiftIn >> E_shamt;
    assign exponentShiftedBits = exponentShiftIn << (MANTISSA_SIZE - E_shamt);
    always_comb begin
        if (E_shamt > MANTISSA_SIZE) begin
            inexact_portions[0] = |exponentShiftIn[MANTISSA_SIZE-1:0];
        end else begin
            if (E_shamt == 0) begin
                inexact_portions[0] = 0;
            end else begin
                // Check the shifted-out bits for nonzero elements
                inexact_portions[0] = |exponentShiftedBits;
            end
        end
    end

    // MANTISSA ADDITION/SUBTRACTION STAGE

    // Intermediate Logic
    logic [MANTISSA_SIZE+1:0] mantissa_add, mantissa_add_shift;
    logic [MANTISSA_SIZE:0]
        mantissa_sub, mantissa_add_ready, mantissa_sub_ready;

    // Handle the addition logic flow
    assign mantissa_add = mantissa_x + mantissa_y;
    assign mantissa_add_shift = mantissa_add >> 1;

    // If this is 1, we need to adjust the exponent and manissa to renormalize
    assign m_add_adjust = sameSign & mantissa_add[MANTISSA_SIZE+1];
    assign inexact_portions[1] = m_add_adjust & mantissa_add[0];

    always_comb begin : mantissaAddResult
        if (m_add_adjust)
            mantissa_add_ready = mantissa_add_shift[MANTISSA_SIZE:0];
        else mantissa_add_ready = mantissa_add[MANTISSA_SIZE:0];
    end

    // Handle the subtraction logic flow
    always_comb begin : mantissaSubInputs
        if (MX_greater)
            mantissa_sub = mantissa_x[MANTISSA_SIZE:0] - mantissa_y[MANTISSA_SIZE:0];
        else
            mantissa_sub = mantissa_y[MANTISSA_SIZE:0] - mantissa_x[MANTISSA_SIZE:0];
    end

    // SINGLE-PRECISION Specific: handle leading zero fix
    // This assumes that MANTISSA_SIZE = 23
    // Note that we pad the input to hit the bitlength, this is subtracted
    // when setting the leadingZeros value
    clz_32 leadingZeroCounter (
        .in ({8'b0000_0000, mantissa_sub}),
        .out(leadingZeros_raw)
    );
    assign leadingZeros = sameSign ? 0 : leadingZeros_raw - 6'd8;

    // Left-shift adjustment for subtraction
    assign mantissa_sub_ready = mantissa_sub << leadingZeros;

    // Set the zero control signal
    assign zero = sameSign ? ~|mantissa_add : ~|mantissa_sub;

    // Determine mantissa output
    always_comb begin : getMantissaOutput
        if (sameSign) mantissa_out = mantissa_add_ready[MANTISSA_SIZE-1:0];
        else mantissa_out = mantissa_sub_ready[MANTISSA_SIZE-1:0];
    end

endmodule  // float_adder_single


// Testbench for Single-Precision Floats
module float_adder_single_tb ();

    parameter DELAY = 100;

    // IO Replication
    logic [31:0] a, b, out;
    logic overflow, underflow, inexact, zero;

    // Instance
    float_adder_single dut (.*);

    // Main Test
    integer i;
    initial begin

        // Fully Randomized Float Inputs
        for (i = 0; i < 30; i++) begin : randomTesting
            a = $urandom();
            b = $urandom();
            #(DELAY);
            $display("a: %e\nb: %e", $bitstoshortreal(a), $bitstoshortreal(b));
            $display("a+b: %e", $bitstoshortreal(out));
            $display("%s%s%s%s", overflow ? "OVERFLOW " : "",
                     underflow ? "UNDERFLOW" : "", zero ? "ZERO" : "",
                     inexact ? "INEXACT" : "");
        end

        // Fix the exponent for precise testing
        a[30:23] = 8'd134;
        b[30:23] = 8'd134;
        for (i = 0; i < 20; i++) begin : zeroExponent
            // Mix the Sign
            a[31]   = $urandom();
            b[31]   = $urandom();
            // Mix the Mantissas
            a[22:0] = $urandom();
            b[22:0] = $urandom();
            #(DELAY);
            $display("a: %e\nb: %e", $bitstoshortreal(a), $bitstoshortreal(b));
            $display("a+b: %e", $bitstoshortreal(out));
            $display("%s%s%s%s", overflow ? "OVERFLOW " : "",
                     underflow ? "UNDERFLOW" : "", zero ? "ZERO" : "",
                     inexact ? "INEXACT" : "");
        end

        // Test Zero Flag
        for (i = 0; i < 20; i++) begin : testZero
            a = $urandom();
            b = a ^ (32'd1 << 31);
            #(DELAY);
            assert (zero);
        end

        $stop();
    end

endmodule  // float_adder_single_tb
