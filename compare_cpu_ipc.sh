#!/bin/bash
# CPU IPC Comparison Script
# Compares IPC (Instructions Per Cycle) performance across Tomasulo and In-Order CPUs

TOMASULO_DIR="../risk-v-32-bit-tomasulo-cpu"
INORDER_DIR="../risk-v-32-bit-inorder-5-stage-cpu"

TEST_PROGRAMS="test01_basic_arithmetic test02_logic_operations test03_shifts test06_memory_ops test07_branches test08_jumps benchmark"

echo "================================================================="
echo "         RISC-V CPU IPC Performance Comparison"
echo "================================================================="
echo ""
echo "Running benchmark mode tests for both CPUs..."
echo ""

# Arrays to store results
declare -A tomasulo_cycles
declare -A tomasulo_instructions
declare -A tomasulo_ipc
declare -A inorder_cycles
declare -A inorder_instructions
declare -A inorder_ipc

# Test Tomasulo CPU
echo "Testing Tomasulo CPU..."
echo "-----------------------"
cd "$TOMASULO_DIR" || exit 1

for test in $TEST_PROGRAMS; do
    echo "Running $test..."
    OUTPUT=$(./scripts/simulate "$test" benchmark 2>&1)

    # Extract cycles and instructions from output (take the first match)
    CYCLES=$(echo "$OUTPUT" | grep "STATS: Cycles:" | head -1 | sed 's/.*Cycles: \([0-9]*\).*/\1/' | tr -d '\n' | tr -d ' ')
    INSTRUCTIONS=$(echo "$OUTPUT" | grep "STATS: Instructions:" | head -1 | sed 's/.*Instructions: \([0-9]*\).*/\1/' | tr -d '\n' | tr -d ' ')

    if [ -n "$CYCLES" ] && [ -n "$INSTRUCTIONS" ] && [ "$CYCLES" -gt 0 ]; then
        IPC=$(echo "scale=4; $INSTRUCTIONS / $CYCLES" | bc -l 2>/dev/null || echo "0")
        tomasulo_cycles[$test]=$CYCLES
        tomasulo_instructions[$test]=$INSTRUCTIONS
        tomasulo_ipc[$test]=$IPC
    else
        tomasulo_cycles[$test]="N/A"
        tomasulo_instructions[$test]="N/A"
        tomasulo_ipc[$test]="N/A"
    fi
done

# Return to analysis directory
cd "$OLDPWD" || cd ..

# Test In-Order CPU
echo ""
echo "Testing In-Order CPU..."
echo "----------------------"
cd "$INORDER_DIR" || exit 1

for test in $TEST_PROGRAMS; do
    echo "Running $test..."
    OUTPUT=$(./scripts/simulate "$test" benchmark 2>&1)

    # Extract cycles and instructions from output (take the first match)
    CYCLES=$(echo "$OUTPUT" | grep "STATS: Cycles:" | head -1 | sed 's/.*Cycles: \([0-9]*\).*/\1/' | tr -d '\n' | tr -d ' ')
    INSTRUCTIONS=$(echo "$OUTPUT" | grep "STATS: Instructions:" | head -1 | sed 's/.*Instructions: \([0-9]*\).*/\1/' | tr -d '\n' | tr -d ' ')

    if [ -n "$CYCLES" ] && [ -n "$INSTRUCTIONS" ] && [ "$CYCLES" -gt 0 ]; then
        IPC=$(echo "scale=4; $INSTRUCTIONS / $CYCLES" | bc -l 2>/dev/null || echo "0")
        inorder_cycles[$test]=$CYCLES
        inorder_instructions[$test]=$INSTRUCTIONS
        inorder_ipc[$test]=$IPC
    else
        inorder_cycles[$test]="N/A"
        inorder_instructions[$test]="N/A"
        inorder_ipc[$test]="N/A"
    fi
done

# Return to analysis directory
cd "$OLDPWD" || cd ..

# Display results
echo ""
echo "================================================================="
echo "                        IPC COMPARISON RESULTS"
echo "================================================================="
echo ""
printf "%-25s | %-12s | %-12s | %-12s | %-12s\n" "Test Program" "Tomasulo IPC" "In-Order IPC" "Difference" "Winner"
printf "%-25s | %-12s | %-12s | %-12s | %-12s\n" "---------------------------" "------------" "------------" "------------" "------"
echo ""

total_tomasulo_ipc=0
total_inorder_ipc=0
valid_tests=0

for test in $TEST_PROGRAMS; do
    t_ipc=${tomasulo_ipc[$test]}
    i_ipc=${inorder_ipc[$test]}

    if [ "$t_ipc" != "N/A" ] && [ "$i_ipc" != "N/A" ]; then
        # Calculate difference
        diff=$(echo "scale=4; $t_ipc - $i_ipc" | bc -l 2>/dev/null || echo "0")

        # Determine winner
        if (( $(echo "$t_ipc > $i_ipc" | bc -l 2>/dev/null) )); then
            winner="Tomasulo"
        elif (( $(echo "$i_ipc > $t_ipc" | bc -l 2>/dev/null) )); then
            winner="In-Order"
        else
            winner="Tie"
        fi

        # Format difference
        if (( $(echo "$diff >= 0" | bc -l 2>/dev/null) )); then
            diff_str="+${diff}"
        else
            diff_str="${diff}"
        fi

        total_tomasulo_ipc=$(echo "scale=4; $total_tomasulo_ipc + $t_ipc" | bc -l 2>/dev/null || echo "$total_tomasulo_ipc")
        total_inorder_ipc=$(echo "scale=4; $total_inorder_ipc + $i_ipc" | bc -l 2>/dev/null || echo "$total_inorder_ipc")
        valid_tests=$((valid_tests + 1))
    else
        diff_str="N/A"
        winner="N/A"
    fi

    printf "%-25s | %-12s | %-12s | %-12s | %-12s\n" "$test" "${t_ipc:-N/A}" "${i_ipc:-N/A}" "${diff_str:-N/A}" "${winner:-N/A}"
done

echo ""
printf "%-25s | %-12s | %-12s | %-12s | %-12s\n" "---------------------------" "------------" "------------" "------------" "------"

# Calculate averages
if [ $valid_tests -gt 0 ]; then
    avg_tomasulo=$(echo "scale=4; $total_tomasulo_ipc / $valid_tests" | bc -l 2>/dev/null || echo "N/A")
    avg_inorder=$(echo "scale=4; $total_inorder_ipc / $valid_tests" | bc -l 2>/dev/null || echo "N/A")

    avg_diff=$(echo "scale=4; $avg_tomasulo - $avg_inorder" | bc -l 2>/dev/null || echo "N/A")

    if (( $(echo "$avg_tomasulo > $avg_inorder" | bc -l 2>/dev/null 2>/dev/null) )); then
        avg_winner="Tomasulo"
    elif (( $(echo "$avg_inorder > $avg_tomasulo" | bc -l 2>/dev/null 2>/dev/null) )); then
        avg_winner="In-Order"
    else
        avg_winner="Tie"
    fi

    if (( $(echo "$avg_diff >= 0" | bc -l 2>/dev/null 2>/dev/null) )); then
        avg_diff_str="+${avg_diff}"
    else
        avg_diff_str="${avg_diff}"
    fi

    echo ""
    printf "%-25s | %-12s | %-12s | %-12s | %-12s\n" "AVERAGE ($valid_tests tests)" "${avg_tomasulo:-N/A}" "${avg_inorder:-N/A}" "${avg_diff_str:-N/A}" "${avg_winner:-N/A}"
fi

echo ""
echo "================================================================="
echo "                        PERFORMANCE ANALYSIS"
echo "================================================================="
echo ""

# Count wins
tomasulo_wins=0
inorder_wins=0
ties=0

for test in $TEST_PROGRAMS; do
    t_ipc=${tomasulo_ipc[$test]}
    i_ipc=${inorder_ipc[$test]}

    if [ "$t_ipc" != "N/A" ] && [ "$i_ipc" != "N/A" ]; then
        if (( $(echo "$t_ipc > $i_ipc" | bc -l 2>/dev/null) )); then
            tomasulo_wins=$((tomasulo_wins + 1))
        elif (( $(echo "$i_ipc > $t_ipc" | bc -l 2>/dev/null) )); then
            inorder_wins=$((inorder_wins + 1))
        else
            ties=$((ties + 1))
        fi
    fi
done

echo "Performance Summary:"
echo "  Tomasulo CPU wins: $tomasulo_wins tests"
echo "  In-Order CPU wins: $inorder_wins tests"
echo "  Ties: $ties tests"
echo ""

if [ $tomasulo_wins -gt $inorder_wins ]; then
    echo "🏆 OVERALL WINNER: Tomasulo CPU (Out-of-Order execution shows better IPC)"
elif [ $inorder_wins -gt $tomasulo_wins ]; then
    echo "🏆 OVERALL WINNER: In-Order CPU (Pipeline efficiency shines)"
else
    echo "🤝 TIE: Both CPUs show similar performance"
fi

echo ""
echo "================================================================="
echo "Test completed at: $(date)"
echo "================================================================="
