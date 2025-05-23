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

#*************Following is the generated instructions*****************

.text
.align 6
.global main
main:
.global ID_SYNC
ID_SYNC:
      fence.i
.global ICACHE_DIS
ICACHE_DIS:
      csrci mhcr,0x1
.global ICACHE_INV_ALL
ICACHE_INV_ALL:
#sel icache
      csrsi mcor,0x1
      csrci mcor,0x2
#inv
      csrsi mcor,0x10
.global ICACHE_EN
ICACHE_EN:
      csrsi mhcr,0x1
.global DCACHE_DIS
DCACHE_DIS:
      csrci mhcr,0x2
.global DCACHE_CLR_ALL
DCACHE_CLR_ALL:
#sel dcache
      csrsi mcor,0x2
      csrci mcor,0x1
#clr
      li x10,0x20
      csrs mcor,x10
.global DCACHE_INV_ALL
DCACHE_INV_ALL:
#sel dcache
      csrsi mcor,0x2
      csrci mcor,0x1
#inv
      csrsi mcor,0x10
.global DCACHE_EN
DCACHE_EN:
      csrsi mhcr,0x2

.global INDEX_OPER
INDEX_OPER:
      nop
.global READ_ICACHE_TAG
READ_ICACHE_TAG:
#set index 3fc0 id 0 (icache tag)
      li x3, 0x3fc0
      csrw mcindex,x3
#read icache tag data
      li x3, 0x1
      csrw mcins,x3
      csrr x3,mcdata0
.global READ_ICACHE_DATA
READ_ICACHE_DATA:
#set index 3fc0 id 1 (icache data)
      li x3, 0x10003fc0
      csrw mcindex,x3
#read icache data
      li x3, 0x1
      csrw mcins,x3
      csrr x3,mcdata0
      csrr x4,mcdata1
.global READ_DCACHE_TAG
READ_DCACHE_TAG:
#set index 3fc0 id 2 (dcache tag)
      li x3, 0x20003fc0
      csrw mcindex,x3
#read dcache tag data
      li x3, 0x1
      csrw mcins,x3
      csrr x3,mcdata0
.global READ_DCACHE_DATA
READ_DCACHE_DATA:
#set index 3fc0 id 3 (dcache data)
      li x3, 0x30003fc0
      csrw mcindex,x3
      li x3, 0x1
#read dcache data
      csrw mcins,x3
      csrr x3,mcdata0
      csrr x4,mcdata0

.global INST_OPER
INST_OPER:
      li x10,0x400000
      csrs mxstatus,x10
.global icache_ins_all
icache_ins_all:
#inv all
      icache.iall
#inv all & share
      icache.ialls
.global icache_ins_index
icache_ins_index:
      li x10,0x3fc0
#inv va,pa 
      icache.iva x10
      icache.ipa x10
.global dcache_ins
dcache_ins:
#inv all
      dcache.iall
#clr all
      dcache.call
#inv & clr all
      dcache.ciall
.global dcache_ins_index
dcache_ins_index:
      li x10, 0x30040000
#inv set /way
      dcache.isw x10
#clr set /way
      dcache.csw x10
#inv & clr set/way
      dcache.cisw x10
#tag
      li x10,0x3fc0
#virtural addr  inv  dcache
      dcache.iva x10
#virtural addr  clr dcache
      dcache.cva x10
#virtural addr clr/inv dcache
      dcache.civa x10
#physical addr  inv 
      dcache.ipa x10
#physical addr  clr dcache
      dcache.cpa x10
#physical addr  clr/inv dcache
      dcache.cipa x10


.global EXIT
EXIT:
     la   x1, __exit
     jr   x1
.global FAIL
FAIL:
    la   x1, __fail 
    jr   x1
