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
#************************************************************

#*************Following is the generated instructions*****************

.text
.align 6
.global main
main:

.set PLICBASE ,0xffffffc000000000
#.set PLICBASE_M  ,APB_BASE_ADDR
.set PLICBASE_M  ,0x4000000000
.set INTPRIO ,0x0
.set INTPEND ,0x1000
.set INTIE ,0x2000
.set INTIE_HART ,0x80
.set INTTH ,0x200000
.set INTCLAIM ,0x200004
.set INTHC_HART ,0x1000


.macro SETINT EXP_CODE, HANDLER_BEGIN,HANDLER_END
  sd   t0, -24(sp)   #address cann't be changed
  sd   t1, -32(sp)   #it relates to crt0.s

  la   t1, vector_table + 128  #intterrupt start address
  addi t0,x0,\EXP_CODE
  slli t0,t0,0x3
  add  t1,t1,t0   

  la   t0, \HANDLER_BEGIN
  sd   t0, 0(t1) 

  ld   t1, -32(sp)
  ld   t0, -24(sp)
  j    \HANDLER_END
 
  ld   a4, -16(sp)
.endm

#//-------------------//
#//   INT HANDLER     //
#//-------------------//
      setint 11 int_begin,int_end
.global int_begin
int_begin:
.global stack_push
stack_push:
      addi x2,x2,-24
      sd x3,0x0(x2)
      csrr x3,mepc
      sd x3,0x8(x2)
      csrr x3,mstatus
      sd x3,0x16(x2)
#//int claim
#//ld id from claim_reg
.global int_claim
int_claim:
      li x5, PLICBASE_M
      li x6, INTCLAIM
      add x7, x5,x6
      lw x8, 0x0(x7)
.global handler
handler:
      nop
      nop
      nop
      nop
#//int cmplt
#//st id to claim_reg
.global int_cmplt
int_cmplt:
      sw x8, 0x0(x7)
.global stack_pop
stack_pop:
      ld x3,0x16(x2)
      csrw mstatus,x3
      ld x3,0x8(x2)
      csrw mepc,x3
      ld x3,0x0(x2)
      addi x2,x2,16
      mret

.global int_end
int_end:
#//-------------------//
#//   INIT BEGIN      //
##//-------------------//
#//enable cpu int ie 
      li x10,0xa
      csrs mstatus,x10
#//enable meie
      li x10,0x800
      csrs mie,x10

#//set threshold highest to mask all 
.global set_mthreshold_mask
set_mthreshold_mask:
      li x5, PLICBASE_M
      li x6, INTTH
      add x7, x5,x6
      li x8, 0x1f
      sw x8, 0x0(x7)

#//set id 1 ip
.global init_ip
init_ip:
      li x5, PLICBASE_M
      li x6, INTPEND
      add x7, x5,x6
      li x8, 0x2
      sw x8, 0x0(x7)

#//set id 1 init prio lv:a
.global init_prio
init_prio:
      li x5, PLICBASE_M
      li x6, INTPRIO
      add x7, x5,x6
      li x8, 0xa
      sw x8, 0x4(x7)

#//enable id 1  mie 
.global init_ie
init_ie:
      li x5, PLICBASE_M
      li x6, INTIE
      add x7, x5,x6
      li x8, 0x2
      sw x8, 0x0(x7)
      sw x8, 0x80(x7)

#//clear mthreshold
.global set_mthreshold_off
set_mthreshold_off:
      li x5, PLICBASE_M
      li x6, INTTH
      add x7, x5,x6
      li x8, 0x0
      sw x8, 0x0(x7)

#//-------------------//
#//   WAIT FOR INT     //
#//-------------------//
#//wait int 

      wfi
.global EXIT
EXIT:
  la   x1, __exit
  jr   x1
.global FAIL
FAIL:
   la   x1, __fail 
  jr   x1
#******this region is added by generator******

