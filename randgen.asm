# randgen.asm

# Implementation notes:
#   Uses MARS syscalls:
#     30 -> give system time in a0
#     40 -> set seed (a0 = gen id, a1 = seed)
#     42 -> random (a0 = gen id, a1 = upper bound) -> returns value in a0

        .text
        .globl seed_rand
seed_rand:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        # get system time (milliseconds low bits)
        li $v0, 30
        syscall            # result in $a0
        move $t0, $a0
        # set seed for generator id 1
        li $a0, 1
        move $a1, $t0
        li $v0, 40
        syscall
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra

        .globl get_rand
# input: $a0 = upper_bound
# returns: $v0 = random integer in [0, upper_bound)
get_rand:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        # Save incoming upper bound FIRST before we overwrite $a0
        move $t2, $a0         # save upper bound in t2
        # Now set up syscall 42 arguments
        li $a0, 1             # generator id = 1
        move $a1, $t2         # upper bound
        li $v0, 42            # syscall 42: random int
        syscall               # random returned in $a0
        move $v0, $a0         # return value
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra
