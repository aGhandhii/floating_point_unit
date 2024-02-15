# Simple Floating Point Unit

A Floating-Point Arithmetic Unit implemented in SystemVerilog

## Main Operations
- [x] Multiplication
    - [x] Handle Over/Underflow appropriately
    - [x] Test for double format
- [x] Division
    - [x] Implement 'inexact' detection
    - [x] Handle Over/Underflow appropriately
    - [x] Test for double format
- [x] Addition + Subtraction
    - [x] Sign Unit
    - [x] Right Shifter
    - [x] Left Shifter (normalization fix)
    - [x] Count Leading Zeros (32 and 64 bit units)
    - [x] Single Precision Unit
    - [x] Double Precision Unit

*Special characters, NaN, and Infinities are not handled in individual units*

*Rounding is implemented by truncation*

## Control Unit
- [x] Detect Zero, Infinity, NaN
- [x] Operation Selection
- [x] Handle Special Input Cases
- [x] Additional Over/Underflow Handling
- [x] Single-Precision
- [ ] Double-Precision
