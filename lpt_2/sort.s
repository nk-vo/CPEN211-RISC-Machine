.global _start
_start:
  LDR R0,=foo
  MOV R1,#10
  BL sort
END: B END

sort:  // R0 is A, R1 is n
//void sort(int *A, int n)
// {
//  for(int i=1; 
  MOV R2, #1 // R2 is i

LOOP_L1:
//  i<n; 
  CMP R2, R1 
  BGE EXIT
  
  //  for(int j=0; 
  MOV R3, #0 // j in R3
  
LOOP_L2:  
  //j<i; 
  CMP R3, R2
  BGE EXIT_L2
  
//      if(A[j] > A[i]) {
  LDR R4, [R0, R3, LSL #2] // R4 is A[j]
  LDR R5, [R0, R2, LSL #2] // R5 is A[i]
  CMP R4, R5
  BLE LABEL
 //       int tmp = A[j]; // swap A[i] and A[j]
 //       A[j] = A[i];
  STR R5, [R0, R3, LSL #2]
 //       A[i] = tmp;
  STR R4, [R0, R2, LSL #2]
 //     }
LABEL:
  ADD R3, R3, #1
	//    j++) {
   // }
  B LOOP_L2
EXIT_L2:	
  ADD R2, R2, #1
	// i++) {
 // }
  B LOOP_L1
EXIT:  
//}
  MOV PC, LR


foo:
  .word 7
  .word 1
  .word 90
  .word 3
  .word 100
  .word 8
  .word 9
  .word -1
  .word 120
  .word 50
  
	