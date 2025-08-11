# ALU_64 - 64-Bit Arithmetic Logic Unit

A comprehensive 64-bit Arithmetic Logic Unit (ALU) implementation in Verilog featuring advanced arithmetic operations, logical operations, and a high-performance Dadda multiplier.


## Features

### Core Operations
- **Arithmetic Operations**: Addition, Subtraction, Multiplication, Division, Remainder
- **Logical Operations**: AND, OR, XOR
- **Shift Operations**: Logical Left Shift (SLL), Logical Right Shift (SRL), Arithmetic Right Shift (SRA)
- **Comparison Operations**: Set Less Than Unsigned (SLTU), Branch comparisons (BEQ, BNE, BLT, BGE, BLTU, BGEU)
- **Special Operations**: Load Upper Immediate (LUI)

### Advanced Components
- **64-bit Carry Select Adder**: Optimized addition with parallel carry computation
- **64x64 Dadda Multiplier**: Hierarchical multiplier using Carry Save Adders (CSA)
- **Comprehensive Testing**: Built-in testbench with stimulus generation and result verification

## Architecture

### Main ALU Module (`alu_64.v`)
The core ALU module that orchestrates all operations:
- **Inputs**: 5-bit opcode, 64-bit operands A and B
- **Outputs**: 64-bit result Y, carry flag, zero flag
- **Operation Selection**: Case-based operation selection using 5-bit opcodes

### Carry Select Adder (`csel_64.v`)
Implements a 64-bit carry select adder using:
- **Full Adders (FA)**: Basic 1-bit addition with carry
- **4-bit Ripple Carry Adders (RCA4)**: Building blocks for larger adders
- **Multiplexers**: Select between carry-in scenarios (0 and 1)
- **Hierarchical Structure**: 16 stages of 4-bit adders with carry selection

### Dadda Multiplier (`dadda_64.v`)
Hierarchical multiplier implementation:
- **8x8 Base Multiplier**: Foundation using partial product generation and CSA reduction
- **16x16 Multiplier**: Built from four 8x8 multipliers
- **32x32 Multiplier**: Built from four 16x16 multipliers  
- **64x64 Multiplier**: Built from four 32x32 multipliers
- **Carry Save Adders (CSA)**: Efficient 3:2 reduction stages
- **Half Adders (HA)**: Final 2:1 reduction

### Test Infrastructure
- **ALU Stimulus (`alu_stimulus.v`)**: Generates test vectors for all operations
- **ALU Monitor (`alu_monitor.v`)**: Verifies results and displays pass/fail status
- **Dadda Testbench (`dadda_tb.v`)**: Tests multiplication operations

## Operation Codes

| Opcode | Operation | Description |
|--------|-----------|-------------|
| 5'b00000 | ADD | Addition (A + B) |
| 5'b00001 | SUB | Subtraction (A - B) |
| 5'b00010 | SLL | Logical Left Shift (A << B) |
| 5'b00011 | BXOR | Bitwise XOR (A ^ B) |
| 5'b00100 | SRL | Logical Right Shift (A >> B) |
| 5'b00101 | SRA | Arithmetic Right Shift |
| 5'b00110 | BOR | Bitwise OR (A \| B) |
| 5'b00111 | BAND | Bitwise AND (A & B) |
| 5'b01000 | SLTU | Set Less Than Unsigned |
| 5'b01001 | BNE | Branch if Not Equal |
| 5'b01010 | BEQ | Branch if Equal |
| 5'b01011 | LUI | Load Upper Immediate |
| 5'b01100 | MUL | Multiplication (lower 64 bits) |
| 5'b01101 | BLT | Branch if Less Than (signed) |
| 5'b01110 | BGE | Branch if Greater or Equal (signed) |
| 5'b01111 | MULHU | Multiplication (upper 64 bits, unsigned) |
| 5'b10000 | BLTU | Branch if Less Than (unsigned) |
| 5'b10001 | BGEU | Branch if Greater or Equal (unsigned) |
| 5'b10010 | DIV | Division (A / B) |
| 5'b10100 | REM | Remainder (A % B) |

## Performance Features

### Carry Select Adder
- **Parallel Carry Computation**: Computes results for both carry-in scenarios simultaneously
- **Fast Addition**: Reduces critical path compared to ripple carry adders
- **Modular Design**: 4-bit blocks for easy scaling and optimization

### Dadda Multiplier
- **Efficient Reduction**: Multi-stage CSA reduction for optimal performance
- **Hierarchical Structure**: Scalable from 8x8 to 64x64 bits
- **Carry Save Architecture**: Minimizes carry propagation delays

## Testing

### Simulation
The project includes comprehensive testbenches:
- **Operation Coverage**: Tests all 20 ALU operations
- **Edge Cases**: Includes signed/unsigned comparisons and large number operations
- **Result Verification**: Automatic pass/fail checking with expected vs. actual results

### Test Vectors
- Arithmetic operations with various operand sizes
- Logical operations with different bit patterns
- Shift operations with varying shift amounts
- Comparison operations with signed and unsigned values
- Multiplication with both small and large numbers

## File Structure

```
ALU_64/
├── alu_64.v          # Main ALU module
├── csel_64.v         # Carry Select Adder implementation
├── dadda_64.v        # Dadda multiplier hierarchy
├── alu_stimulus.v    # Test stimulus generation
├── alu_monitor.v     # Result verification and monitoring
├── dadda_tb.v        # Multiplier testbench
└── README.md          # This documentation
```


## Design Considerations

### Performance Optimizations
- **Carry Select Logic**: Reduces addition latency
- **CSA Reduction**: Efficient multiplication with minimal carry propagation
- **Hierarchical Design**: Scalable architecture for different bit widths

### Area vs. Speed Trade-offs
- **Carry Select Adder**: Increased area for improved speed
- **Dadda Multiplier**: Optimized for speed with reasonable area overhead
- **Modular Components**: Reusable building blocks for different configurations

## Future Enhancements

- **Floating Point Support**: Integration with FPU for floating-point operations
- **Pipeline Implementation**: Multi-stage pipeline for higher throughput
- **SIMD Operations**: Vector processing capabilities
- **Power Optimization**: Clock gating and power-aware design



---


divider = not implemented yet
