.global _start
_start:
    MOV R0, #1 // i=1
    MOV R1, #2 // j=2
    MOV R2, #1 // k=1
    LDR R3, =data // set base of A = first address of array “data”
    BL func
END: B END // infinite loop; R0 should contain return value of func

.global func
func:
    CMP R0, R1  // compare i and j
    BGE IF1
    MOV R4, #1  // store value 1 into r4
    STR R4, [R3] // store value 1 into A[0]

IF1:
    CMP R0, R2  // compare i and k
    BNE DONE
    MOV R5, #2  // store value 2 into r5
    STR R5, [R3, R4, LSL #2]    // store value 2 into A[1]
    LDR R6, [R3, R5, LSL #2]    // load A[2] into r6
    CMP R6, R1  // compare A[2] and j
    BLE DONE
    MOV R4, #3  // overwrite value 3 into r4
    MOV R5, #4  // overwrite value 4 into r5
    STR R5, [R3, R4, LSL #2]    // store value 4 into A[3]
    // A will be [1,2,3,4]
DONE:
    ADD R0, R0, R1  // add i and j
    MOV PC, LR  // return
data:
    .word 0
    .word 0
    .word 3
    .word 0