# generate_problem.asm
# API:
#   generate_problem
#     Inputs: none
#     Behavior: choose problem mode and problem number.
#     Outputs (via registers and memory):
#       $v0 = mode (0 = B->D, 1 = D->B)
#       $v1 = integer number (0..255)
#       Also writes binary string (8 chars + null) to BINSTR_TEMP (label in utils.asm)
#
# Uses get_rand (randgen.asm). On success returns to caller.
# Note: In MARS, .extern is not needed - all .globl symbols are automatically shared

        .text
        .globl generate_problem
generate_problem:
        addi $sp, $sp, -16
        sw $ra, 12($sp)
        sw $s0, 8($sp)
        sw $s1, 4($sp)
        # pick mode: 0 or 1
        li $a0, 2
        jal get_rand
        move $s0, $v0   # save mode in s0 (0 or 1)
        # generate number 0..255
        li $a0, 256
        jal get_rand
        move $s1, $v0   # save number in s1
        # create binary string for number at BINSTR_TEMP
        la $a1, BINSTR_TEMP
        move $a0, $s1
        jal int_to_binstr
        # return: v0=mode, v1=number, BINSTR_TEMP filled
        move $v0, $s0   # return mode in v0
        move $v1, $s1   # return number in v1
        lw $s1, 4($sp)
        lw $s0, 8($sp)
        lw $ra, 12($sp)
        addi $sp, $sp, 16
        jr $ra
