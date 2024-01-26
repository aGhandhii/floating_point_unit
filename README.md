# Simple Floating Point Unit

A Floating-Point Arithmetic Unit implemented in SystemVerilog


## Main Goals
- [x] Multiplication
    - [x] Handle Over/Underflow appropriately
    - [ ] Test for double format
    - [ ] Expand unit tests
- [x] Division
    - [ ] Implement 'inexact' detection
    - [x] Handle Over/Underflow appropriately
    - [ ] Test for double format
    - [ ] Expand unit tests
- [ ] Addition + Subtraction
    - [ ] Sign Unit
    - [ ] Right Shifter
    - [ ] Left Shifter (normalization fix)
    - [x] Count Leading Zeros (32 and 64 bit units)

*Special characters, NaN, and Infinities will not be initially handled*
 - This will be implemented in a separate control unit once main arithmetic units are established

*Rounding will be implemented by trunctation, if digits are lost a control signal will be raised*
