#include "stdio.h"
//#include "string.h"

int max(int x, int y){
    int z;
    if(x>y){
        z = x;
    } else{
        z = y;
    }
    return z;
}
/*
int min(int x, int y){
    int z;
    if(x<y){
        z = x;
    } else{
        z = y;
    }
    return z;
}
*/

int main (void)
{
  int a;
  int b;
  //int c;
  //int d;
  int max_value;
  //int min_value;
  a=27;
  b=58;
  //c=77;
  //d=88;
  max_value = max(a,b);
  //min_value = min(a,b);
  printf("max: %d\n",max_value);
  //printf("%d",max_value);
  //printf("h");
  //printf("hello");
  //printf("e");
  //printf("l");
  //printf("\n");
  //printf("%d",345);
  //printf("\n");
  //int a;
  //a = 1234;
  //printf(a);
  //printf("hello world!\n");
  return 0;
}
