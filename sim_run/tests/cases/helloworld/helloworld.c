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
  int max_value;
  //int min_value;
  a=10;
  for(b=0;b<20;b++){
    //printf("b%d",b);
    max_value = max(a,b);
    printf("%d\n",max_value);
    //printf("END\n");
    if(max_value>0)
        max_value++;
  }
  //min_value = min(a,b);
  //printf("max: %d\n",max_value);
  //printf("hello world!\n");
  return 0;
}
