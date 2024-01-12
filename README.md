# Simple Floating Point Unit

A basic Floating-Point arithmetic unit implemented in SystemVerilog


## Main Goals
- [x] Multiplication
    - [ ] Handle Over/Underflow appropriately
    - [ ] Test for double format
- [ ] Division
- [ ] Simple Addition
- [ ] Simple Subtraction

*Special characters, NaN, and Infinities will not be initially handled*
 - This will be implemented in a separate control unit once main arithmetic units are established

*Rounding will be implemented by trunctation, if digits are lost a control signal will be raised*
