#/*Copyright 2020-2021 T-Head Semiconductor Co., Ltd.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
#*/
#*/
#*/
CC      = ${TOOL_EXTENSION}/riscv32-unknown-elf-gcc
AS      = ${TOOL_EXTENSION}/riscv32-unknown-elf-as
LINK    = ${TOOL_EXTENSION}/riscv32-unknown-elf-ld
OBJDUMP = ${TOOL_EXTENSION}/riscv32-unknown-elf-objdump
OBJCOPY = ${TOOL_EXTENSION}/riscv32-unknown-elf-objcopy
CONVERT		=../tests/bin/Srec2vmem
#CONVERT_BIN =../tests/bin/obd2bin.py
obj_file =${CUTERISCV}/sim_run/work/${FILE}_elf.txt
bin_file =${CUTERISCV}/sim_run/work/cutecore.v_toplevel_icache_inst_icache_rom.bin


SSRC = $(wildcard *.S)
sSRC = $(wildcard *.s)
CSRC = $(wildcard *.c)

OBJECTS = $(SSRC:%.S=%.o) $(sSRC:%.s=%.o) $(CSRC:%.c=%.o)

#INCDIR = -I/tools/cskytools/csky-abiv2-elf-tools-x86_64-20130312/csky-abiv2-elf/include -I.

FLAG_ABI = 
#FLAG_MARCH = -mtune=c906 
FLAG_MARCH =
#CPU_ARCH_FLAG_0 => CPU Arch: c906, c906fd, c906fdv
ifeq (${CPU_ARCH_FLAG_0}, c906)
  FLAG_MARCH += -march=rv64imacxtheadc
  FLAG_ABI   = -mabi=lp64
else
  ifeq (${CPU_ARCH_FLAG_0}, c906fd)
    FLAG_MARCH += -march=rv64imafdcxtheadc
    FLAG_ABI   = -mabi=lp64d
  else  # c906fdv
  ifeq (${CPU_ARCH_FLAG_0}, cute318)
  	FLAG_MARCH += -march=rv32i
  	FLAG_ABI   = -mabi=ilp32
  	else
  	  FLAG_MARCH = -march=rv64imafdcvxtheadc
  	  FLAG_ABI   = -mabi=lp64dv
  	endif
  endif
endif
CFLAGS = ${FLAG_MARCH} ${FLAG_ABI} -g

#ifeq (${CASENAME}, coremark)
#  CFLAGS +=  -c -O3 -mtune=c906 -static -funroll-all-loops -finline-limit=500 -fgcse-sm -fno-schedule-insns --param max-rtl-if-conversion-unpredictable-cost=100 -msignedness-cmpiv -fno-code-hoisting -mno-thread-jumps1 -mno-iv-adjust-addr-cost -mno-expand-split-imm -DITERATIONS=10000
#else
#  CFLAGS += -c -O2
#endif

LINKFLAGS = -Tlinker.lcf -nostartfiles ${FLAG_MARCH} ${FLAG_ABI}

# LINKLIBS  = -L${TOOL_PATH}/lib/gcc/riscv64-unknown-elf/8.1.0/rv32imac
# LINKLIBS += -L${TOOL_PATH}/riscv64-unknown-elf/lib/rv32imac
# LINKLIBS += -L${TOOL_PATH}/riscv32-unknown-elf/lib

LINKLIBS = -lc -lgcc

OBJDUMPFLAGS = -S -Mnumeric

HEXFLAGS	= -O srec

%.o : %.c
	${CC} -c ${CFLAGS} -o $@ $<

%.o : %.s
	${CC} -c ${CFLAGS} -o $@ $<

%.o : %.S
	${CC} -c ${CFLAGS} -o $@ $<

${FILE}.elf : ${OBJECTS} linker.lcf
	${CC} ${LINKFLAGS} ${LINKLIBS} ${OBJECTS} -o $@ -lm 
	${OBJDUMP} -S ${FILE}.elf > ${FILE}_elf.txt
	echo ${OBJECTS}

${FILE}.obj : ${FILE}.elf
	${OBJDUMP} ${OBJDUMPFLAGS} $< > $@
	${OBJDUMP} -d ${FILE}.o > ${FILE}.txt
	${OBJDUMP} -d crt0.o > crt0.txt
#	${CC} ${FLAG_MARCH} ${FLAG_ABI} -S ${FILE}.c -o ${FILE}.s --verbose

INST_HEX = ${FILE}_inst.hex
DATA_HEX = ${FILE}_data.hex
FILE_HEX = ${FILE}.hex

${FILE}.hex : ${FILE}.elf
	${OBJCOPY} ${HEXFLAGS} $< ${INST_HEX} -j .text*  -j .rodata* -j .eh_frame*
	${OBJCOPY} ${HEXFLAGS} $< ${DATA_HEX} -j .data*  -j .bss -j .COMMON
	${OBJCOPY} ${HEXFLAGS} $< $@ 
#	${OBJDUMP} -S ${FILE}.elf > ${FILE}_elf.txt
#	${OBJDUMP} -l -S ${FILE}.elf > ${FILE}_elf.txt


INST_PAT = inst.pat
DATA_PAT = data.pat
FILE_PAT = case.pat

%.pat	: %.hex
	rm -f *.pat
	${CONVERT} ${INST_HEX} ${INST_PAT}
	${CONVERT} ${DATA_HEX} ${DATA_PAT}
	${CONVERT} ${FILE_HEX} ${FILE_PAT}
#	${CONVERT_BIN} ${obj_file} ${bin_file}
#	echo ${obj_file}
#	echo ${bin_file}

#--------------------------------------------------------------------
# target setting
.PHONY :all
all : ${FILE}.pat ${FILE}.hex ${FILE}.elf ${FILE}.obj

#---------------------------------------------------------------------
# clean some medium code and .pat
.PHONY :clean 
clean:
	rm -rf *.o *.pat *.elf *.obj *.hex

