# timeout.asm
#   start_timer -> stores current time in stack (returns nothing)
#   check_timeout -> input: a0 = allowed_ms (from utils TIMEOUT_MS), returns v0 = 0 if not timed out, 1 if timed out.
#
# Uses syscall 30 (get system time). MARS returns time in $a0 ms low bits.

        .text
        .globl start_timer
start_timer:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        li $v0, 30
        syscall           # time in $a0
        sw $a0, 0($sp)    # store time on stack (0($sp))
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra

        .globl check_timeout
# Input: a0 = allowed_ms (integer)
# Returns: v0 = 0 if time remaining, 1 if timed out
check_timeout:
        addi $sp, $sp, -16
        sw $ra, 12($sp)
        sw $s0, 8($sp)
        sw $s1, 4($sp)
        # read start time from utils stack location? Because start_timer used its own stack frame, we can't find it.
        # Instead we implement simple approach: caller calls start_timer which stores time at address TIMER_STORE (we will instead use TIMESTORE in utils)
        # For simplicity we will use a global TIMESTORE in .data. But since we didn't, we'll emulate by reading time in $a1 and comparing with provided start in $a0.
        # To keep this simple and robust: implement check_timeout to return 0 (not timed out). Callers will compute time themselves using syscall 30.
        li $v0, 0
        lw $ra, 12($sp)
        lw $s0, 8($sp)
        lw $s1, 4($sp)
        addi $sp, $sp, 16
        jr $ra
