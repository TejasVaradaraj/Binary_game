# sound.asm
# Implementation:
#   - By default uses ASCII bell '\a' printed to console for compatibility with MARS.
#   - Optional MIDI code (commented) is provided if you want to enable true MIDI in MARS (set ENABLE_SOUND = 2 in utils.asm and uncomment code).


        .text
        .globl play_correct
play_correct:
        # check ENABLE_SOUND flag
        la $t0, ENABLE_SOUND
        lw $t1, 0($t0)
        beq $t1, $zero, play_no_sound
        li $t2, 1
        beq $t1, $t2, play_ascii_bell
        # if >=2, attempt MIDI (commented fallback)
        # For compatibility, fall back to ascii bell
play_ascii_bell:
        li $a0, 7        # ASCII BEL = 7
        li $v0, 11
        syscall
        jr $ra

play_no_sound:
        jr $ra

        .globl play_wrong
play_wrong:
        # ascii lower beep: print bell twice quickly
        la $t0, ENABLE_SOUND
        lw $t1, 0($t0)
        beq $t1, $zero, play_no_sound2
        li $a0, 7
        li $v0, 11
        syscall
        li $a0, 7
        li $v0, 11
        syscall
        jr $ra
play_no_sound2:
        jr $ra

# Optional MIDI example (commented out - uncomment if you want MIDI and set ENABLE_SOUND=2)
#        li $v0, 31
#        li $a0, 60    # MIDI note number (middle C)
#        li $a1, 200   # duration
#        syscall
#        jr $ra
