.global _start
_start:
    MOV R0, #2 // n=2
    LDR R1, =input // base of A = first address of array “input”
    LDR R2, =output// base of B = first address of array “output”
    BL loopy
END: B END // infinite loop; R0 should contain return value of loopy

.global loopy
loopy:
 // ADD YOUR CODE HERE
    MOV R4, #0 // move value 0 into L1norm
    MOV R5, #0 // move value 0 into i

WHILE:
    CMP R5, R0  // compare i and n
    BGE DONE
    LDR R6, [R1, R5, LSL#2] // load A[i] into tmp (R6)

    CMP R6, #0  // compare r6 and 0
    BGE CONTINUE
    MOV R7, #0  // move 0 to r7
    SUB R6, R7, R6 // tmp = 0 - tmp

CONTINUE:
    STR R6, [R2, R5, LSL#2] // store tmp into B[i]
    ADD R4, R4, R6 // L1norm = L1norm + tmp
    ADD R5, R5, #1 // i = i + 1
    B WHILE

DONE:
    MOV R0, R4  // return L1norm
    MOV PC, LR

input:
    .word -1
    .word 1
output:
    .word 0
    .word 0