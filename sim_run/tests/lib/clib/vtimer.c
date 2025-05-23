/*Copyright 2020-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
int get_vtimer()
{
  volatile unsigned int   LoadCount;
  asm ("csrr %[LoadCount], time\n"
      :[LoadCount]"=r"(LoadCount)
      :
      :
      );
  //LoadCount = *TIMER_ADDR;
  return LoadCount;
  //int *TIMER_ADDR;
  //TIMER_ADDR = 0xE0013000;
  //volatile unsigned int   LoadCount;
  //LoadCount = *TIMER_ADDR;
  //return LoadCount;
}

void sim_end()
{
  int *END_ADDR;
  END_ADDR = 0x6000FFF8;
  unsigned int END_DATA;
  END_DATA= 0xffff0000;
  *END_ADDR = END_DATA;
}
