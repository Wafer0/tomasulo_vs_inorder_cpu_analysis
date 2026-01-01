# Tomasulo vs In-Order 5-Stage CPU Analysis

**Author:** Andreas Tzitzikas

This directory contains comparative analysis between two RISC-V RV32I CPU implementations:

- **Tomasulo CPU**: Out-of-order execution using Tomasulo's Algorithm
- **In-Order CPU**: Traditional 5-stage pipeline architecture

## Directory Structure

```
tomasulo_vs_inorder_analysis/
├── compare_cpu_ipc.sh      # Automated IPC benchmarking script
├── compile_report.sh       # Script to compile LaTeX report
├── report.tex             # LaTeX report template
├── ipc_results.tex        # IPC comparison results (LaTeX table)
└── README.md              # This file
```

## Quick Start

### Run Performance Comparison

```bash
./compare_cpu_ipc.sh
```

This will:
- Run all test programs in benchmark mode for both CPUs
- Extract IPC (Instructions Per Cycle) measurements
- Display detailed performance comparisons
- Show overall winner analysis

### Generate LaTeX Report

```bash
./compile_report.sh
```

Or manually:
```bash
pdflatex report.tex
```

Requires LaTeX installation with the following packages:
- geometry
- graphicx
- booktabs
- siunitx
- xcolor
- hyperref

## Test Programs Analyzed

| Program | Description |
|---------|-------------|
| test01_basic_arithmetic | ADD/ADDI operations |
| test02_logic_operations | AND/OR/XOR operations |
| test03_shifts | SLL/SRL/SRA operations |
| test06_memory_ops | LW/SW operations |
| test07_branches | BEQ/BNE/BLT/etc. operations |
| test08_jumps | JAL/JALR operations |
| benchmark | Comprehensive benchmark |

## Performance Results Summary

Based on IPC measurements across 7 test programs:

- **Tomasulo CPU** excels at:
  - Logic operations (higher ILP)
  - Branch-intensive code
  - Complex instruction sequences

- **In-Order CPU** performs better at:
  - Simple sequential programs
  - Jump operations
  - Minimal overhead for basic operations

- **Overall**: Tomasulo shows advantage for workloads benefiting from out-of-order execution

## CPU Specifications

### Tomasulo CPU
- **Architecture**: Out-of-order execution
- **Reservation Stations**: 8 entries
- **Reorder Buffer**: 16 entries
- **Register Renaming**: Full RAT implementation
- **Branch Support**: Speculative execution

### In-Order CPU
- **Architecture**: 5-stage pipeline (IF/ID/EX/MEM/WB)
- **Hazard Resolution**: Stall-based
- **Forwarding**: Limited implementation
- **Branch Support**: Pipeline flush

## Synthesis Results

Both CPUs have been synthesized for Sky130 130nm technology:

- **Technology**: Sky130 130nm open-source PDK
- **Target Frequency**: 50 MHz
- **DRC/LVS**: All checks pass
- **Timing**: Meets constraints

## Future Enhancements

- Add more sophisticated branch prediction
- Implement memory hierarchy analysis
- Power consumption measurements
- Additional benchmark suites
- Hardware complexity analysis

## Scripts

### compare_cpu_ipc.sh
Automated benchmarking script that:
- Runs all tests in benchmark mode
- Extracts performance statistics
- Generates comparative analysis
- Produces winner determination

### LaTeX Report Generation
The `report.tex` file provides a template for generating professional PDF reports with:
- Performance comparison tables
- Architectural analysis
- Synthesis results
- Conclusions and future work

## Contributing

To extend this analysis:
1. Add new test programs to both CPU directories
2. Update expected outputs in `test/expected/`
3. Run `./compare_cpu_ipc.sh` to update results
4. Modify `ipc_results.tex` with new data
5. Regenerate LaTeX report

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Academic Integrity

This analysis is for educational purposes, demonstrating the performance trade-offs between different CPU architectures and the benefits of out-of-order execution techniques.
