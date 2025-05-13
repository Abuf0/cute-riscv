#include "stdio.h"
#include "timer.h"

int Loop_Num = 0;

int main (void)
{
    int ts;
    int te;
    int td;
    ts = start_timer();
    for(int i=0;i<2;i=i+1){
        printf("Loop Num : %d\n",i);
    }
    te = stop_timer();
    td = te-ts;
    printf("Spent time : %d\n",td);
    return 0;
}