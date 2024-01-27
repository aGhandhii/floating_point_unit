// Author: Alex Ghandhi

/* Floating-Point Multiplier Unit

Calculates the sum of two normalized floats

Inputs:
    a: first input float
    b: second input float

Outputs:
    out: sum of input floats
    inexact: raised if truncation occurred
    overflow: raised if overflow occurred
    underflow: raised if underflow occurred
    zero: raised if result is zero

Parameters:
    FLOAT_SIZE: bit-length of floating point value
    EXPONENT_SIZE: bit-length of exponent portion
    MANTISSA_SIZE: bit-length of mantissa portion
    BIAS: bias for exponent
*/
module float_adder #(
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

    // EXPONENT CALCULATIONS

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
    assign {underflow, exponent_out} = E_m_add - {4'b0000, leadingZeros};

    ///////////////////////////
    // MANTISSA CALCULATIONS //
    ///////////////////////////

    // EXPONENT ADJUSTMENT STAGE
    // In this stage, we shift the mantissas so that they represent the same
    // exponent, allowing for a simple arithmetic operation in the next stage.
    // Our input a and b will be converted to x and y, representing the order
    // with weight to the value of the input exponent.

    // Intermediate Logic
    logic [MANTISSA_SIZE+1:0] exponentShiftIn;

    // Logic assignments
    assign mantissa_x = EB_greater ? {2'b01, mantissa_b} : {2'b01, mantissa_a};

    // Adjust the lower mantissa by the difference in exponents
    assign mantissa_y = exponentShiftIn >> E_shamt;
    always_comb begin
        if (E_shamt > MANTISSA_SIZE) begin
            inexact_portions[0] = |exponentShiftIn[MANTISSA_SIZE-1:0];
        end else begin
            if (E_shamt == 0) inexact_portions[0] = 0;
            else inexact_portions[0] = |exponentShiftIn[E_shamt-1:0];
        end
    end

    // MANTISSA ADDITION/SUBTRACTION STAGE


endmodule  // float_adder
