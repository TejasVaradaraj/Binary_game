# utils.asm
# Shared data and small helpers used by multiple modules.
# Contains runtime configuration flags for extra features.


        .data
        .globl GAME_TITLE
        .globl GAME_SCORE
        .globl CUR_LEVEL
        .globl ENABLE_GRAPHICS
        .globl ENABLE_SOUND
        .globl ENABLE_TIMEOUT
        .globl TIMEOUT_MS
        .globl BUFFER_IN
        .globl BINBUF
        .globl BINSTR_TEMP
        .globl DECSTR_TEMP
        .globl NEWLINE
        .globl SEP_LINE
        .globl PROMPT_DEC
        .globl PROMPT_BIN
        .globl INVALID_BIN
        .globl INVALID_DEC
        .globl CORRECT_MSG
        .globl WRONG_MSG

GAME_TITLE:     .asciiz "Binary Game (MARS MIPS) - Binary <-> Decimal Conversion\n"
GAME_SCORE:     .word 0
CUR_LEVEL:      .word 1

# Extra-credit toggles - change these values here before assembling to enable/disable features.
ENABLE_GRAPHICS:    .word 1   # 1 = fancy ASCII board, 0 = minimal
ENABLE_SOUND:       .word 1   # 0 = no sound, 1 = ASCII bell, 2 = MIDI (requires uncommenting MIDI code in sound.asm)
ENABLE_TIMEOUT:     .word 0   # 1 = timeout enabled, 0 = disabled (DISABLED by default for easier testing)
TIMEOUT_MS:         .word 15000  # 15000 ms = 15 seconds timeout per question

BUFFER_IN:      .space 64    # input buffer (read_string)
BINBUF:         .space 12    # buffer for 8-bit binary + newline + null
BINSTR_TEMP:    .space 12
DECSTR_TEMP:    .space 12

NEWLINE:        .asciiz "\n"
SEP_LINE:       .asciiz "--------------------------------------------------------------\n"

# small format strings
PROMPT_DEC:     .asciiz "Enter decimal (0-255): "
PROMPT_BIN:     .asciiz "Enter 8 bits (MSB->LSB, e.g. 01010101): "
INVALID_BIN:    .asciiz "Invalid binary input. Must be exactly 8 chars of 0 or 1.\n"
INVALID_DEC:    .asciiz "Invalid decimal input. Must be integer 0..255.\n"
CORRECT_MSG:    .asciiz "Correct!\n"
WRONG_MSG:      .asciiz "Incorrect. Correct answer: "

        .text
# helper: print_string (a0 -> address)
# returns: none
# clobbers: v0 only
        .globl print_string
print_string:
        li $v0, 4
        syscall
        jr $ra

# helper: print_int (a0 -> integer)
# returns: none
        .globl print_int
print_int:
        li $v0, 1
        syscall
        jr $ra

# helper: print_char (a0 -> char)
        .globl print_char
print_char:
        li $v0, 11
        syscall
        jr $ra

# helper: newline
        .globl newline
newline:
        la $a0, NEWLINE
        li $v0, 4
        syscall
        jr $ra
