vcs_compile:
	@echo "start vcs compile"
	cd work && vcs  \
		-f ../filelist/filelist.f \
		-timescale=1ns/1ns \
		-full64  -kdb -lca -R  +vc  +v2k  -sverilog  -debug_access+all  \
		-partcomp -fastpartcomp=j4 \
		|tee vcs_compile.log  

#verdi:
#	cd work && verdi -dbdir simv.daidir -ssf top.fsdb -sv &

include ./setup/smart_cfg.mk
include ./setup/env_check.mk

################################################################################
# Simulation related
################################################################################
SIM = vcs 
DUMP = off

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# Generate makefile dependencies (not shown as complicates the Makefile)
#VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -Os -x-assign 0
# lint-only
VERILATOR_FLAGS += -lint-only
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wno-fatal
# Make waveforms
#VERILATOR_FLAGS += --trace
## Check SystemVerilog assertions
#VERILATOR_FLAGS += --assert
## Generate coverage analysis
#VERILATOR_FLAGS += --coverage
# Run Verilator in debug mode
#VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# Generate makefile dependencies (not shown as complicates the Makefile)
#VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -Os -x-assign 0
# lint-only
VERILATOR_FLAGS += -lint-only
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wno-fatal
# Make waveforms
#VERILATOR_FLAGS += --trace
## Check SystemVerilog assertions
#VERILATOR_FLAGS += --assert
## Generate coverage analysis
#VERILATOR_FLAGS += --coverage
# Run Verilator in debug mode
#VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt

ifeq ($(DUMP), on)
ifeq (${SIM}, verilator)
SIM_DUMP := --trace
else
SIM_DUMP :=
endif
else
ifeq (${SIM}, iverilog)
SIM_DUMP = -DNO_DUMP
else
SIM_DUMP := +define+NO_DUMP
endif
endif

ifeq ($(SIM), vcs)
TIMESCALE := -timescale=1ns/100ps
SIMULATOR_OPT := -sverilog -full64 -kdb -lca -debug_access +nospecify +notimingchecks +lint=TFIPC-L
SIMULATOR_DEF := +define+no_warning +define+TSMC_NO_WARNING
SIMULATOR_LOG := -l comp.vcs.log
ifeq ($(UPF), on)
SIMULATOR_POWER_OPT := -upf ../impl/upf/example_cpu_power_spec.upf +define+UPF_INCLUDED
SIMV_POWER_OPT      := +fsdb+power +fsdb+all 
else
SIMULATOR_POWER_OPT := 
SIMV_POWER_OPT      := 
endif
else 
    ifeq ($(SIM), nc) 
    TIMESCALE := -timescale 1ns/100fs
    SIMULATOR_OPT := +v2k -sysv +sv +access+wrc +notimingcheck -default_ext verilog -elaborate +tcl+../setup/nc.tcl
    SIMULATOR_DEF := +define+no_warning +define+TSMC_NO_WARNING +define+VMC +define+NC_SIM 
    SIMULATOR_LOG := -l comp.nc.log
    else
        ifeq ($(SIM), iverilog)
          TIMESCALE := 
          SIMULATOR_OPT := -o xuantie_core.vvp -Diverilog=1 -g2012 
          SIMULATOR_DEF := -DIVERILOG_SIM
          SIMULATOR_LOG := 
        else
            ifeq ($(SIM), verilator)
              SIMULATOR_OPT := -Os -x-assign 0 -Wno-fatal --threads ${THREADS}
              SIMULATOR_DEF := -cc --exe --top-module top 
              SIMULATOR_LOG := 
            else
            endif
        endif
    endif
endif

ifeq ($(SIM), iverilog)
SIM_FILELIST := $(SIM_FILELIST) -f ${CODE_BASE_PATH}/gen_rtl/filelists/C906_asic_rtl.fl -f ${CODE_BASE_PATH}/gen_rtl/filelists/tdt_dmi_top_rtl.fl -c ../logical/filelists/smart.fl -c ../logical/filelists/tb.fl
else
    ifeq ($(SIM), verilator)
    SIM_FILELIST := $(SIM_FILELIST) -f ../logical/filelists/sim_verilator.fl
    else
    SIM_FILELIST := $(SIM_FILELIST) -f ${CUTERISCV}/sim_run/filelist/filelist.f
    endif
endif

compile:
	@echo "  [THead-smart] Compiling smart now ... "
	@echo "  [THead-smart] SIM = $(SIM)"
	@echo "SIM_FILELIST = ${SIM_FILELIST}"
ifeq ($(SIM), vcs)
	@make -s cleansim
	@cd ./work && vcs $(SIMULATOR_OPT) $(TIMESCALE) $(SIMULATOR_DEF) $(SIM_FILELIST) $(SIM_DUMP) $(SIMULATOR_LOG) $(SIMULATOR_POWER_OPT)
else 
    ifeq ($(SIM), nc) 
	@cd ./work && irun $(SIMULATOR_OPT) $(TIMESCALE) $(SIMULATOR_DEF) $(SIM_FILELIST) $(SIM_DUMP) $(SIMULATOR_LOG) 
    else
        ifeq ($(SIM), iverilog)
	  @cd ./work && iverilog $(TIMESCALE) $(SIMULATOR_OPT) $(SIMULATOR_DEF) $(SIM_FILELIST) $(SIM_DUMP) $(SIMULATOR_LOG)
        else
            ifeq ($(SIM), verilator)
	      @cd ./work && verilator $(SIMULATOR_OPT) $(SIMULATOR_DEF) $(SIMULATOR_LOG) $(SIM_FILELIST) $(SIM_DUMP)
            else
	      @echo "  [THead-smart] Please specify SIM = vcs to use VCS, or SIM = nc ,or SIM = verilator to use irun ..."
            endif
        endif
    endif 
endif 

buildVerilator:
	@cp ./logical/tb/Makefile_obj ./work/Makefile_obj
	@cd ./work && make -j -C obj_dir -f ../Makefile_obj

cleansim:
	@cd ./work && rm -rf simv* csrc ucli.key *.vcs.log novas_dump.log *.fsdb

cleanVerilator:
	@cd ./work && rm -rf obj_dir/

################################################################################
# Cases related
################################################################################
showcase:
	@echo "  Case lists:" \ 
	@for case in $(CASE_LIST) ; do \
          echo "    $$case"; \
        done

buildcase: tool-chain-chk
ifeq ($(CASE),)
	$(error Please specify CASE=xxx on the command line, like: \
        $(newline)   > make buildcase CASE=xxx... \
        $(newline)   The list of valid cases can be obtained by executing: \
        $(newline)   > make showcase ...)
endif
ifeq ($(findstring $(CASE), $(CASE_LIST)), $(CASE))
	@make -s cleancase
	@make -s $(CASE)_build
	@echo "SIM_FILELIST = $(SIM_FILELIST)"
else
	$(error Argument CASE=xxx is not valid: \
        $(newline)   The list of valid cases can be obtained by executing: \
        $(newline)   > make showcase ...)
endif


cleancase:
	@cd ./work && rm -rf *.s *.S *.c *.o *.pat *.h *.lcf *.hex *.obj *.vh *.v *.report *.elf Makefile *.case.log

################################################################################
# Combined flows
################################################################################
# Execute one case

runVerilator:
	@cd ./work && obj_dir/Vtop

runcase:
ifeq ($(CASE),)
	$(error Please specify CASE=xxx on the command line, like: \
        $(newline)   > make buildcase CASE=xxx... \
        $(newline)   The list of valid cases can be obtained by executing: \
        $(newline)   > make showcase ...)
endif
ifeq ($(findstring $(CASE), $(CASE_LIST)), $(CASE))
	@make -s compile
	@make -s buildcase CASE=$(CASE)
ifeq ($(SIM), vcs)
	cd ./work && ./simv -l run.vcs.log
#verdi -ssf novas.fsdb $(SIM_FILELIST) -sv -ssy -ssz &
else
        ifeq ($(SIM), nc)	
	cd ./work && irun -R -l run.irun.log
        else
	cd ./work && vvp xuantie_core.vvp -l run.iverilog.log
        endif
endif
else
	$(error Argument CASE=xxx is not valid: \
        $(newline)   The list of valid cases can be obtained by executing: \
        $(newline)   > make showcase ...)
endif

# Execute all cases
regress:
	rm -rf ./tests/regress/regress_result/*
	@(for case in $(CASE_LIST) ; do \
	 rm -rf ./work/* ; \
	 make -s runcase CASE=$$case; \
	 cp ./work/run_case.report ./tests/regress/regress_result/$$case.report; \
	 done)
	cd ./tests/regress && perl report_gen.pl
	cat ./tests/regress/regress_report

################################################################################
# Misc
################################################################################
.DEFAULT_GOAL := help

clean:
	@cd ./work && rm -rf * 

help:
	@echo "  ########## Smart Help Info ##########"
	@echo "  This Makefile is the entrance of T-Head Smart simulation environment"
	@echo "  Usage: make [target] [arguments]";
	@echo "  Available targets:";
	@echo "    compile                         : compile the RTL and Smart tbench (using vcs or ius)";
	@echo "    showcase                        : list all valid cases under current configuration";
	@echo "    buildcase CASE=[casename]       : clean and compile the .c/.s case [casename]";
	@echo "    [casename]_build                : compile the .c/.s case [casename]";
	@echo "    runcase CASE=[casename]         : run the case [casename]";
	@echo "    regress                         : run all cases and summarize the regress result";
	@echo "    cleansim                        : clean files generated by simulator in ./work ";
	@echo "    cleancase                       : clean files generated by GNU in ./work ";
	@echo "    clean                           : clean ./work ";
	@echo "  Optional arguments:";
	@echo "    SIM=                            : options: vcs / nc"; 
	@echo "    CASE=                           : options: the list print by 'make showcase'"; 
	@echo "    DUMP=                           : options: on / off";
	@echo "  Examples:";
	@echo "    make runcase CASE=dhry          : run case 'dhry' (by vcs withtout dump) "; 
	@echo "    make runcase CASE=dhry SIM=nc   : run case 'dhry' (by nc withtout dump) "; 
	@echo "    make runcase CASE=dhry DUMP=on  : run case 'dhry' with dump "; 
	@echo "  Waveforms:";
	@echo "	   make verdi CASE=[casename]";

verdi:
#ifeq ($(CASE), debug)
#	#SIM_FILELIST := ../tests/cases/debug/JTAG_DRV.vh ../tests/cases/debug/C906_DEBUG_PATTERN.v
#	@cd ./work && verdi -ssf novas.fsdb -f ../logical/filelists/debug.f -sv -ssy -ssv -ssz &
#else
#	@cd ./work && verdi -ssf novas.fsdb $(SIM_FILELIST) -sv -ssy -ssz &
#endif
#	@cd ./work && verdi -ssf novas.fsdb -dbdir simv.daidir -sv -ssy -ssz &
	@cd work && verdi -dbdir simv.daidir -ssf top.fsdb -sv &


