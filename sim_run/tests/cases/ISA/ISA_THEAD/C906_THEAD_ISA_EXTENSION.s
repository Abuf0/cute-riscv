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
.text
.align 2
.macro FPUMOVD FDESREG,IMME64,IMM_REG
  li \IMM_REG, \IMME64
  fmv.d.x \FDESREG, \IMM_REG
.endm
.set ADDR0, 0x10000
.set ADDR1, 0x10008
.set ADDR2, 0x10010
.set ADDR3, 0x10018
.global main
main:           
.global ENABLE_THEADEE
ENABLE_THEADEE:
    li              x9 , 0x400000
    csrs            mxstatus, x9 
.global addsl_test
addsl_test:
    li              x3 , 0x123456789abcdef0
    li              x4 , 0x56789abcdef01234
    addsl           x5 , x3 , x4 , 0x0
    li              x6 , 0x68acf13579acf124
    bne             x5 , x6 , TEST_FAIL
    li              x3 , 0x42
    li              x4 , 0xffffffffdeadbeef
    addsl           x5 , x3 , x4 , 0x0
    li              x6 , 0xffffffffdeadbf31
    bne             x5 , x6 , TEST_FAIL
    li              x3 , 0xbeef9876543210fe
    li              x4 , 0x690042690042
    addsl           x5 , x3 , x4 , 0x0
    li              x6 , 0xbef00176969b1140
    bne             x5 , x6 , TEST_FAIL
.global rev_test
rev_test:
    li              x6 , 0x123456789abcdef0
    rev             x7 , x6 
    li              x6 , 0xf0debc9a78563412
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0x0
    rev             x7 , x6 
    li              x6 , 0x0
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0xffffffff
    rev             x7 , x6 
    li              x6 , 0xffffffff00000000
    bne             x6 , x7 , TEST_FAIL
.global revw_test
revw_test:
    li              x6 , 0x123456789abcdef0
    revw            x7 , x6 
    li              x6 , 0xfffffffff0debc9a
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0x0
    revw            x7 , x6 
    li              x6 , 0x0
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0xffffffff
    revw            x7 , x6 
    li              x6 , 0xffffffffffffffff
    bne             x6 , x7 , TEST_FAIL
.global ff0_test
ff0_test:
    li              x6 , 0xffffffffffffffff
    ff0             x7 , x6 
    li              x6 , 64 
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0x7fffffffffffffff
    ff0             x7 , x6 
    li              x6 , 0  
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0xfffffffffffffffe
    ff0             x7 , x6 
    li              x6 , 63 
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0xfffeff6ff8ff8fff
    ff0             x7 , x6 
    li              x6 , 15 
    bne             x6 , x7 , TEST_FAIL
.global ff1_test
ff1_test:
    li              x6 , 0x0
    ff1             x7 , x6 
    li              x6 , 64 
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0xffffffffffffffff
    ff1             x7 , x6 
    li              x6 , 0x0
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0x1
    ff1             x7 , x6 
    li              x6 , 63 
    bne             x6 , x7 , TEST_FAIL
    li              x6 , 0x0001ff6ff8ff8fff
    ff1             x7 , x6 
    li              x6 , 15 
    bne             x6 , x7 , TEST_FAIL
.global ext_instruction
ext_instruction:
    nop            
.global ext_1_bit
ext_1_bit:
    li              x12, 0xff
    ext             x14, x12, 1  , 1  
    li              x15, 0xffffffffffffffff
    bne             x15, x14, TEST_FAIL
    li              x12, 0x80000000
    ext             x14, x12, 1  , 1  
    li              x15, 0x0
    bne             x15, x14, TEST_FAIL
.global ext_64_bit
ext_64_bit:
    li              x12, 0xabcdabcdabcdabcd
    ext             x14, x12, 63 , 0  
    bne             x14, x12, TEST_FAIL
.global ext_sign_bit1
ext_sign_bit1:
    li              x12, 0xabcdabcd
    ext             x14, x12, 2  , 1  
    li              x15, 0xfffffffffffffffe
    bne             x15, x14, TEST_FAIL
.global ext_sign_bit0
ext_sign_bit0:
    li              x12, 0xabcdabcd
    ext             x14, x12, 5  , 3  
    li              x15, 0x1
    bne             x15, x14, TEST_FAIL
.global extu_instruction
extu_instruction:
    nop            
.global extu_1_bit
extu_1_bit:
    li              x12, 0xff
    extu            x14, x12, 1  , 1  
    li              x15, 0x1
    bne             x15, x14, TEST_FAIL
    li              x12, 0x80000000
    extu            x14, x12, 1  , 1  
    li              x15, 0x0
    bne             x15, x14, TEST_FAIL
.global extu_64_bit
extu_64_bit:
    li              x12, 0xabcdabcdabcdabcd
    extu            x14, x12, 63 , 0  
    bne             x14, x12, TEST_FAIL
.global extu_sign_bit1
extu_sign_bit1:
    li              x12, 0xabcdabcd
    extu            x14, x12, 2  , 1  
    li              x15, 0x2
    bne             x15, x14, TEST_FAIL
.global extu_sign_bit0
extu_sign_bit0:
    li              x12, 0xabcdabcd
    extu            x14, x12, 5  , 3  
    li              x15, 0x1
    bne             x15, x14, TEST_FAIL
.global mveqz_instrcution
mveqz_instrcution:
    li              x3 , 0x0
    li              x4 , 0xabcd
    li              x6 , 0xaaaaaaaaaaaaaaaa
    li              x7 , 0xffffffffffffff
    li              x8 , 0xffffffffffffff
    mveqz           x7 , x6 , x3 
    bne             x7 , x6 , TEST_FAIL
    mveqz           x7 , x8 , x4 
    bne             x7 , x6 , TEST_FAIL
    mveqz           x7 , x8 , x0 
    bne             x7 , x8 , TEST_FAIL
.global mvnez_instruction
mvnez_instruction:
    li              x3 , 0x0
    li              x4 , 0xabcd
    li              x6 , 0xaaaaaaaaaaaaaaaa
    li              x7 , 0x5555555555
    li              x8 , 0x5555555555
    mvnez           x7 , x6 , x3 
    bne             x7 , x8 , TEST_FAIL
    mvnez           x7 , x6 , x4 
    bne             x7 , x6 , TEST_FAIL
    mvnez           x7 , x8 , x0 
    bne             x7 , x6 , TEST_FAIL
.global tstnbz_instruction
tstnbz_instruction:
    li              x3 , 0x0
    tstnbz          x5 , x3 
    li              x6 , 0xffffffffffffffff
    bne             x5 , x6 , TEST_FAIL
    li              x3 , 0xffffffffffffffff
    tstnbz          x5 , x3 
    li              x6 , 0x0
    bne             x5 , x6 , TEST_FAIL
    li              x3 , 0xaaaaaaaaaaaaaaaa
    tstnbz          x5 , x3 
    li              x6 , 0x0
    bne             x5 , x6 , TEST_FAIL
    li              x3 , 0xaaaaaaaaaaaa00aa
    tstnbz          x5 , x3 
    li              x6 , 0x000000000000ff00
    bne             x5 , x6 , TEST_FAIL
.global tst_instruction
tst_instruction:
    li              x3 , 0x12345678
    tst             x4 , x3 , 0  
    li              x5 , 0x0
    bne             x4 , x5 , TEST_FAIL
    li              x3 , 0x1234567812345678
    tst             x4 , x3 , 60 
    li              x5 , 0x1
    bne             x4 , x5 , TEST_FAIL
    li              x3 , 0x12345678
    tst             x4 , x3 , 7  
    li              x5 , 0x0
    bne             x4 , x5 , TEST_FAIL
.global srri_instruction
srri_instruction:
    li              x3 , 0x123456789abcdef0
    srri            x4 , x3 , 0  
    li              x5 , 0x123456789abcdef0
    bne             x5 , x4 , TEST_FAIL
    li              x3 , 0xabcdef0123456789
    srri            x4 , x3 , 3  
    li              x5 , 0x3579bde02468acf1
    bne             x5 , x4 , TEST_FAIL
.global srriw_instruction
srriw_instruction:
    li              x3 , 0x123456789abcdef0
    srriw           x4 , x3 , 0  
    li              x5 , 0xffffffff9abcdef0
    bne             x5 , x4 , TEST_FAIL
    li              x3 , 0x12345678
    srriw           x4 , x3 , 4  
    li              x5 , 0xffffffff81234567
    bne             x5 , x4 , TEST_FAIL
.global test_mula
test_mula:
    li              x3 , 0x8000000000000000
    li              x4 , 0x7fffffffffffffff
    li              x11, 0xabcdeabcde
    li              x10, 0xabcdeabcde
    mula            x10, x3 , x0 
    bne             x10, x11, TEST_FAIL
    li              x10, 0xabcdeabcde
    mula            x10, x0 , x4 
    bne             x10, x11, TEST_FAIL
    li              x3 , 0xabcdeabcde
    li              x10, 0xbd3a1a4d5d2ed083
    li              x7 , 0xffffffffffffffff
    mula            x7 , x3 , x3 
    bne             x7 , x10, TEST_FAIL
.global test_muls
test_muls:
    li              x3 , 0x8000000000000000
    li              x4 , 0x7fffffffffffffff
    li              x11, 0xabcdeabcde
    li              x10, 0xabcdeabcde
    muls            x10, x3 , x0 
    bne             x10, x11, TEST_FAIL
    li              x10, 0xabcdeabcde
    muls            x10, x0 , x4 
    bne             x10, x11, TEST_FAIL
    li              x3 , 0xabcdeabcde
    li              x10, 0x42c5e5b2a2d12f7b
    li              x7 , 0xffffffffffffffff
    muls            x7 , x3 , x3 
    bne             x7 , x10, TEST_FAIL
.global test_mulaw
test_mulaw:
    li              x3 , 0xabcdabcd
    li              x4 , 0xffffffff
    li              x11, 0xffffffffabcdabcd
    li              x10, 0xabcdabcd
    mulaw           x10, x3 , x0 
    bne             x10, x11, TEST_FAIL
    li              x10, 0xabcdabcd
    mulaw           x10, x0 , x4 
    bne             x10, x11, TEST_FAIL
    li              x3 , 0xabcdeabcde
    li              x10, 0x5d2ed083
    li              x7 , 0xffffffff
    mulaw           x7 , x3 , x3 
    bne             x7 , x10, TEST_FAIL
.global test_mulsw
test_mulsw:
    li              x3 , 0xffffffffffffffff
    li              x4 , 0xabcdabcd
    li              x11, 0xffffffffabcdabcd
    li              x10, 0xabcdabcd
    mulsw           x10, x3 , x0 
    bne             x10, x11, TEST_FAIL
    li              x10, 0xabcdabcd
    mulsw           x10, x0 , x4 
    bne             x10, x11, TEST_FAIL
    li              x3 , 0xabcdeabcde
    li              x10, 0xffffffffa2d12f7b
    li              x7 , 0xffffffffffffffff
    mulsw           x7 , x3 , x3 
    bne             x7 , x10, TEST_FAIL
.global test_mulah
test_mulah:
    li              x3 , 0xabcdabcd
    li              x4 , 0xffffffff
    li              x11, 0xffffffffabcdabcd
    li              x10, 0xabcdabcd
    mulah           x10, x3 , x0 
    bne             x10, x11, TEST_FAIL
    li              x10, 0xabcdabcd
    mulah           x10, x0 , x4 
    bne             x10, x11, TEST_FAIL
    li              x3 , 0xabcdabcd
    li              x10, 0x1bb18228
    li              x7 , 0xffffffff
    mulah           x7 , x3 , x3 
    bne             x7 , x10, TEST_FAIL
.global test_mulsh
test_mulsh:
    li              x3 , 0xffffffffffffffff
    li              x4 , 0xabcdabcd
    li              x11, 0xffffffffabcdabcd
    li              x10, 0xabcdabcd
    mulsh           x10, x3 , x0 
    bne             x10, x11, TEST_FAIL
    li              x10, 0xabcdabcd
    mulsh           x10, x0 , x4 
    bne             x10, x11, TEST_FAIL
    li              x3 , 0xabcdabcd
    li              x10, 0xffffffffe44e7dd6
    li              x7 , 0xffffffffffffffff
    mulsh           x7 , x3 , x3 
    bne             x7 , x10, TEST_FAIL
.option norvc 
.global STORE1
STORE1:
    li              x3 , 0xffffffffffffffff
    li              x8 , 0xaaaaaaaaaaaaaaaa
    li              x4 , 0x000000000000a000
    li              x18, 0xfffffffffffffff8
    sd              x8 , 0xffffffffffffffe0( x4 )
    lrd             x5 , x4 , x18, 2  
    bne             x8 , x5 , TEST_FAIL
    li              x18, 0x7f8
    li              x19, 0xffffffff000007f8
    sd              x8 , 0x7f8( x4 )
    lrd             x5 , x4 , x18, 0  
    lurd            x9 , x4 , x19, 0  
    bne             x8 , x5 , TEST_FAIL
    bne             x8 , x9 , TEST_FAIL
    li              x18, 0  
    li              x19, 0xffffffff00000000
    sd              x3 , 0x0( x4 )
    lrd             x5 , x4 , x18, 1  
    lurd            x9 , x4 , x19, 1  
    bne             x3 , x5 , TEST_FAIL
    bne             x9 , x5 , TEST_FAIL
    li              x18, 0x10
    li              x19, 0xffffffff00000010
    sd              x8 , 0x80( x4 )
    lrd             x5 , x4 , x18, 3  
    lurd            x9 , x4 , x19, 3  
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x5 , TEST_FAIL
.global STORE2
STORE2:
    li              x6 , 0xffffffff80000000
    li              x8 , 0x0000000080000000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaa80000000
    li              x18, 0  
    li              x19, 0x0000ffff00000000
    sd              x9 , 0x0( x4 )
    sw              x6 , 0x0( x4 )
    lrwu            x7 , x4 , x18, 0  
    lurwu           x20, x4 , x18, 0  
    lrw             x5 , x4 , x18, 0  
    lurw            x21, x4 , x18, 0  
    lrd             x11, x4 , x18, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x6 , x21, TEST_FAIL
    bne             x11, x10, TEST_FAIL
    li              x18, 0xffffffffffffff00
    li              x19, 0x0000ffff00000000
    sd              x9 , -256( x4 )
    sw              x6 , -256( x4 )
    lrwu            x7 , x4 , x18, 0  
    lrw             x5 , x4 , x18, 0  
    lrd             x11, x4 , x18, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x11, x10, TEST_FAIL
    li              x18, 0x3fc
    li              x19, 0x0000ffff0000003fc
    sd              x9 , 0x7f8( x4 )
    sw              x6 , 0x7f8( x4 )
    lrwu            x7 , x4 , x18, 1  
    lurwu           x20, x4 , x18, 1  
    lrw             x5 , x4 , x18, 1  
    lurw            x21, x4 , x18, 1  
    lrd             x11, x4 , x18, 1  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x6 , x21, TEST_FAIL
    bne             x11, x10, TEST_FAIL
    li              x18, 0x7e
    li              x19, 0x0000ffff0000007e
    sd              x9 , 0x1f8( x4 )
    sw              x6 , 0x1f8( x4 )
    lrwu            x7 , x4 , x18, 2  
    lurwu           x20, x4 , x18, 2  
    lrw             x5 , x4 , x18, 2  
    lurw            x21, x4 , x18, 2  
    lrd             x11, x4 , x18, 2  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x6 , x21, TEST_FAIL
    bne             x11, x10, TEST_FAIL
    li              x18, 0xFE
    li              x19, 0x0000ffff0000007e
    sd              x9 , 0x7f0( x4 )
    sw              x6 , 0x7f0( x4 )
    lrwu            x7 , x4 , x18, 3  
    lurwu           x20, x4 , x18, 3  
    lrw             x5 , x4 , x18, 3  
    lurw            x21, x4 , x18, 3  
    lrd             x11, x4 , x18, 3  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x6 , x21, TEST_FAIL
    bne             x11, x10, TEST_FAIL
.global STORE3
STORE3:
    sw              x6 , 0xfffffffffffffffc( x4 )
    lwu             x7 , 0xfffffffffffffffc( x4 )
    lw              x5 , 0xfffffffffffffffc( x4 )
    bne             x7 , x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    li              x18, 0x7fc
    sw              x6 , 0x7fc( x4 )
    lrwu            x7 , x4 , x18, 0  
    lrw             x5 , x4 , x18, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
.global STORE4
STORE4:
    li              x6 , 0xffffffffffff8000
    li              x8 , 0x0000000000008000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x31, 0xffffffffaaaa8000
    li              x18, 0  
    li              x19, 0xffff000000000000
    sd              x9 , 0x0( x4 )
    sh              x6 , 0x0( x4 )
    lrhu            x7 , x4 , x18, 0  
    lurhu           x20, x4 , x18, 0  
    lrh             x5 , x4 , x18, 0  
    lurh            x21, x4 , x19, 0  
    lrw             x11, x4 , x18, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x6 , x21, TEST_FAIL
    bne             x11, x31, TEST_FAIL
    li              x18, 0xfffffffffffffff0
    li              x19, 0xffff000000000000
    sd              x9 , -16( x4 )
    sh              x6 , -16( x4 )
    lrhu            x7 , x4 , x18, 0  
    lrh             x5 , x4 , x18, 0  
    lrw             x11, x4 , x18, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x11, x31, TEST_FAIL
    li              x18, 0x3f8
    li              x19, 0xffff0000000003f8
    sd              x9 , 0x7f0( x4 )
    sh              x6 , 0x7f0( x4 )
    lrhu            x7 , x4 , x18, 1  
    lurhu           x20, x4 , x18, 1  
    lrh             x5 , x4 , x18, 1  
    lurh            x21, x4 , x19, 1  
    lrw             x11, x4 , x18, 1  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x6 , x21, TEST_FAIL
    bne             x11, x31, TEST_FAIL
    li              x18, 0x7c
    li              x19, 0xffff00000000007c
    sd              x9 , 0x1f0( x4 )
    sh              x6 , 0x1f0( x4 )
    lrhu            x7 , x4 , x18, 2  
    lurhu           x20, x4 , x18, 2  
    lrh             x5 , x4 , x18, 2  
    lurh            x21, x4 , x19, 2  
    lrw             x11, x4 , x18, 2  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x6 , x21, TEST_FAIL
    bne             x11, x31, TEST_FAIL
    li              x18, 0xFC
    li              x19, 0xffff0000000000Fc
    sd              x9 , 0x7e0( x4 )
    sh              x6 , 0x7e0( x4 )
    lrhu            x7 , x4 , x18, 3  
    lurhu           x20, x4 , x18, 3  
    lrh             x5 , x4 , x18, 3  
    lurh            x21, x4 , x19, 3  
    lrw             x11, x4 , x18, 3  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x6 , x21, TEST_FAIL
    bne             x11, x31, TEST_FAIL
.global STORE5
STORE5:
    li              x18, 0xfffffffffffffffe
    sh              x6 , 0xfffffffffffffffe( x4 )
    lrhu            x7 , x4 , x18, 0  
    lrh             x5 , x4 , x18, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
.global STORE6
STORE6:
    li              x18, 0x7fe
    li              x19, 0xffffff00000007fe
    sh              x6 , 0x7fe( x4 )
    lrhu            x7 , x4 , x18, 0  
    lurhu           x20, x4 , x19, 0  
    lrh             x5 , x4 , x18, 0  
    lurh            x21, x4 , x19, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x6 , x5 , TEST_FAIL
    bne             x6 , x21, TEST_FAIL
.global STORE7
STORE7:
    li              x3 , 0xffffffffffffffff
    li              x8 , 0x00000000000000ff
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaaaaff
    li              x31, 0xffffffffaaaaaaff
    li              x18, 0x0
    li              x19, 0xffefff0f00000000
    sd              x9 , 0x0( x4 )
    sb              x3 , 0x0( x4 )
    lrbu            x7 , x4 , x18, 0  
    lurbu           x20, x4 , x19, 0  
    lrb             x5 , x4 , x18, 0  
    lurb            x21, x4 , x19, 0  
    lrw             x11, x4 , x18, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x3 , x5 , TEST_FAIL
    bne             x3 , x21, TEST_FAIL
    bne             x31, x11, TEST_FAIL
    li              x18, 0x3f0
    li              x19, 0xffefff0f000003f0
    sd              x9 , 0x7e0( x4 )
    sb              x3 , 0x7e0( x4 )
    lrbu            x7 , x4 , x18, 1  
    lurbu           x20, x4 , x19, 1  
    lrb             x5 , x4 , x18, 1  
    lurb            x21, x4 , x19, 1  
    lrw             x11, x4 , x18, 1  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x3 , x5 , TEST_FAIL
    bne             x3 , x21, TEST_FAIL
    bne             x31, x11, TEST_FAIL
    li              x18, 0x78
    li              x19, 0xffeffff000000078
    sd              x9 , 0x1e0( x4 )
    sb              x3 , 0x1e0( x4 )
    lrbu            x7 , x4 , x18, 2  
    lurbu           x20, x4 , x19, 2  
    lrb             x5 , x4 , x18, 2  
    lurb            x21, x4 , x19, 2  
    lrw             x11, x4 , x18, 2  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x3 , x5 , TEST_FAIL
    bne             x3 , x21, TEST_FAIL
    bne             x31, x11, TEST_FAIL
    li              x18, 0xF8
    li              x19, 0xffeffff0000000F8
    sd              x9 , 0x7c0( x4 )
    sb              x3 , 0x7c0( x4 )
    lrbu            x7 , x4 , x18, 3  
    lurbu           x20, x4 , x19, 3  
    lrb             x5 , x4 , x18, 3  
    lurb            x21, x4 , x19, 3  
    lrw             x11, x4 , x18, 3  
    bne             x7 , x8 , TEST_FAIL
    bne             x20, x8 , TEST_FAIL
    bne             x3 , x5 , TEST_FAIL
    bne             x3 , x21, TEST_FAIL
    bne             x31, x11, TEST_FAIL
.global STORE8
STORE8:
    sb              x3 , 0xffffffffffffffff( x4 )
    li              x18, 0xffffffffffffffff
    lrbu            x7 , x4 , x18, 0  
    lrb             x5 , x4 , x18, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x3 , x5 , TEST_FAIL
    li              x18, 0x7ff
    sb              x3 , 0x7ff( x4 )
    lrbu            x7 , x4 , x18, 0  
    lrb             x5 , x4 , x18, 0  
    bne             x7 , x8 , TEST_FAIL
    bne             x3 , x5 , TEST_FAIL
.global ld_sdib
ld_sdib:
    li              x8 , 0xaaaaaaaaaaaaaaaa
    li              x3 , 0xffffffffffffffaa
    li              x4 , 0x000000000000a000
    li              x18, 0xfffffffffffffff8
    li              x19, 0x9fe0
    sd              x8 , 0xffffffffffffffe0( x4 )
    ldib            x5 ,( x4 ), -8 , 2  
    bne             x8 , x5 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fef
    li              x18, 0xf
    sd              x8 , 0xf( x4 )
    ldib            x5 ,( x4 ), 0xf, 0  
    bne             x8 , x5 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fef
    li              x18, 0  
    sd              x8 , 0x0( x4 )
    ldib            x5 ,( x4 ), 0x0, 1  
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
    li              x19, 0xa02f
    li              x18, 0x8
    sd              x8 , 0x40( x4 )
    ldib            x5 ,( x4 ), 0x8, 3  
    bne             x8 , x5 , TEST_FAIL
    li              x8 , 0xaaaaaaaaaaaaaaaa
    li              x3 , 0xffffffffffffffaa
    li              x4 , 0x000000000000a000
    li              x18, 0xfffffffffffffff8
    li              x19, 0x9fe0
    sdib            x5 ,( x4 ), -8 , 2  
    ld              x8 , 0x0( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fef
    li              x18, 0xf
    sdib            x5 ,( x4 ), 0xf, 0  
    ld              x8 , 0  ( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fef
    li              x18, 0  
    sdib            x5 ,( x4 ), 0x0, 1  
    ld              x8 , 0x0( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
    li              x19, 0xa02f
    li              x18, 0x8
    sdib            x5 ,( x4 ), 0x8, 3  
    ld              x8 , 0x0( x4 )
    bne             x8 , x5 , TEST_FAIL
.global ld_sdia
ld_sdia:
    li              x3 , 0xffffffffffffffbb
    li              x8 , 0xbbbbbbbbbbbbbbbb
    li              x4 , 0x000000000000a000
    li              x18, 0xfffffffffffffff8
    li              x19, 0x9fe0
    sd              x8 , 0x0( x4 )
    ldia            x5 ,( x4 ), -8 , 2  
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
    li              x19, 0x9fef
    li              x18, 0xf
    sd              x8 , 0x0( x4 )
    ldia            x5 ,( x4 ), 0xf, 0  
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
    li              x19, 0x9fef
    li              x18, 0  
    sd              x8 , 0x0( x4 )
    ldia            x5 ,( x4 ), 0x0, 1  
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
    li              x19, 0xa02f
    li              x18, 0x8
    sd              x8 , 0x0( x4 )
    ldia            x5 ,( x4 ), 0x8, 3  
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
    li              x3 , 0xffffffffffffffbb
    li              x8 , 0xbbbbbbbbbbbbbbbb
    li              x4 , 0x000000000000a000
    li              x18, 0xfffffffffffffff8
    li              x19, 0x9fe0
    sdia            x5 ,( x4 ), -8 , 2  
    sd              x8 , 0xffffffffffffffe0( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
    li              x19, 0x9fef
    li              x18, 0xf
    sdia            x5 ,( x4 ), 0xf, 0  
    ld              x8 , 0xfffffffffffffff1( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
    li              x19, 0x9fef
    li              x18, 0  
    sdia            x5 ,( x4 ), 0x0, 1  
    ld              x8 , 0x0( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
    li              x19, 0xa02f
    li              x18, 0x8
    sdia            x5 ,( x4 ), 0x8, 3  
    ld              x8 , 0xffffffffffffffc0( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x4 , x19, TEST_FAIL
.global ld_swib
ld_swib:
    li              x6 , 0xffffffff80000000
    li              x8 , 0x0000000080000000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaa8000000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sw              x6 , 0x0( x4 )
    lwib            x7 ,( x4 ), 0x0, 0  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa008
    sd              x9 , 0x8( x4 )
    sw              x6 , 0x8( x4 )
    lwib            x7 ,( x4 ), 0x4, 1  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fc8
    sd              x9 , -64( x4 )
    sw              x6 , -64( x4 )
    lwib            x7 ,( x4 ), -16, 2  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffff80000000
    li              x8 , 0x0000000080000000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaa8000000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sw              x6 , 0x0( x4 )
    lwuib           x20,( x4 ), 0x0, 0  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa008
    sd              x9 , 0x8( x4 )
    sw              x6 , 0x8( x4 )
    lwuib           x20,( x4 ), 0x4, 1  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fc8
    sd              x9 , -64( x4 )
    sw              x6 , -64( x4 )
    lwuib           x20,( x4 ), -16, 2  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffff80000000
    li              x8 , 0x0000000080000000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaa8000000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    swib            x6 ,( x4 ), 0x0, 0  
    lw              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa008
    sd              x9 , 0x8( x4 )
    swib            x6 ,( x4 ), 0x4, 1  
    lw              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fc8
    sd              x9 , -64( x4 )
    swib            x6 ,( x4 ), -16, 2  
    lw              x7 , 0  ( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
.global ld_swia
ld_swia:
    li              x6 , 0xffffffff80000000
    li              x8 , 0x0000000080000000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaa8000000
    li              x4 , 0xa000
    li              x18, 0  
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sw              x6 , 0x0( x4 )
    lwia            x7 ,( x4 ), 0x0, 0  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa008
    sd              x9 , 0x0( x4 )
    sw              x6 , 0x0( x4 )
    lwia            x7 ,( x4 ), 0x4, 1  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fc8
    sd              x9 , 0  ( x4 )
    sw              x6 , 0  ( x4 )
    lwia            x7 ,( x4 ), -16, 2  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffff80000000
    li              x8 , 0x0000000080000000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaa8000000
    li              x4 , 0xa000
    li              x18, 0  
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sw              x6 , 0x0( x4 )
    lwuia           x20,( x4 ), 0x0, 0  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa008
    sd              x9 , 0x0( x4 )
    sw              x6 , 0x0( x4 )
    lwuia           x20,( x4 ), 0x4, 1  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fc8
    sd              x9 , 0  ( x4 )
    sw              x6 , 0  ( x4 )
    lwuia           x20,( x4 ), -16, 2  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffff80000000
    li              x8 , 0x0000000080000000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaa8000000
    li              x4 , 0xa000
    li              x18, 0  
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    swia            x6 ,( x4 ), 0x0, 0  
    lw              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa008
    sd              x9 , 0x0( x4 )
    swia            x6 ,( x4 ), 0x4, 1  
    lw              x7 , -8 ( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0x9fc8
    sd              x9 , 0  ( x4 )
    swia            x6 ,( x4 ), -16, 2  
    lw              x7 , 0x40( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
.global ld_shib
ld_shib:
    li              x6 , 0xffffffffffff8000
    li              x8 , 0x0000000000008000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sh              x6 , 0x0( x4 )
    lhib            x7 ,( x4 ), 0x0, 0  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x10( x4 )
    sh              x6 , 0x10( x4 )
    lhib            x7 ,( x4 ), 0x8, 1  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x30( x4 )
    sh              x6 , 0x30( x4 )
    lhib            x7 ,( x4 ), 0xc, 2  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , -64( x4 )
    sh              x6 , -64( x4 )
    lhib            x7 ,( x4 ), -8 , 3  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffffffff8000
    li              x8 , 0x0000000000008000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sh              x6 , 0x0( x4 )
    lhuib           x20,( x4 ), 0x0, 0  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x10( x4 )
    sh              x6 , 0x10( x4 )
    lhuib           x20,( x4 ), 0x8, 1  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x30( x4 )
    sh              x6 , 0x30( x4 )
    lhuib           x20,( x4 ), 0xc, 2  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , -64( x4 )
    sh              x6 , -64( x4 )
    lhuib           x20,( x4 ), -8 , 3  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffffffff8000
    li              x8 , 0x0000000000008000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    shib            x6 ,( x4 ), 0x0, 0  
    lh              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x10( x4 )
    shib            x6 ,( x4 ), 0x8, 1  
    lh              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x30( x4 )
    shib            x6 ,( x4 ), 0xc, 2  
    lh              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , -64( x4 )
    shib            x6 ,( x4 ), -8 , 3  
    lh              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
.global ld_shia
ld_shia:
    li              x6 , 0xffffffffffff8000
    li              x8 , 0x0000000000008000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sh              x6 , 0x0( x4 )
    lhia            x7 ,( x4 ), 0x0, 0  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x0( x4 )
    sh              x6 , 0x0( x4 )
    lhia            x7 ,( x4 ), 0x8, 1  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x0( x4 )
    sh              x6 , 0x0( x4 )
    lhia            x7 ,( x4 ), 0xc, 2  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , 0  ( x4 )
    sh              x6 , 0  ( x4 )
    lhia            x7 ,( x4 ), -8 , 3  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffffffff8000
    li              x8 , 0x0000000000008000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sh              x6 , 0x0( x4 )
    lhuia           x20,( x4 ), 0x0, 0  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x0( x4 )
    sh              x6 , 0x0( x4 )
    lhuia           x20,( x4 ), 0x8, 1  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x0( x4 )
    sh              x6 , 0x0( x4 )
    lhuia           x20,( x4 ), 0xc, 2  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , 0  ( x4 )
    sh              x6 , 0  ( x4 )
    lhuia           x20,( x4 ), -8 , 3  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffffffff8000
    li              x8 , 0x0000000000008000
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    shia            x6 ,( x4 ), 0x0, 0  
    lh              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x0( x4 )
    shia            x7 ,( x4 ), 0x8, 1  
    lh              x6 , -16( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x0( x4 )
    shia            x6 ,( x4 ), 0xc, 2  
    lh              x7 , -48( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , 0  ( x4 )
    shia            x6 ,( x4 ), -8 , 3  
    lh              x7 , 0x40( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
.global ld_sbib
ld_sbib:
    li              x6 , 0xfffffffffffffff0
    li              x8 , 0x00000000000000f0
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sb              x6 , 0x0( x4 )
    lbib            x7 ,( x4 ), 0x0, 0  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x10( x4 )
    sb              x6 , 0x10( x4 )
    lbib            x7 ,( x4 ), 0x8, 1  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x30( x4 )
    sb              x6 , 0x30( x4 )
    lbib            x7 ,( x4 ), 0xc, 2  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , -64( x4 )
    sb              x6 , -64( x4 )
    lbib            x7 ,( x4 ), -8 , 3  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffffffffff80
    li              x8 , 0x0000000000000080
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sb              x6 , 0x0( x4 )
    lbuib           x20,( x4 ), 0x0, 0  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x10( x4 )
    sb              x6 , 0x10( x4 )
    lbuib           x20,( x4 ), 0x8, 1  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x30( x4 )
    sb              x6 , 0x30( x4 )
    lbuib           x20,( x4 ), 0xc, 2  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , -64( x4 )
    sb              x6 , -64( x4 )
    lbuib           x20,( x4 ), -8 , 3  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffffffffff80
    li              x8 , 0x0000000000000080
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sbib            x6 ,( x4 ), 0x0, 0  
    lb              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x10( x4 )
    sbib            x6 ,( x4 ), 0x8, 1  
    lb              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x30( x4 )
    sbib            x6 ,( x4 ), 0xc, 2  
    lb              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , -64( x4 )
    sbib            x7 ,( x4 ), -8 , 3  
    lb              x6 , 0  ( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
.global ld_sbia
ld_sbia:
    li              x6 , 0xffffffffffffff80
    li              x8 , 0x0000000000000080
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sb              x6 , 0x0( x4 )
    lbia            x7 ,( x4 ), 0x0, 0  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x0( x4 )
    sb              x6 , 0x0( x4 )
    lbia            x7 ,( x4 ), 0x8, 1  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x0( x4 )
    sb              x6 , 0x0( x4 )
    lbia            x7 ,( x4 ), 0xc, 2  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , 0  ( x4 )
    sb              x6 , 0  ( x4 )
    lbia            x7 ,( x4 ), -8 , 3  
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffffffffff80
    li              x8 , 0x0000000000000080
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sb              x6 , 0x0( x4 )
    lbuia           x20,( x4 ), 0x0, 0  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x0( x4 )
    sb              x6 , 0x0( x4 )
    lbuia           x20,( x4 ), 0x8, 1  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x0( x4 )
    sb              x6 , 0x0( x4 )
    lbuia           x20,( x4 ), 0xc, 2  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , 0  ( x4 )
    sb              x6 , 0  ( x4 )
    lbuia           x20,( x4 ), -8 , 3  
    bne             x20, x8 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x6 , 0xffffffffffffff80
    li              x8 , 0x0000000000000080
    li              x9 , 0xaaaaaaaaaaaaaaaa
    li              x10, 0xaaaaaaaaaaaa8000
    li              x4 , 0xa000
    li              x19, 0xa000
    sd              x9 , 0x0( x4 )
    sbia            x6 ,( x4 ), 0x0, 0  
    lb              x7 , 0x0( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa010
    sd              x9 , 0x0( x4 )
    sbia            x6 ,( x4 ), 0x8, 1  
    lb              x7 , -16( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa040
    sd              x9 , 0x0( x4 )
    sbia            x6 ,( x4 ), 0xc, 2  
    lb              x7 , -48( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
    li              x19, 0xa000
    sd              x9 , 0  ( x4 )
    sbia            x6 ,( x4 ), -8 , 3  
    lb              x7 , 0x40( x4 )
    bne             x7 , x6 , TEST_FAIL
    bne             x19, x4 , TEST_FAIL
.global ld_sdd
ld_sdd:
    li              x3 , 0xffffffffffffffff
    li              x8 , 0xaaaaaaaaaaaaaaaa
    li              x9 , 0x5555555555555555
    li              x4 , 0x000000000000a000
    sd              x8 , 0x30( x4 )
    sd              x9 , 0x38( x4 )
    ldd             x5 , x6 ,( x4 ), 3  , 4  
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    sd              x8 , 0x20( x4 )
    sd              x9 , 0x28( x4 )
    ldd             x5 , x6 ,( x4 ), 2  , 4  
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    sd              x8 , 0  ( x4 )
    sd              x9 , 8  ( x4 )
    ldd             x5 , x6 ,( x4 ), 0  , 4  
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    sd              x8 , 0x10( x4 )
    sd              x9 , 0x18( x4 )
    ldd             x5 , x6 ,( x4 ), 1  , 4  
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    addi            x4 , x4 , 0x80
    sdd             x8 , x9 ,( x4 ), 2  , 4  
    ld              x5 , 0x20( x4 )
    ld              x6 , 0x28( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    sdd             x8 , x9 ,( x4 ), 3  , 4  
    ld              x5 , 0x30( x4 )
    ld              x6 , 0x38( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    sdd             x8 , x9 ,( x4 ), 0  , 4  
    ld              x5 , 0x0( x4 )
    ld              x6 , 0x8( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    sdd             x8 , x9 ,( x4 ), 1  , 4  
    ld              x5 , 0x10( x4 )
    ld              x6 , 0x18( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
.global lwd_swd_test_init
lwd_swd_test_init:
    li              x3 , 0xffffffffffffffff
    li              x8 , 0xffffffffaaaaaaaa
    li              x9 , 0x0000000055555555
    li              x10, 0x00000000aaaaaaaa
    li              x11, 0x0000000055555555
    li              x4 , 0x000000000000a000
.global lwd_lwud_test
lwd_lwud_test:
    sw              x8 , 8  ( x4 )
    sw              x9 , 0xc( x4 )
    lwd             x5 , x6 ,( x4 ), 1  , 3  
    lwud            x12, x13,( x4 ), 1  , 3  
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    bne             x10, x12, TEST_FAIL
    bne             x11, x13, TEST_FAIL
    sw              x8 , 0  ( x4 )
    sw              x9 , 4  ( x4 )
    lwd             x5 , x6 ,( x4 ), 0  , 3  
    lwud            x12, x13,( x4 ), 0  , 3  
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    bne             x10, x12, TEST_FAIL
    bne             x11, x13, TEST_FAIL
    sw              x8 , 0x18( x4 )
    sw              x9 , 0x1c( x4 )
    lwd             x5 , x6 ,( x4 ), 3  , 3  
    lwd             x5 , x6 ,( x4 ), 3  , 3  
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    bne             x10, x12, TEST_FAIL
    bne             x11, x13, TEST_FAIL
    sw              x8 , 0x10( x4 )
    sw              x9 , 0x14( x4 )
    lwd             x5 , x6 ,( x4 ), 2  , 3  
    lwud            x12, x13,( x4 ), 2  , 3  
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    bne             x10, x12, TEST_FAIL
    bne             x11, x13, TEST_FAIL
.global swd_test
swd_test:
    addi            x4 , x4 , 0x80
    swd             x8 , x9 ,( x4 ), 2  , 3  
    lw              x5 , 0x10( x4 )
    lw              x6 , 0x14( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    swd             x8 , x9 ,( x4 ), 3  , 3  
    lw              x5 , 0x18( x4 )
    lw              x6 , 0x1c( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    swd             x8 , x9 ,( x4 ), 0  , 3  
    lw              x5 , 0  ( x4 )
    lw              x6 , 4  ( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    swd             x8 , x9 ,( x4 ), 1  , 3  
    lw              x5 , 8  ( x4 )
    lw              x6 , 0xc( x4 )
    bne             x8 , x5 , TEST_FAIL
    bne             x9 , x6 , TEST_FAIL
    li              x3 , ADDR0
    li              x10, 0xf12345678
    sd              x10, 0x0( x3 )
    li              x10, 0x87654321
    sd              x10, 0x8( x3 )
    li              x10, 0xffffffff
    sd              x10, 0x10( x3 )
    li              x11, 0xffffffff12345678
.global FLRW1
FLRW1:
    flrw            f15, x3 , x0 , 0  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR1
    li              x11, 0xffffffff87654321
.global FLRW2
FLRW2:
    flrw            f15, x3 , x0 , 3  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR3
    li              x4 , 0xffffffffffffffff
    li              x11, 0xffffffffffffffff
.global FLRW3
FLRW3:
    flrw            f15, x3 , x4 , 3  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x4 , 0xffffffff00000000
    li              x11, 0xffffffff12345678
.global FLURW1
FLURW1:
    flurw           f15, x3 , x4 , 0  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x11, 0xffffffff87654321
    li              x4 , 0xff00000001
.global FLURW2
FLURW2:
    flurw           f15, x3 , x4 , 3  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x4 , 0xffffffff00000002
    li              x11, 0xffffffffffffffff
.global FLURW3
FLURW3:
    flurw           f15, x3 , x4 , 3  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x11, 0xf12345678
.global FLRD1
FLRD1:
    flrd            f15, x3 , x0 , 0  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x11, 0x87654321
    li              x4 , 0x2
.global FLRD2
FLRD2:
    flrd            f15, x3 , x4 , 2  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR3
    li              x4 , 0xffffffffffffffff
    li              x11, 0xffffffff
.global FLRD3
FLRD3:
    flrd            f15, x3 , x4 , 3  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x4 , 0xffffffff00000000
    li              x11, 0xf12345678
.global FLURD1
FLURD1:
    flurd           f15, x3 , x4 , 0  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x4 , 0xffff00000004
    li              x11, 0x87654321
.global FLURD2
FLURD2:
    flurd           f15, x3 , x4 , 1  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x4 , 0x2
    li              x11, 0xffffffff
.global FLURD3
FLURD3:
    flurd           f15, x3 , x4 , 3  
    fmv.x.d         x15, f15
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x11, 0xeeeeeeee80000000
    FPUMOVD         f10, 0x80000000, x10
    li              x10, 0xeeeeeeeeffffffff
    sd              x10, 0  ( x3 )
.global FSRW1
FSRW1:
    fsrw            f10, x3 , x0 , 0  
    ld              x15, 0  ( x3 )
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR2
    li              x10, 0x1234567887654321
    sd              x10, 0  ( x3 )
    li              x3 , ADDR3
    li              x4 , 0xffffffffffffffff
    FPUMOVD         f10, 0x12345678, x10
    li              x11, 0x1234567812345678
.global FSRW2
FSRW2:
    fsrw            f10, x3 , x4 , 3  
    li              x3 , ADDR2
    ld              x15, 0  ( x3 )
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x4 , 0xffffffff00000000
    li              x11, 0xeeeeeeee80000000
    FPUMOVD         f10, 0x80000000, x10
    li              x10, 0xeeeeeeeeffffffff
    sd              x10, 0  ( x3 )
.global FSURW1
FSURW1:
    fsurw           f10, x3 , x4 , 0  
    ld              x15, 0  ( x3 )
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR2
    li              x10, 0x1234567887654321
    sd              x10, 0  ( x3 )
    li              x3 , ADDR0
    li              x4 , 0xffffffff00000002
    FPUMOVD         f10, 0x12345678, x10
    li              x11, 0x1234567812345678
.global FSURW2
FSURW2:
    fsurw           f10, x3 , x4 , 3  
    li              x3 , ADDR2
    ld              x15, 0  ( x3 )
    bne             x15, x11, TEST_FAIL
    li              x3 , ADDR0
    li              x4 , 0xffffffffffffffff
    sd              x4 , 0  ( x3 )
    FPUMOVD         f10, 0x0, x10
.global FSRD1
FSRD1:
    fsrd            f10, x3 , x0 , 0  
    ld              x10, 0  ( x3 )
    bne             x10, x0 , TEST_FAIL
    li              x3 , ADDR2
    li              x4 , 0xffffffffffffffff
    sd              x4 , 0  ( x3 )
    li              x3 , ADDR3
    li              x4 , 0xffffffffffffffff
    FPUMOVD         f10, 0x0, x10
.global FSRD2
FSRD2:
    fsrd            f10, x3 , x4 , 3  
    ld              x10, 0  ( x3 )
    bne             x10, x0 , TEST_FAIL
    li              x3 , ADDR0
    li              x4 , 0xffffffffffffffff
    sd              x4 , 0  ( x3 )
    FPUMOVD         f10, 0x0, x10
    li              x4 , 0xfff00000000
.global FSURD1
FSURD1:
    fsurd           f10, x3 , x4 , 0  
    ld              x10, 0  ( x3 )
    bne             x10, x0 , TEST_FAIL
    li              x3 , ADDR2
    li              x4 , 0xffffffffffffffff
    sd              x4 , 0  ( x3 )
    li              x3 , ADDR0
    li              x4 , 0xffff00000008
    FPUMOVD         f10, 0x0, x10
.global FSURD2
FSURD2:
    fsurd           f10, x3 , x4 , 1  
    li              x3 , ADDR2
    ld              x10, 0  ( x3 )
    bne             x10, x0 , TEST_FAIL
.global TEST_EXIT
TEST_EXIT:
    j __exit           
.global TEST_FAIL
TEST_FAIL:
    j __fail           
