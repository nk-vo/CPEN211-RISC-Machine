#include <stdio.h>

void sort(int *A, int n)
{
  for(int i=1; i<n; i++) {
    for(int j=0; j<i; j++) {
      if(A[j] > A[i]) { 
        int tmp = A[j]; // swap A[i] and A[j]
        A[j] = A[i];
        A[i] = tmp;
      }
    }
  }
}

int foo[] = {7,1,90,3,100,8,9,-1,120,50};

int main(void) {
  int N = sizeof(foo)/sizeof(int);
  sort(foo,N);
  for(int i=0; i<N; i++) {
    printf("foo[%d] = %d\n", i, foo[i]);
  }
  return 0;
}
