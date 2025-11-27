# input.asm

        .text
        .globl read_line
read_line:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        # $a0 = buffer, $a1 = length
        li $v0, 8
        syscall
        # syscall 8 returns buffer filled; ensure null termination exists (MARS does)
        move $v0, $a0
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra

        .globl read_int_str
read_int_str:
        addi $sp, $sp, -16
        sw $ra, 12($sp)
        sw $s0, 8($sp)
        sw $s1, 4($sp)
        move $s0, $a0       # buffer
        li $a1, 32
        move $a0, $s0
        li $v0, 8
        syscall             # read_string(buffer, 32)
        # parse decimal: allow optional leading spaces and +/- (but we enforce 0..255)
        move $t0, $s0
        li $t1, 0           # value
parse_loop:
        lb $t2, 0($t0)
        beq $t2, $zero, parse_done
        beq $t2, 10, parse_done    # newline
        blt $t2, '0', parse_next
        bgt $t2, '9', parse_next
        # digit
        addi $t2, $t2, -48
        mul $t1, $t1, 10
        add $t1, $t1, $t2
parse_next:
        addi $t0, $t0, 1
        j parse_loop
parse_done:
        # check range 0..255
        li $t3, 0
        li $t4, 255
        blt $t1, $t3, parse_invalid
        bgt $t1, $t4, parse_invalid
        move $v0, $t1
        j parse_return
parse_invalid:
        li $v0, -1
parse_return:
        lw $ra, 12($sp)
        lw $s0, 8($sp)
        lw $s1, 4($sp)
        addi $sp, $sp, 16
        jr $ra
