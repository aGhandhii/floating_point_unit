// Author: Alex Ghandhi

`include "opcodes.svh"

/* Top-Level Floating Point Unit for Double Precision Values

Handles multiple arithmetic operations on floating point values, selects from
the desired opcode, and considers special values.

Inputs:
    a:          first input double
    b:          second input double
    opcode:     desired operation

Outputs:
    out:        sum of input doubles
    inexact:    raised if truncation occurred
    overflow:   raised if overflow occurred
    underflow:  raised if underflow occurred
    divByZero:  raised if division by zero occurred
    invalid:    raised if result is invalid
*/
module fpu_double (
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
    // Useful Constants
    parameter NAN_FLOAT              = 64'b0_11111111111_1111111111111111111111111111111111111111111111111111;
    parameter ZERO_FLOAT_NO_SIGN     = 63'b00000000000_0000000000000000000000000000000000000000000000000000;
    parameter INFINITY_FLOAT_NO_SIGN = 63'b11111111111_0000000000000000000000000000000000000000000000000000;

    // IO Declaration
    input logic [63:0] a, b;
    input opcodes opcode;
    output logic [63:0] out;
    output logic inexact, overflow, underflow, divByZero, invalid;  // Flags

    // The invalid flag is thrown when the output is NaN
    assign invalid   = ((&out[62:52] == 1'b1) & (|out[51:0] != 1'b0)) ? 1 : 0;

    // Divide By Zero is thrown when the divisor is zero
    assign divByZero = (opcode == DIV) & (|b[62:0] == 1'b0);

    // Store Arithmetic Operation Results
    // NOTE: addition and subtraction are combined in a single unit
    logic [63:0] add_o, mul_o, div_o;
    logic add_overflow, add_underflow, add_inexact;
    logic mul_overflow, mul_underflow, mul_inexact;
    logic div_overflow, div_underflow, div_inexact;

    // Arithmetic Sub-Unit Instances
    float_adder_double addUnit (
        .a(a),
        .b((opcode == SUB) ? {~b[63], b[62:0]} : b),  // Flip sign of b for SUB
        .out(add_o),
        .overflow(add_overflow),
        .underflow(add_underflow),
        .inexact(add_inexact),
        .zero()
    );
    float_multiplier #(
        .FLOAT_SIZE(64),
        .EXPONENT_SIZE(11),
        .MANTISSA_SIZE(52),
        .BIAS(1023)
    ) mulUnit (
        .a(a),
        .b(b),
        .out(mul_o),
        .overflow(mul_overflow),
        .underflow(mul_underflow),
        .inexact(mul_inexact)
    );
    float_divider #(
        .FLOAT_SIZE(64),
        .EXPONENT_SIZE(11),
        .MANTISSA_SIZE(52),
        .BIAS(1023)
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
    assign A_is_zero     = (|a[62:0] == 1'b0) ? 1 : 0;
    assign A_is_infinity = ((&a[62:52] == 1'b1) & (|a[51:0] == 1'b0)) ? 1 : 0;
    assign A_is_NaN      = ((&a[62:52] == 1'b1) & (|a[51:0] != 1'b0)) ? 1 : 0;
    assign B_is_zero     = (|b[62:0] == 1'b0) ? 1 : 0;
    assign B_is_infinity = ((&b[62:52] == 1'b1) & (|b[51:0] == 1'b0)) ? 1 : 0;
    assign B_is_NaN      = ((&b[62:52] == 1'b1) & (|b[51:0] != 1'b0)) ? 1 : 0;

    // Handle Special Values for each operation
    always_comb begin
        // ADDITION and SUBTRACTION
        if ((opcode == ADD) | (opcode == SUB)) begin
            if (A_is_NaN | B_is_NaN) begin
                out       = NAN_FLOAT;
                inexact   = 0;
                overflow  = 0;
                underflow = 0;
            end else if (A_is_infinity) begin
                if (B_is_infinity) begin
                    // Check for opposing signs - this results in NaN
                    if (opcode == ADD) begin
                        if (a[63] ^ b[63] == 1'b1) begin  // NaN
                            out       = NAN_FLOAT;
                            inexact   = 0;
                            overflow  = 0;
                            underflow = 0;
                        end else begin  // Valid
                            out       = a;
                            inexact   = 0;
                            overflow  = 0;
                            underflow = 0;
                        end
                    end else begin
                        if (a[63] ^ b[63] == 1'b0) begin  // NaN
                            out       = NAN_FLOAT;
                            inexact   = 0;
                            overflow  = 0;
                            underflow = 0;
                        end else begin  // Valid
                            out       = a;
                            inexact   = 0;
                            overflow  = 0;
                            underflow = 0;
                        end
                    end
                end else begin
                    out       = a;
                    inexact   = 0;
                    overflow  = 0;
                    underflow = 0;
                end
            end else if (B_is_infinity) begin
                inexact   = 0;
                overflow  = 0;
                underflow = 0;
                if (opcode == SUB) out = {~b[63], b[62:0]};  // Flip the sign
                else out = b;
            end else if (A_is_zero) begin
                out       = b;
                inexact   = 0;
                overflow  = 0;
                underflow = 0;
            end else if (B_is_zero) begin
                out       = a;
                inexact   = 0;
                overflow  = 0;
                underflow = 0;
            end else begin  // No special values, output Adder results
                inexact   = add_inexact;
                overflow  = add_overflow;
                underflow = add_underflow;
                if (add_overflow) out = {add_o[63], INFINITY_FLOAT_NO_SIGN};
                else if (add_underflow) out = {add_o[63], ZERO_FLOAT_NO_SIGN};
                else out = add_o;
            end
        end else if (opcode == MUL) begin  // MULTIPLICATION
            if (A_is_NaN | B_is_NaN) begin
                out       = NAN_FLOAT;
                inexact   = 0;
                overflow  = 0;
                underflow = 0;
            end else if (A_is_zero | B_is_zero) begin
                // 0 * infinity = NaN
                if (A_is_infinity | B_is_infinity) begin
                    out       = NAN_FLOAT;
                    inexact   = 0;
                    overflow  = 0;
                    underflow = 0;
                end else begin
                    out       = {mul_o[63], ZERO_FLOAT_NO_SIGN};
                    inexact   = 0;
                    overflow  = 0;
                    underflow = 0;
                end
            end else if (A_is_infinity | B_is_infinity) begin
                out       = {mul_o[63], INFINITY_FLOAT_NO_SIGN};
                inexact   = 0;
                overflow  = 0;
                underflow = 0;
            end else begin  // No Special Values, use Multiplier outputs
                inexact   = mul_inexact;
                overflow  = mul_overflow;
                underflow = mul_underflow;
                if (mul_overflow) out = {mul_o[63], INFINITY_FLOAT_NO_SIGN};
                else if (mul_underflow) out = {mul_o[63], ZERO_FLOAT_NO_SIGN};
                else out = mul_o;
            end
        end else if (opcode == DIV) begin  // DIVISION
            if (A_is_NaN | B_is_NaN) begin
                out       = NAN_FLOAT;
                inexact   = 0;
                overflow  = 0;
                underflow = 0;
            end else if (B_is_zero) begin
                // 0 / 0 = NaN
                if (A_is_zero) begin
                    out       = NAN_FLOAT;
                    inexact   = 0;
                    overflow  = 0;
                    underflow = 0;
                end else begin
                    out       = {div_o[63], INFINITY_FLOAT_NO_SIGN};
                    inexact   = 0;
                    overflow  = 0;
                    underflow = 0;
                end
            end else if (B_is_infinity) begin
                // infinity / infinity = NaN
                if (A_is_infinity) begin
                    out       = NAN_FLOAT;
                    inexact   = 0;
                    overflow  = 0;
                    underflow = 0;
                end else begin  // x / infinity = 0
                    out       = {div_o[63], ZERO_FLOAT_NO_SIGN};
                    inexact   = 0;
                    overflow  = 0;
                    underflow = 0;
                end
            end else if (A_is_infinity) begin
                out       = {div_o[63], INFINITY_FLOAT_NO_SIGN};
                inexact   = 0;
                overflow  = 0;
                underflow = 0;
            end else if (A_is_zero) begin
                out       = {div_o[63], ZERO_FLOAT_NO_SIGN};
                inexact   = 0;
                overflow  = 0;
                underflow = 0;
            end else begin  // No Special Values, use Divider Unit Outputs
                inexact   = div_inexact;
                overflow  = div_overflow;
                underflow = div_underflow;
                if (div_overflow) out = {div_o[63], INFINITY_FLOAT_NO_SIGN};
                else if (div_underflow) out = {div_o[63], ZERO_FLOAT_NO_SIGN};
                else out = div_o;
            end
        end
    end  // Handle Special Values for each operation

endmodule  // fpu_double


// Top-Level Testbench, Double Precision
module fpu_double_tb ();

    // Useful Constants
    parameter NAN_FLOAT              = 64'b0_11111111111_1111111111111111111111111111111111111111111111111111;
    parameter ZERO_FLOAT_NO_SIGN     = 63'b00000000000_0000000000000000000000000000000000000000000000000000;
    parameter INFINITY_FLOAT_NO_SIGN = 63'b11111111111_0000000000000000000000000000000000000000000000000000;
    parameter DELAY = 100;

    // IO Replication
    logic [63:0] a, b, out;
    opcodes opcode;
    logic inexact, overflow, underflow, divByZero, invalid;

    // Instance
    fpu_double dut (.*);

    // Test
    integer i;
    initial begin

        $display("Testing Special Value Detection");
        a = 64'd0;  // Zero
        #(10);
        a[62:52] = 11'b111_1111_1111;  // Exponent all 1, Mantissa all 0
        #(10);
        a[51:0] = 23'd1;  // Mantissa no longer 0, now a NaN
        #(10);
        a[62:52] = 11'b111_1111_1110;  // Representable Exponent
        #(10);

        $display("Testing ADD/SUB Logic Flow");
        opcode = ADD;
        a = NAN_FLOAT;
        b = NAN_FLOAT;
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        a = {1'b0, INFINITY_FLOAT_NO_SIGN};
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        b = {1'b0, ZERO_FLOAT_NO_SIGN};
        #(DELAY);
        assert (out == a);
        b = {1'b0, INFINITY_FLOAT_NO_SIGN};
        #(DELAY);
        assert (out == a);
        b[63] = 1'b1;
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        opcode = SUB;
        #(DELAY);
        assert (out == a);
        a = 64'd0;
        #(DELAY);
        assert (out == {~b[63], b[62:0]});
        opcode = ADD;
        #(DELAY);
        assert (out == b);
        b = 64'd10;
        #(DELAY);
        assert (out == b);
        a = 64'd10;
        b = 64'd0;
        #(DELAY);
        assert (out == a);
        b = 64'd10;
        #(DELAY);

        $display("Testing MUL Logic Flow");
        opcode = MUL;
        a = NAN_FLOAT;
        b = NAN_FLOAT;
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        a = {1'b0, ZERO_FLOAT_NO_SIGN};
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        b = {1'b0, INFINITY_FLOAT_NO_SIGN};
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        b = {1'b0, ZERO_FLOAT_NO_SIGN};
        #(DELAY);
        assert (out[62:0] == ZERO_FLOAT_NO_SIGN);
        a = {1'b0, INFINITY_FLOAT_NO_SIGN};
        b = {1'b1, INFINITY_FLOAT_NO_SIGN};
        #(DELAY);
        assert (out == {1'b1, INFINITY_FLOAT_NO_SIGN});
        a = {1'b1, 63'd10};
        #(DELAY);
        assert (out == {1'b0, INFINITY_FLOAT_NO_SIGN});
        b = 64'd234;
        #(DELAY);

        $display("Testing DIV Logic Flow");
        opcode = DIV;
        a = NAN_FLOAT;
        b = NAN_FLOAT;
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        a = {1'b0, ZERO_FLOAT_NO_SIGN};
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        b = {1'b0, ZERO_FLOAT_NO_SIGN};
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        a = {1'b0, INFINITY_FLOAT_NO_SIGN};
        #(DELAY);
        assert (out == {1'b0, INFINITY_FLOAT_NO_SIGN});
        b = {1'b0, INFINITY_FLOAT_NO_SIGN};
        #(DELAY);
        assert ((out == NAN_FLOAT) & invalid);
        a = 64'd123;
        #(DELAY);
        assert (out == {1'b0, ZERO_FLOAT_NO_SIGN});
        b = 64'd123;
        a = {1'b0, INFINITY_FLOAT_NO_SIGN};
        #(DELAY);
        assert (out == {1'b0, INFINITY_FLOAT_NO_SIGN});
        a = {1'b0, ZERO_FLOAT_NO_SIGN};
        #(DELAY);
        assert (out == {1'b0, ZERO_FLOAT_NO_SIGN});
        a = 64'd123;
        #(DELAY);

        $display("TEST ADD/SUB UNDERFLOW");
        a = 64'b0_00000000000_0000000000000000000000000000000000000000000000000111;
        b = 64'b0_00000000000_0000000000000000000000000000000000000000000000001000;
        opcode = SUB;
        #(DELAY);
        assert (out == {1'b1, ZERO_FLOAT_NO_SIGN} && underflow);

        $display("TEST MUL OVERFLOW/UNDERFLOW");
        opcode = MUL;
        a = 64'b0_11111111110_0000000000001111111111111111111111111111111111111111;
        b = 64'b0_10000000010_1000000000000000000000000000000000000000000000001000;
        #(DELAY);
        assert (out == {1'b0, INFINITY_FLOAT_NO_SIGN} && overflow);
        a = 64'b0_00000000000_0000000000001111111111111111111111111111111111111111;
        b = 64'b0_00000000111_1000000000000000000000000000000000000000000000001000;
        #(DELAY);
        assert (out == {1'b0, ZERO_FLOAT_NO_SIGN} && underflow);

        $display("TEST DIV OVERFLOW/UNDERFLOW");
        opcode = DIV;
        a = 64'b0_11111111110_0000000000001111111111111111111111111111111111111111;
        b = 64'b0_00000000010_1000000000000000000000000000000000000000000000001000;
        #(DELAY);
        assert (out == {1'b0, INFINITY_FLOAT_NO_SIGN} && overflow);
        a = 64'b0_00000000010_1000000000000000000000000000000000000000000000001000;
        b = 64'b0_11111111110_0000000000001111111111111111111111111111111111111111;
        #(DELAY);
        assert (out == {1'b0, ZERO_FLOAT_NO_SIGN} && underflow);

        $display("\n\nRANDOM ADDITION");
        opcode = ADD;
        for (i = 0; i < 10; i++) begin
            a[63:32] = $urandom();
            a[31:0]  = $urandom();
            b[63:32] = $urandom();
            b[31:0]  = $urandom();
            #(DELAY);
            $display("a: %e\nb: %e\na+b: %e", $bitstoreal(a), $bitstoreal(b),
                     $bitstoreal(out));
            if (overflow | underflow | inexact) begin
                $display("%s%s%s", overflow ? "OVERFLOW " : "",
                         underflow ? "UNDERFLOW " : " ",
                         inexact ? "INEXACT" : "");
            end
        end

        $display("\n\nRANDOM SUBTRACTION");
        opcode = SUB;
        for (i = 0; i < 10; i++) begin
            a[63:32] = $urandom();
            a[31:0]  = $urandom();
            b[63:32] = $urandom();
            b[31:0]  = $urandom();
            #(DELAY);
            $display("a: %e\nb: %e\na-b: %e", $bitstoreal(a), $bitstoreal(b),
                     $bitstoreal(out));
            if (overflow | underflow | inexact) begin
                $display("%s%s%s", overflow ? "OVERFLOW " : "",
                         underflow ? "UNDERFLOW " : " ",
                         inexact ? "INEXACT" : "");
            end
        end

        $display("\n\nRANDOM MULTIPLICATION");
        opcode = MUL;
        for (i = 0; i < 10; i++) begin
            a[63:32] = $urandom();
            a[31:0]  = $urandom();
            b[63:32] = $urandom();
            b[31:0]  = $urandom();
            #(DELAY);
            $display("a: %e\nb: %e\na*b: %e", $bitstoreal(a), $bitstoreal(b),
                     $bitstoreal(out));
            if (overflow | underflow | inexact) begin
                $display("%s%s%s", overflow ? "OVERFLOW " : "",
                         underflow ? "UNDERFLOW " : " ",
                         inexact ? "INEXACT" : "");
            end
        end

        $display("\n\nRANDOM DIVISION");
        opcode = DIV;
        for (i = 0; i < 10; i++) begin
            a[63:32] = $urandom();
            a[31:0]  = $urandom();
            b[63:32] = $urandom();
            b[31:0]  = $urandom();
            #(DELAY);
            $display("a: %e\nb: %e\na/b: %e", $bitstoreal(a), $bitstoreal(b),
                     $bitstoreal(out));
            if (overflow | underflow | inexact) begin
                $display("%s%s%s", overflow ? "OVERFLOW " : "",
                         underflow ? "UNDERFLOW " : " ",
                         inexact ? "INEXACT" : "");
            end
        end

        $stop();
    end  // Test

endmodule  // fpu_double_tb
