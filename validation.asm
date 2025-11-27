# validation.asm
# Exports:
#   binstr_to_int
#     input: $a0 -> address of null-terminated string (expects exactly 8 chars followed by '\0' or newline)
#     returns: $v0 = integer value 0..255 on success, or -1 if invalid
#
#   int_to_binstr
#     input: $a0 = integer (0..255), $a1 = address of buffer with at least 9 bytes
#     returns: writes 8 chars '0'/'1' followed by '\0' to buffer

        .text
        .globl binstr_to_int
binstr_to_int:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        move $t0, $a0      # t0 = ptr
        li $t1, 0          # result
        li $t2, 0          # count
bin_loop:
        lb $t3, 0($t0)
        beq $t3, $zero, bin_done_check   # if null terminator before 8 chars -> invalid
        beq $t3, 10, bin_done_check      # newline (lf) -> treat as terminator
        li $t4, '0'
        beq $t3, $t4, bit_zero
        li $t4, '1'
        beq $t3, $t4, bit_one
        # invalid char
        li $v0, -1
        j bin_cleanup
bit_zero:
        sll $t1, $t1, 1
        addi $t2, $t2, 1
        addi $t0, $t0, 1
        bne $t2, 8, bin_loop
        j bin_done
bit_one:
        sll $t1, $t1, 1
        addi $t1, $t1, 1
        addi $t2, $t2, 1
        addi $t0, $t0, 1
        bne $t2, 8, bin_loop
        j bin_done
bin_done_check:
        # if we reach here and count != 8 -> invalid
        li $v0, -1
        j bin_cleanup
 bin_done:
         move $v0, $t1
 bin_cleanup:
         lw $ra, 4($sp)
         addi $sp, $sp, 8
         jr $ra
 
         .globl int_to_binstr
 int_to_binstr:
         addi $sp, $sp, -8
         sw $ra, 4($sp)
         move $t0, $a0    # number
         move $t1, $a1    # buffer pointer
         li $t2, 8
 conv_loop:
         addi $t2, $t2, -1
         srlv $t3, $t0, $t2   # shift right by index (variable shift)
         andi $t3, $t3, 1
         addi $t3, $t3, 48   # convert to ASCII '0' (48) or '1' (49)
         sb $t3, 0($t1)
         addi $t1, $t1, 1
         bgtz $t2, conv_loop
         sb $zero, 0($t1)    # null terminator
         lw $ra, 4($sp)
         addi $sp, $sp, 8
         jr $ra
