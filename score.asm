# score.asm


        .text
        .globl add_score
add_score:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        la $t0, GAME_SCORE
        lw $t1, 0($t0)
        add $t1, $t1, $a0
        sw $t1, 0($t0)
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra

        .globl print_score
print_score:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        la $a0, GAME_SCORE
        lw $t0, 0($a0)
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        la $a0, GAME_TITLE
        li $v0, 4
        syscall
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        la $a0, CORRECT_MSG   # temporary reuse: this exists in utils; but we'll print "Score: "
        # Instead print "Score: " then int
        la $a0, CORRECT_MSG
        li $v0, 4
        syscall
        # print score integer
        move $a0, $t0
        jal print_int
        la $a0, NEWLINE
        li $v0, 4
        syscall
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra
