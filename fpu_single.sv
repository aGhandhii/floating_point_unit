// Author: Alex Ghandhi

`include "opcodes.svh"

/* Top-Level Floating Point Unit for Single Precision Values

Handles multiple arithmetic operations on floating point values, selects from
the desired opcode, and considers special values.

Inputs:
    a:          first input float
    b:          second input float
    opcode:     desired operation

Outputs:
    out:        sum of input floats
    inexact:    raised if truncation occurred
    overflow:   raised if overflow occurred
    underflow:  raised if underflow occurred
    divByZero:  raised if division by zero occurred
    invalid:    raised if result is invalid
*/
module fpu_single (
    a,
    b,
    opcode,
    out,
    inexact,
    overflow,
    underflow,
    divByZero,
    invalid
);

    // IO Declaration
    input logic [31:0] a, b;
    input opcodes opcode;
    output logic [31:0] out;
    output logic inexact, overflow, underflow, divByZero, invalid;  // Flags

    // Store Arithmetic Operation Results
    // NOTE: addition and subtraction are combined in a single unit
    logic [31:0] add_o, mul_o, div_o;
    logic add_overflow, add_underflow, add_inexact;
    logic mul_overflow, mul_underflow, mul_inexact;
    logic div_overflow, div_underflow, div_inexact;

    // Arithmetic Sub-Unit Instances
    float_adder_single addUnit (
        .a(a),
        .b((opcode == SUB) ? {~b[31], b[30:0]} : b),  // Flip sign of b for SUB
        .out(add_o),
        .overflow(add_overflow),
        .underflow(add_underflow),
        .inexact(add_inexact)
    );
    float_multiplier #(
        .FLOAT_SIZE(32),
        .EXPONENT_SIZE(8),
        .MANTISSA_SIZE(23),
        .BIAS(127)
    ) mulUnit (
        .a(a),
        .b(b),
        .out(mul_o),
        .overflow(mul_overflow),
        .underflow(mul_underflow),
        .inexact(mul_inexact)
    );
    float_divider #(
        .FLOAT_SIZE(32),
        .EXPONENT_SIZE(8),
        .MANTISSA_SIZE(23),
        .BIAS(127)
    ) divUnit (
        .a(a),
        .b(b),
        .out(div_o),
        .overflow(div_overflow),
        .underflow(div_underflow),
        .inexact(div_inexact)
    );

    // Determine Special Values
    logic A_is_zero, A_is_infinity, A_is_NaN;
    logic B_is_zero, B_is_infinity, B_is_NaN;
    assign A_is_zero     = (|a[30:0] == 1'b0) ? 1 : 0;
    assign A_is_infinity = ((&a[30:23] == 1'b1) & (|a[22:0] == 1'b0)) ? 1 : 0;
    assign A_is_NaN      = ((&a[30:23] == 1'b1) & (|a[22:0] != 1'b0)) ? 1 : 0;
    assign B_is_zero     = (|b[30:0] == 1'b0) ? 1 : 0;
    assign B_is_infinity = ((&b[30:23] == 1'b1) & (|b[22:0] == 1'b0)) ? 1 : 0;
    assign B_is_NaN      = ((&b[30:23] == 1'b1) & (|b[22:0] != 1'b0)) ? 1 : 0;


endmodule  // fpu_single


// Top-Level Testbench, Single Precision
module fpu_single_tb ();

    // IO Replication
    logic [31:0] a, b, out;
    opcodes opcode;
    logic inexact, overflow, underflow, divByZero, invalid;

    // Instance
    fpu_single dut (.*);

    // Test
    integer i;
    initial begin

        $stop();
    end  // Test

endmodule  // fpu_single_tb
