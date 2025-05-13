`timescale 1ns/10ps
`define RTL_INST_MEM cuteriscv_tb.cutecore_inst.icache_inst
`define RTL_DATA_MEM cuteriscv_tb.cutecore_inst.dcache_inst
module cuteriscv_tb();

parameter CPU_PERIOD = 10;
parameter APB_PERIOD = 100;

logic clk;
logic rstn;
logic pclk;
logic prstn;
logic pclken;

integer FILE;


cutecore cutecore_inst(
  .io_clk       (clk),
  .io_rstn      (rstn),
  .io_pclk      (pclk),
  .io_prstn     (prstn),
  .io_pclken    (pclken),
  .clk          (clk),
  .reset        (~rstn)
);

always #(CPU_PERIOD/2) clk = ~clk;
always #(APB_PERIOD/2) pclk = ~pclk;
//assign pclken = pclk;// todo

logic pclk_d1;
always@(posedge clk) begin
  pclk_d1 <= pclk;
end
assign pclken = pclk && ~pclk_d1;

initial begin
    clk = 1'b0;
    rstn = 1'b0;
    pclk = 1'b0;
    prstn = 1'b0;
    #(1.3*CPU_PERIOD)
    rstn = 1'b1;
    prstn = 1'b1;
    repeat(100000000000) begin
        @(posedge clk);
    end
    #10
    FILE = $fopen("run_case.report","a");
    $fwrite(FILE,"TEST FAIL<OUT OF TIME>");
    $fclose(FILE);
    $finish(2);
end

// todo for printf
logic [31:0] cpu_awaddr;
logic [31:0] cpu_wdata;
logic cpu_wvalid;

always@(posedge clk) begin
    cpu_awaddr[31:0] <= cuteriscv_tb.cutecore_inst.cutecore_logic_1.commit_1.io_wb_dacahe_interfacec_waddr[31:0];
    cpu_wdata[31:0] <= cuteriscv_tb.cutecore_inst.cutecore_logic_1.commit_1.io_wb_dacahe_interfacec_wdata[31:0];
    //cpu_wvalid <= cuteriscv_tb.cutecore_inst.cutecore_logic_1.commit_1.io_wb_dacahe_interfacec_we;
    cpu_wvalid <= cuteriscv_tb.cutecore_inst.cutecore_logic_1.mmu_1.io_s_memory_write_interface_wvalid;
end


string str0;

always@(posedge clk) begin
    if(cpu_awaddr[31:0] == 32'h9000_0000 && cpu_wvalid) begin
        str0 = {str0,$sformatf("%c",cpu_wdata[7:0])};
        $write("[Sim Controlxx] %s",str0);
        if(cpu_wdata[7:0] == "\n") begin
            $write("[Sim Control] %s",str0);
            str0 = "";
        end
    end
end


always@(posedge clk) begin
    if(cuteriscv_tb.cutecore_inst.cutecore_logic_1.commit_1.io_ex_commit_entry_pc[31:0] === 32'hcc) begin
        $display("Entering trap!!!\n");
        #10
        FILE = $fopen("run_case.report","a");
        $fwrite(FILE,"TEST FAIL<TRAP>");
        $fclose(FILE);
        $finish(2);
    end
    
    else if(cuteriscv_tb.cutecore_inst.cutecore_logic_1.commit_1.io_ex_commit_entry_pc[31:0] === 32'hb8) begin
        $display("Simulation Failed!!!\n");
        #10
        FILE = $fopen("run_case.report","a");
        $fwrite(FILE,"TEST FAIL<Error>");
        $fclose(FILE);
        $finish(2);
    end
    else if(cuteriscv_tb.cutecore_inst.cutecore_logic_1.commit_1.io_ex_commit_entry_pc[31:0] === 32'h9c) begin
        $display("Simulation Finished!!!\n");
        #10
        FILE = $fopen("run_case.report","a");
        $fwrite(FILE,"TEST PASS");
        $fclose(FILE);
        $finish(2);
    end
end

/*
initial begin
    $monitor("<%0t cycles>: pc@ %0h = %0h",($time/CPU_PERIOD/1000),cuteriscv_tb.cutecore_inst.cutecore_logic_1.instr_queue_1.io_if2id_instr_entry_pc[31:0],cuteriscv_tb.cutecore_inst.cutecore_logic_1.instr_queue_1.io_if2id_instr_entry_inst[31:0]);
    //$monitor("T(%0t ns) : [x0] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_0);
    //$monitor("T(%0t ns) : [x1] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_1);
    //$monitor("T(%0t ns) : [x2] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_2);
    //$monitor("T(%0t ns) : [x3] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_3);
    //$monitor("T(%0t ns) : [x4] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_4);
    //$monitor("T(%0t ns) : [x5] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_5);
    //$monitor("T(%0t ns) : [x6] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_6);
    //$monitor("T(%0t ns) : [x7] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_7);
    //$monitor("T(%0t ns) : [x8] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_8);
    //$monitor("T(%0t ns) : [x9] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_9);
    //$monitor("T(%0t ns) : [x10] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_10);
    //$monitor("T(%0t ns) : [x11] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_11);
    //$monitor("T(%0t ns) : [x12] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_12);
    //$monitor("T(%0t ns) : [x13] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_13);
    //$monitor("T(%0t ns) : [x14] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_14);
    //$monitor("T(%0t ns) : [x15] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_15);
    //$monitor("T(%0t ns) : [x16] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_16);
    //$monitor("T(%0t ns) : [x17] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_17);
    //$monitor("T(%0t ns) : [x18] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_18);
    //$monitor("T(%0t ns) : [x19] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_19);
    //$monitor("T(%0t ns) : [x20] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_20);
    //$monitor("T(%0t ns) : [x21] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_21);
    //$monitor("T(%0t ns) : [x22] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_22);
    //$monitor("T(%0t ns) : [x23] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_23);
    //$monitor("T(%0t ns) : [x24] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_24);
    //$monitor("T(%0t ns) : [x25] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_25);
    //$monitor("T(%0t ns) : [x26] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_26);
    //$monitor("T(%0t ns) : [x27] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_27);
    //$monitor("T(%0t ns) : [x28] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_28);
    //$monitor("T(%0t ns) : [x29] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_29);
    //$monitor("T(%0t ns) : [x30] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_30);
    //$monitor("T(%0t ns) : [x31] = %0h",$time,cuteriscv_tb.cutecore_inst.cutecore_logic_1.regfile_1.REG_FILE_31);
end
*/
integer i;
  bit [31:0] mem_inst_temp [16384];
  bit [31:0] mem_data_temp [16384];
  integer j;
  initial
  begin
    $display("\t********* Init Program *********");
    $display("\t********* Wipe memory to 0 *********");
    for(i=0; i < 32'h4000; i=i+1)
    begin
      `RTL_INST_MEM.ram_0[i][7:0] = 8'h0;
      `RTL_INST_MEM.ram_1[i][7:0] = 8'h0;
      `RTL_INST_MEM.ram_2[i][7:0] = 8'h0;
      `RTL_INST_MEM.ram_3[i][7:0] = 8'h0;
      `RTL_DATA_MEM.ram_0[i][7:0] = 8'h0;
      `RTL_DATA_MEM.ram_1[i][7:0] = 8'h0;
      `RTL_DATA_MEM.ram_2[i][7:0] = 8'h0;
      `RTL_DATA_MEM.ram_3[i][7:0] = 8'h0;
    end
  
    $display("\t********* Read program *********");
    $readmemh("inst.pat", mem_inst_temp);
    $readmemh("data.pat", mem_data_temp);
  
    $display("\t********* Load program to memory *********");
    i=0;
    for(i=0;i<32'h4000;i=i+1)
    begin
      `RTL_INST_MEM.ram_0[i][7:0] = mem_inst_temp[i][31:24];
      `RTL_INST_MEM.ram_1[i][7:0] = mem_inst_temp[i][23:16];
      `RTL_INST_MEM.ram_2[i][7:0] = mem_inst_temp[i][15: 8];
      `RTL_INST_MEM.ram_3[i][7:0] = mem_inst_temp[i][ 7: 0];
    end
    i=0;
    for(i=0;i<32'h4000;i=i+1)
    begin
      `RTL_DATA_MEM.ram_0[i][7:0] = mem_data_temp[i][31:24];
      `RTL_DATA_MEM.ram_1[i][7:0] = mem_data_temp[i][23:16];
      `RTL_DATA_MEM.ram_2[i][7:0] = mem_data_temp[i][15: 8];
      `RTL_DATA_MEM.ram_3[i][7:0] = mem_data_temp[i][ 7: 0];
    end
  end



initial begin
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0,cutecore_inst);
    $fsdbDumpMDA();
end

endmodule
