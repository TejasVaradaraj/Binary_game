

        .text
        .globl draw_binary_line
draw_binary_line:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        sw $s0, 0($sp)
        la $t0, ENABLE_GRAPHICS
        lw $t1, 0($t0)
        move $s0, $a0    # save bits pointer
        beq $t1, $zero, minimal_draw_bin
        # fancy draw
        # print top border for 8 boxes + decimal slot
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        # Print bits row
        li $t2, 0
        move $t3, $s0    # pointer to bits buffer passed in a0
        # If caller passed 0, use BINSTR_TEMP pointer (safety)
        beq $t3, $zero, use_temp_bin
print_bits_loop:
        lb $t4, 0($t3)
        beq $t4, $zero, print_bits_done
        # print '| ' then char then ' '
        li $v0, 11
        li $a0, '|'
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        li $v0, 11
        move $a0, $t4
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        addi $t3, $t3, 1
        addi $t2, $t2, 1
        blt $t2, 8, print_bits_loop
        j print_bits_done
use_temp_bin:
        la $t3, BINSTR_TEMP
        j print_bits_loop
print_bits_done:
        # print final |
        li $v0, 11
        li $a0, '|'
        syscall
        # newline
        la $a0, NEWLINE
        li $v0, 4
        syscall
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        j draw_done

minimal_draw_bin:
        # minimal: print the 8 bits inline and a prompt
        move $a0, $s0
        beqz $a0, use_binstr_temp_minimal
        li $v0, 4
        syscall
        j draw_done
use_binstr_temp_minimal:
        la $a0, BINSTR_TEMP
        li $v0, 4
        syscall

draw_done:
        lw $s0, 0($sp)
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra

        .globl draw_decimal_line
draw_decimal_line:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        sw $s0, 0($sp)
        move $s0, $a0    # save decimal value
        # Print decimal at left and 8 blank boxes
        la $t0, ENABLE_GRAPHICS
        lw $t1, 0($t0)
        beq $t1, $zero, minimal_draw_dec
        # fancy draw
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        # print 8 blank boxes
        li $t2, 0
print_blank_loop:
        bge $t2, 8, print_blank_done
        li $v0, 11
        li $a0, '|'
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        li $v0, 11
        li $a0, '_'
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        addi $t2, $t2, 1
        j print_blank_loop
print_blank_done:
        # print final |
        li $v0, 11
        li $a0, '|'
        syscall
        # print = and decimal value
        li $v0, 11
        li $a0, ' '
        syscall
        li $v0, 11
        li $a0, '='
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        move $a0, $s0
        li $v0, 1
        syscall
        la $a0, NEWLINE
        li $v0, 4
        syscall
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        j draw_dec_done

minimal_draw_dec:
        # minimal: print "Decimal: X"
        la $a0, dec_prompt
        li $v0, 4
        syscall
        move $a0, $s0
        li $v0, 1
        syscall
        la $a0, NEWLINE
        li $v0, 4
        syscall

draw_dec_done:
        lw $s0, 0($sp)
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra
        
        .data
dec_prompt: .asciiz "Decimal: "
