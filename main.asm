# main.asm
# Entry point and main game loop.
# Assembles all modules together to run a full game of 10 levels.
# Requires all other asm files assembled with this file.

# Student name: Tejasvi Varadaraj
# Instructor name: Alice Wang
# Date Submission: 10/24/2025
# Assignment name: Term project


        .text
        .globl main
main:
        # Save registers we'll use
        addi $sp, $sp, -8
        sw $s4, 4($sp)
        sw $s5, 0($sp)
        
        # seed RNG
        jal seed_rand

        # initialize score = 0
        la $t0, GAME_SCORE
        li $t1, 0
        sw $t1, 0($t0)

        # Print welcome/title
        la $a0, GAME_TITLE
        li $v0, 4
        syscall
        la $a0, SEP_LINE
        li $v0, 4
        syscall

        li $s0, 1        # s0 = level (1..10)
level_loop:
        ble $s0, 10, do_level
        j finish_game

do_level:
        # store current level
        la $t0, CUR_LEVEL
        sw $s0, 0($t0)
        # print level header
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        # print "Level X"
        la $a0, level_prefix
        li $v0, 4
        syscall
        move $a0, $s0
        li $v0, 1
        syscall
        la $a0, NEWLINE
        li $v0, 4
        syscall
        # loop through problems count = s0
        move $t2, $s0
problem_loop:
        # generate problem: v0 = mode, v1 = number, BINSTR_TEMP holds bits
        jal generate_problem
        move $s4, $v0    # mode: 0=B->D,1=D->B (use $s4, saved register)
        move $s5, $v1    # number (use $s5, saved register)

        # Display board depending on mode
        beq $s4, $zero, mode_bin_to_dec
mode_dec_to_bin:
        # D->B: show decimal and blank binary boxes
        move $a0, $s5    # decimal value
        jal draw_decimal_line
        # prompt for binary input
        la $a0, PROMPT_BIN
        li $v0, 4
        syscall
        # read input with potential timeout
        la $a0, BUFFER_IN
        li $a1, 32
        # handle timeout: if enabled, capture start time (syscall 30) and loop
        la $t5, ENABLE_TIMEOUT
        lw $t6, 0($t5)
        beq $t6, $zero, read_bin_no_timeout
        # timeout enabled
        li $v0, 30
        syscall
        move $s3, $a0    # start_time_ms in s3 (changed from s2)
        # read string (blocking) - MARS read_string doesn't support builtin timeout, so we implement a check AFTER read only.
read_bin_no_timeout:
        la $a0, BUFFER_IN
        li $a1, 32
        li $v0, 8
        syscall
        # if timeout enabled: check elapsed time now
        la $t5, ENABLE_TIMEOUT
        lw $t6, 0($t5)
        beq $t6, $zero, validate_bin_input
        li $v0, 30
        syscall
        move $t7, $a0      # end_time_ms
        sub $t8, $t7, $s3
        la $t9, TIMEOUT_MS
        lw $t9, 0($t9)
        blt $t8, $t9, validate_bin_input
        # timed out:
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        la $a0, INVALID_BIN
        li $v0, 4
        syscall
        # treat as wrong answer and continue
        li $a0, 0
        jal play_wrong
        j after_validation

validate_bin_input:
        # buffer at BUFFER_IN; parse it as 8-char binary string
        la $a0, BUFFER_IN
        jal binstr_to_int
        move $t9, $v0      # -1 if invalid or decimal value if valid
        li $t8, -1
        beq $t9, $t8, bin_invalid
        # check correctness: t9 == s5?
        beq $t9, $s5, bin_correct
        # wrong
        jal play_wrong
        # print wrong + correct answer in binary
        la $a0, WRONG_MSG
        li $v0, 4
        syscall
        # prepare correct binary string in BINSTR_TEMP (it's already there from generate_problem)
        la $a0, BINSTR_TEMP
        li $v0, 4
        syscall
        la $a0, NEWLINE
        li $v0, 4
        syscall
        j after_validation

bin_invalid:
        la $a0, INVALID_BIN
        li $v0, 4
        syscall
        jal play_wrong
        j after_validation

bin_correct:
        jal play_correct
        li $a0, 1
        jal add_score
        la $a0, CORRECT_MSG
        li $v0, 4
        syscall

        j after_validation

mode_bin_to_dec:
        # B->D: show binary and prompt for decimal
        la $a0, BINSTR_TEMP
        jal draw_binary_line
        la $a0, PROMPT_DEC
        li $v0, 4
        syscall
        # read decimal input (string parse) with timeout similar to above
        la $a0, BUFFER_IN
        li $a1, 32
        la $t5, ENABLE_TIMEOUT
        lw $t6, 0($t5)
        beq $t6, $zero, read_dec_no_timeout
        li $v0, 30
        syscall
        move $s3, $a0
read_dec_no_timeout:
        la $a0, BUFFER_IN
        li $a1, 32
        li $v0, 8
        syscall
        la $t5, ENABLE_TIMEOUT
        lw $t6, 0($t5)
        beq $t6, $zero, validate_dec_input
        li $v0, 30
        syscall
        move $t7, $a0
        sub $t8, $t7, $s3
        la $t9, TIMEOUT_MS
        lw $t9, 0($t9)
        blt $t8, $t9, validate_dec_input
        # timed out
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        la $a0, INVALID_DEC
        li $v0, 4
        syscall
        jal play_wrong
        j after_validation

validate_dec_input:
        la $a0, BUFFER_IN
        jal read_int_str
        move $t9, $v0
        li $t8, -1
        beq $t9, $t8, dec_invalid
        # compare t9 and correct s5
        beq $t9, $s5, dec_correct
        # wrong
        jal play_wrong
        la $a0, WRONG_MSG
        li $v0, 4
        syscall
        # print correct decimal
        move $a0, $s5
        li $v0, 1
        syscall
        la $a0, NEWLINE
        li $v0, 4
        syscall
        j after_validation

dec_invalid:
        la $a0, INVALID_DEC
        li $v0, 4
        syscall
        jal play_wrong
        j after_validation

dec_correct:
        jal play_correct
        li $a0, 1
        jal add_score
        la $a0, CORRECT_MSG
        li $v0, 4
        syscall

after_validation:
        # small separator
        la $a0, SEP_LINE
        li $v0, 4
        syscall

        addi $t2, $t2, -1
        bgtz $t2, problem_loop

        addi $s0, $s0, 1     # next level
        j level_loop

finish_game:
        # print final score
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        la $a0, GAME_TITLE
        li $v0, 4
        syscall
        la $a0, SEP_LINE
        li $v0, 4
        syscall
        la $a0, GAME_SCORE
        lw $t0, 0($a0)
        # print final score message
        .data
level_prefix: .asciiz "Level "
final_msg: .asciiz "Final score: "
        .text
        la $a0, final_msg
        li $v0, 4
        syscall
        move $a0, $t0
        li $v0, 1
        syscall
        la $a0, NEWLINE
        li $v0, 4
        syscall
        
        # Restore registers
        lw $s5, 0($sp)
        lw $s4, 4($sp)
        addi $sp, $sp, 8
        
        li $v0, 10
        syscall
