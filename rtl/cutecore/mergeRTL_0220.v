module ahb_master
#(
    parameter ADDR_WIDTH    = 32   ,   // 10~64
    parameter DATA_WIDTH    = 32  ,   // 8,16,32,64,128,256,512,1024
    parameter HBURST_WIDTH  = 3  ,   // 0,3
    parameter HPROT_WIDTH   = 4      // 0,4,7
    //parameter HMASTER_WIDTH = 8     // 0~8
)
(
    // ------ From cpucore ------ //
    input                                  HCLK        ,
    input                                  HRESETn     ,
    output logic                           rvalid_ifu  ,
    output logic                           rvalid_lsu  ,
    output logic                           wvalid      ,
    output logic [DATA_WIDTH-1:0]          rdata       ,  
    input                                  re          ,
    input       [ADDR_WIDTH-1:0]           raddr       ,
    input       [DATA_WIDTH/8-1:0]         rsel        ,  
    input       [ADDR_WIDTH-1:0]           waddr       ,
    input                                  we          ,  
    input       [DATA_WIDTH-1:0]           wdata       ,  
    input       [DATA_WIDTH/8-1:0]         wsel        ,   
    input       [1:0]                      master_read_id  ,
    // ------ To interconnect ------ //
    output logic [ADDR_WIDTH-1:0]          HADDR       ,
    output logic [HBURST_WIDTH-1:0]        HBURST      ,
    output logic                           HMASTLOCK   ,
    output logic [HPROT_WIDTH-1:0]         HPROT       ,
    output logic [2:0]                     HSIZE       ,
    output logic [1:0]                     HTRANS      ,
    output logic [DATA_WIDTH-1:0]          HWDATA      ,
    output logic                           HWRITE      ,
    // ------ From interconnect ------ //
    input                                  trans_pend  ,
    input                                  HREADY      ,
    input [DATA_WIDTH-1:0]                 HRDATA      ,
    input                                  HRESP         
);

logic transfer_on;
logic seq_done;
logic [1:0] scnt;
logic [1:0] seq_num;
logic [2:0] wsize;
logic [ADDR_WIDTH-1:0] waddr_real;

// todo
assign seq_num = 2'd1;
//assign rvalid = re && HREADY;
//assign wvalid = we && HREADY;

always@(*) begin
    case(wsel) 
        4'b0001: begin
            waddr_real <= waddr;
            wsize <= 3'b000;
        end
        4'b0010: begin
            waddr_real <= {waddr[ADDR_WIDTH-1:2],2'b01};
            wsize <= 3'b000;
       end
        4'b0100: begin
            waddr_real <= {waddr[ADDR_WIDTH-1:2],2'b10};
            wsize <= 3'b000;
       end
        4'b1000: begin
            waddr_real <= {waddr[ADDR_WIDTH-1:2],2'b11};
            wsize <= 3'b000;
       end
        4'b0011: begin
            waddr_real <= waddr;
            wsize <= 3'b001;
       end
        4'b1100: begin
            waddr_real <= {waddr[ADDR_WIDTH-1:2],2'b10};
            wsize <= 3'b001;
       end
        4'b1111: begin
            waddr_real <= waddr;
            wsize <= 3'b010;
       end
       default: begin
            waddr_real <= waddr;
            wsize <= 3'b010;
       end
    endcase
end

typedef enum logic [1:0] {IDLE,BUSY,NONSEQ,SEQ} state_t;
state_t state_c,state_n;
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        state_c <= IDLE;
    else 
        state_c <= state_n;
end
always @(*) begin
    if(~HRESETn)
        state_n = IDLE;
    else begin
        state_n = IDLE;
        case(state_c)
            IDLE: begin
                state_n = (transfer_on && HREADY)?  NONSEQ:IDLE;
            end
            BUSY: begin
                if(HREADY) begin
                    //state_n = seq_done? IDLE:SEQ;   // TODO
                    if(transfer_on) state_n = (seq_num==2'd1)? NONSEQ : SEQ;
                    else state_n = IDLE;
                end
                else begin
                    state_n = BUSY;
                end
            end
            NONSEQ: begin
                if(HREADY) begin
                    if(transfer_on)
                        state_n = HRESP?   IDLE:
                                  (seq_num==2'd1)?  NONSEQ : SEQ;
                    else    state_n = IDLE;
                end
                else begin
                    state_n = BUSY;
                end
            end
            SEQ:  begin
                if(HREADY) begin
                    if(HRESP)   state_n = IDLE;
                    else        state_n = seq_done? IDLE:SEQ;
                end
                else begin
                    state_n = BUSY;    
                end            
            end
            default:state_n = IDLE;
        endcase
    end
end           
/*
我感觉具体的传输模式是因地制宜的，是事前确定的，
这里选择：Four-beat wrapping burst, WRAP4
*/  

logic [1:0] ahb_read_id;

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        ahb_read_id <= 'd0;
    else if(state_n != IDLE)
        ahb_read_id <= we?  'd0 : master_read_id;   // start addr
end

logic hready_pend;  // 每个slave的第一笔传输的第一个周期是pending的
logic rvalid_ifu_tmp;
logic rvalid_lsu_tmp;
logic wvalid_tmp;
logic we_d1;
assign rvalid_ifu = rvalid_ifu_tmp && ~trans_pend; // TODO
assign rvalid_lsu = rvalid_lsu_tmp && ~trans_pend;
assign wvalid = wvalid_tmp && ~trans_pend; // TODO 
/*
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        rvalid_ifu_tmp <= 1'b0;
    else if(re && HREADY && master_read_id[0])
        rvalid_ifu_tmp <= 1'b1;
    else 
        rvalid_ifu_tmp <= 1'b0;
end
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        rvalid_lsu_tmp <= 1'b0;
    else if(re && HREADY && master_read_id[1])
        rvalid_lsu_tmp <= 1'b1;
    else 
        rvalid_lsu_tmp <= 1'b0;
end
*/
assign rvalid_ifu_tmp = (re && HREADY && master_read_id[0]);
assign rvalid_lsu_tmp = (re && HREADY && master_read_id[1]);
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        we_d1 <= 1'b0;
    else
        we_d1 <= we;
end
assign wvalid_tmp = (we_d1 && HREADY);
/*    
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        transfer_on <= 1'b0;
    else if(cmd_buff[47:46]==2'b00 && (cmd_buff[55:49]==8'b0 || cmd_buff[55:49]==8'b1))
        transfer_on <= 1'b1;
    else
        transfer_on <= 1'b0;
end
*/
assign transfer_on = re || we;
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        seq_done <= 1'b0;
    else if(state_c == SEQ && scnt == seq_num-1)
        seq_done <= 1'b1;
    else 
        seq_done <= 1'b0;
end
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        scnt <= 2'd0;
    else if(state_n == SEQ)
        scnt <= scnt+1'b1;
    else if(state_c ==  IDLE)
        scnt <= 2'd0;
end

assign HTRANS = state_c;     
assign HPROT = 4'd1;    // todo with instr data
/*
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HBURST <= 'd0;
    else if(state_c == IDLE && state_n != IDLE)
        HBURST <= 3'b000;   // SINGLE
end
*/
assign HBURST = 3'b000;

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HSIZE <= 'd0;
    else if(state_n != IDLE)
        HSIZE <= we?    wsize : 3'b010;   // WORD
    else
        HSIZE <= 3'b010;
end

//assign HSIZE = we? wsize : 3'b010;

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HWRITE <= 1'b0;
    //else if(state_c == IDLE && state_n != IDLE)
    else if(state_n !=  IDLE)
        HWRITE <= we;  //优先回写内存
    else
        HWRITE <= 1'b0;
end

//assign HWRITE = (state_c == IDLE)?  1'b0 : we;
logic [DATA_WIDTH-1:0] wdata_lat;
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
      wdata_lat <= 'd0;
    end
    else if(state_n !=  IDLE) begin
      //wdata_lat <= we?  wdata : wdata_lat;
      wdata_lat <= wdata;
    end
end

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HWDATA <= 'd0;
    //else if(state_c == IDLE && state_n != IDLE && we)
    else if(state_n != IDLE && we_d1)
        HWDATA <= wdata_lat; 
end

//assign HWDATA = (state_c == IDLE)?  'b0 : wdata;
/*
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HMASTLOCK <= 1'b0;
    else if(state_c == IDLE && state_n != IDLE)
        HMASTLOCK <= 1'b1; 
    else if(state_n == IDLE)
        HMASTLOCK <= 1'b0;
end
*/
assign HMASTLOCK = (state_c != IDLE);
logic [ADDR_WIDTH-1:0] HADDR_next;
assign HADDR_next = HADDR + 'd4;
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HADDR <= 'd0;
    else if(state_n == NONSEQ)
//always@(*) begin
//    if(state_c == NONSEQ)
        HADDR <= we?    waddr_real : raddr;   // start addr
    else if(state_n == SEQ) begin
        if(HADDR[3:0] > HADDR_next[3:0])    // 16-byte boundary
            HADDR <= HADDR_next & {{(ADDR_WIDTH-5){1'b1}},5'b01111};
    end
    else if(HRESP==1'b1) begin
        HADDR <= we?    waddr_real : raddr; 
    end
    else begin
        HADDR <= we?    waddr_real : raddr;
    end
end

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
        rdata <= 'd0;
    end
    else if(re && HREADY) begin
        rdata <= HRDATA;
    end
end

//assign rdata = HRDATA;
endmodule
//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2001-2013-2024 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-10-15 18:01:36 +0100 (Mon, 15 Oct 2012) $
//
//      Revision            : $Revision: 225465 $
//
//      Release Information : Cortex-M System Design Kit-r1p0-01rel0
//
//-----------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
//  Abstract            : BusMatrixLite is a wrapper module that wraps around
//                        the BusMatrix module to give AHB Lite compliant
//                        slave and master interfaces.
//
//-----------------------------------------------------------------------------

`timescale 1ns/1ps

module ahb_connect (

    // Common AHB signals
    HCLK,
    HRESETn,


    // Input port SI0 (inputs from master 0)
    HADDRS1,
    HTRANSS1,
    HWRITES1,
    HSIZES1,
    HBURSTS1,
    HPROTS1,
    HWDATAS1,
    HMASTLOCKS1,

    // Output port MI0 (inputs from slave 0)
    HRDATAM1,
    HREADYOUTM1,
    HRESPM1,

    // Output port MI1 (inputs from slave 1)
    HRDATAM2,
    HREADYOUTM2,
    HRESPM2,

    // Output port MI1 (inputs from slave 1)
    HRDATAM3,
    HREADYOUTM3,
    HRESPM3,

    // Output port MI1 (inputs from slave 1)
    HRDATAM4,
    HREADYOUTM4,
    HRESPM4,

    // Output port MI1 (inputs from slave 1)
    HRDATAM5,
    HREADYOUTM5,
    HRESPM5,

    // Output port MI1 (inputs from slave 1)
    HRDATAM6,
    HREADYOUTM6,
    HRESPM6,

    // Output port MI1 (inputs from slave 1)
    HRDATAM7,
    HREADYOUTM7,
    HRESPM7,

    // Scan test dummy signals; not connected until scan insertion
    SCANENABLE,   // Scan Test Mode Enable
    SCANINHCLK,   // Scan Chain Input


    // Output port MI0 (outputs to slave 0)
    HSELM1,
    HADDRM1,
    HTRANSM1,
    HWRITEM1,
    HSIZEM1,
    HBURSTM1,
    HPROTM1,
    HWDATAM1,
    HMASTLOCKM1,
    HREADYMUXM1,

    // Output port MI1 (outputs to slave 1)
    HSELM2,
    HADDRM2,
    HTRANSM2,
    HWRITEM2,
    HSIZEM2,
    HBURSTM2,
    HPROTM2,
    HWDATAM2,
    HMASTLOCKM2,
    HREADYMUXM2,

    // Output port MI1 (outputs to slave 1)
    HSELM3,
    HADDRM3,
    HTRANSM3,
    HWRITEM3,
    HSIZEM3,
    HBURSTM3,
    HPROTM3,
    HWDATAM3,
    HMASTLOCKM3,
    HREADYMUXM3,

    // Output port MI1 (outputs to slave 1)
    HSELM4,
    HADDRM4,
    HTRANSM4,
    HWRITEM4,
    HSIZEM4,
    HBURSTM4,
    HPROTM4,
    HWDATAM4,
    HMASTLOCKM4,
    HREADYMUXM4,

    // Output port MI1 (outputs to slave 1)
    HSELM5,
    HADDRM5,
    HTRANSM5,
    HWRITEM5,
    HSIZEM5,
    HBURSTM5,
    HPROTM5,
    HWDATAM5,
    HMASTLOCKM5,
    HREADYMUXM5,

    // Output port MI1 (outputs to slave 1)
    HSELM6,
    HADDRM6,
    HTRANSM6,
    HWRITEM6,
    HSIZEM6,
    HBURSTM6,
    HPROTM6,
    HWDATAM6,
    HMASTLOCKM6,
    HREADYMUXM6,

    // Output port MI1 (outputs to slave 1)
    HSELM7,
    HADDRM7,
    HTRANSM7,
    HWRITEM7,
    HSIZEM7,
    HBURSTM7,
    HPROTM7,
    HWDATAM7,
    HMASTLOCKM7,
    HREADYMUXM7,

    // Input port SI0 (outputs to master 0)
    HRDATAS1,
    HREADYS1,
    HRESPS1,

    // each slave first trans pending
    trans_pend, 

    // Scan test dummy signals; not connected until scan insertion
    SCANOUTHCLK   // Scan Chain Output

    );

// -----------------------------------------------------------------------------
// Input and Output declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    input         HCLK;            // AHB System Clock
    input         HRESETn;         // AHB System Reset

    // System Address Remap control

    // Input port SI0 (inputs from master 0)
    input  [31:0] HADDRS1;         // Address bus
    input   [1:0] HTRANSS1;        // Transfer type
    input         HWRITES1;        // Transfer direction
    input   [2:0] HSIZES1;         // Transfer size
    input   [2:0] HBURSTS1;        // Burst type
    input   [3:0] HPROTS1;         // Protection control
    input  [31:0] HWDATAS1;        // Write data
    input         HMASTLOCKS1;     // Locked Sequence

    // Output port MI0 (inputs from slave 0)
    input  [31:0] HRDATAM1;        // Read data bus
    input         HREADYOUTM1;     // HREADY feedback
    input         HRESPM1; 

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATAM2;        // Read data bus
    input         HREADYOUTM2;     // HREADY feedback
    input         HRESPM2;

    // Output port MI2 (inputs from slave 2)
    input  [31:0] HRDATAM3;        // Read data bus
    input         HREADYOUTM3;     // HREADY feedback
    input         HRESPM3;

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATAM4;        // Read data bus
    input         HREADYOUTM4;     // HREADY feedback
    input         HRESPM4;

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATAM5;        // Read data bus
    input         HREADYOUTM5;     // HREADY feedback
    input         HRESPM5;

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATAM6;        // Read data bus
    input         HREADYOUTM6;     // HREADY feedback
    input         HRESPM6;

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATAM7;        // Read data bus
    input         HREADYOUTM7;     // HREADY feedback
    input         HRESPM7;


    // Scan test dummy signals; not connected until scan insertion
    input         SCANENABLE;      // Scan enable signal
    input         SCANINHCLK;      // HCLK scan input


    // Output port MI0 (outputs to slave 0)
    output        HSELM1;          // Slave Select
    output [31:0] HADDRM1;         // Address bus
    output  [1:0] HTRANSM1;        // Transfer type
    output        HWRITEM1;        // Transfer direction
    output  [2:0] HSIZEM1;         // Transfer size
    output  [2:0] HBURSTM1;        // Burst type
    output  [3:0] HPROTM1;         // Protection control
    output [31:0] HWDATAM1;        // Write data
    output        HMASTLOCKM1;     // Locked Sequence
    output        HREADYMUXM1;     // Transfer done

    // Output port MI1 (outputs to slave 1)
    output        HSELM2;          // Slave Select
    output [31:0] HADDRM2;         // Address bus
    output  [1:0] HTRANSM2;        // Transfer type
    output        HWRITEM2;        // Transfer direction
    output  [2:0] HSIZEM2;         // Transfer size
    output  [2:0] HBURSTM2;        // Burst type
    output  [3:0] HPROTM2;         // Protection control
    output [31:0] HWDATAM2;        // Write data
    output        HMASTLOCKM2;     // Locked Sequence
    output        HREADYMUXM2;     // Transfer done

    // Output port MI1 (outputs to slave 1)
    output        HSELM3;          // Slave Select
    output [31:0] HADDRM3;         // Address bus
    output  [1:0] HTRANSM3;        // Transfer type
    output        HWRITEM3;        // Transfer direction
    output  [2:0] HSIZEM3;         // Transfer size
    output  [2:0] HBURSTM3;        // Burst type
    output  [3:0] HPROTM3;         // Protection control
    output [31:0] HWDATAM3;        // Write data
    output        HMASTLOCKM3;     // Locked Sequence
    output        HREADYMUXM3;     // Transfer done

    // Output port MI1 (outputs to slave 1)
    output        HSELM4;          // Slave Select
    output [31:0] HADDRM4;         // Address bus
    output  [1:0] HTRANSM4;        // Transfer type
    output        HWRITEM4;        // Transfer direction
    output  [2:0] HSIZEM4;         // Transfer size
    output  [2:0] HBURSTM4;        // Burst type
    output  [3:0] HPROTM4;         // Protection control
    output [31:0] HWDATAM4;        // Write data
    output        HMASTLOCKM4;     // Locked Sequence
    output        HREADYMUXM4;     // Transfer done

    // Output port MI1 (outputs to slave 1)
    output        HSELM5;          // Slave Select
    output [31:0] HADDRM5;         // Address bus
    output  [1:0] HTRANSM5;        // Transfer type
    output        HWRITEM5;        // Transfer direction
    output  [2:0] HSIZEM5;         // Transfer size
    output  [2:0] HBURSTM5;        // Burst type
    output  [3:0] HPROTM5;         // Protection control
    output [31:0] HWDATAM5;        // Write data
    output        HMASTLOCKM5;     // Locked Sequence
    output        HREADYMUXM5;     // Transfer done

    // Output port MI1 (outputs to slave 1)
    output        HSELM6;          // Slave Select
    output [31:0] HADDRM6;         // Address bus
    output  [1:0] HTRANSM6;        // Transfer type
    output        HWRITEM6;        // Transfer direction
    output  [2:0] HSIZEM6;         // Transfer size
    output  [2:0] HBURSTM6;        // Burst type
    output  [3:0] HPROTM6;         // Protection control
    output [31:0] HWDATAM6;        // Write data
    output        HMASTLOCKM6;     // Locked Sequence
    output        HREADYMUXM6;     // Transfer done

    // Output port MI1 (outputs to slave 1)
    output        HSELM7;          // Slave Select
    output [31:0] HADDRM7;         // Address bus
    output  [1:0] HTRANSM7;        // Transfer type
    output        HWRITEM7;        // Transfer direction
    output  [2:0] HSIZEM7;         // Transfer size
    output  [2:0] HBURSTM7;        // Burst type
    output  [3:0] HPROTM7;         // Protection control
    output [31:0] HWDATAM7;        // Write data
    output        HMASTLOCKM7;     // Locked Sequence
    output        HREADYMUXM7;     // Transfer done

    // Input port SI0 (outputs to master 0)
    output [31:0] HRDATAS1;        // Read data bus
    output        HREADYS1;     // HREADY feedback
    output        HRESPS1;         // Transfer response

    // Scan test dummy signals; not connected until scan insertion
    output        SCANOUTHCLK;     // Scan Chain Output

    output wire   trans_pend;
// -----------------------------------------------------------------------------
// Wire declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    wire         HCLK;            // AHB System Clock
    wire         HRESETn;         // AHB System Reset

    // System Address Remap control
    wire   [3:0] REMAP;           // System REMAP signal

    // Input Port SI0
    wire  [31:0] HADDRS1;         // Address bus
    wire   [1:0] HTRANSS1;        // Transfer type
    wire         HWRITES1;        // Transfer direction
    wire   [2:0] HSIZES1;         // Transfer size
    wire   [2:0] HBURSTS1;        // Burst type
    wire   [3:0] HPROTS1;         // Protection control
    wire  [31:0] HWDATAS1;        // Write data
    wire         HMASTLOCKS1;     // Locked Sequence

    wire  [31:0] HRDATAS1;        // Read data bus
    wire         HREADYS1;     // HREADY feedback
    wire         HRESPS1;         // Transfer response

    // Output Port MI0
    wire         HSELM1;          // Slave Select
    wire  [31:0] HADDRM1;         // Address bus
    wire   [1:0] HTRANSM1;        // Transfer type
    wire         HWRITEM1;        // Transfer direction
    wire   [2:0] HSIZEM1;         // Transfer size
    wire   [2:0] HBURSTM1;        // Burst type
    wire   [3:0] HPROTM1;         // Protection control
    wire  [31:0] HWDATAM1;        // Write data
    wire         HMASTLOCKM1;     // Locked Sequence
    wire         HREADYMUXM1;     // Transfer done

    wire  [31:0] HRDATAM1;        // Read data bus
    wire         HREADYOUTM1;     // HREADY feedback
    wire         HRESPM1;         // Transfer response

    // Output Port MI1
    wire         HSELM2;          // Slave Select
    wire  [31:0] HADDRM2;         // Address bus
    wire   [1:0] HTRANSM2;        // Transfer type
    wire         HWRITEM2;        // Transfer direction
    wire   [2:0] HSIZEM2;         // Transfer size
    wire   [2:0] HBURSTM2;        // Burst type
    wire   [3:0] HPROTM2;         // Protection control
    wire  [31:0] HWDATAM2;        // Write data
    wire         HMASTLOCKM2;     // Locked Sequence
    wire         HREADYMUXM2;     // Transfer done

    wire  [31:0] HRDATAM2;        // Read data bus
    wire         HREADYOUTM2;     // HREADY feedback
    wire         HRESPM2;         // Transfer response

    wire         HSELM3;        
    wire  [31:0] HADDRM3;      
    wire   [1:0] HTRANSM3;     
    wire         HWRITEM3;     
    wire   [2:0] HSIZEM3;      
    wire   [2:0] HBURSTM3;     
    wire   [3:0] HPROTM3;      
    wire  [31:0] HWDATAM3;     
    wire         HMASTLOCKM3;  
    wire         HREADYMUXM3;  
    wire         HSELM4;       
    wire  [31:0] HADDRM4;      
    wire   [1:0] HTRANSM4;     
    wire         HWRITEM4;     
    wire   [2:0] HSIZEM4;      
    wire   [2:0] HBURSTM4;     
    wire   [3:0] HPROTM4;      
    wire  [31:0] HWDATAM4;     
    wire         HMASTLOCKM4;  
    wire         HREADYMUXM4;  
    wire         HSELM5;       
    wire  [31:0] HADDRM5;      
    wire   [1:0] HTRANSM5;     
    wire         HWRITEM5;     
    wire   [2:0] HSIZEM5;      
    wire   [2:0] HBURSTM5;     
    wire   [3:0] HPROTM5;      
    wire  [31:0] HWDATAM5;     
    wire         HMASTLOCKM5;  
    wire         HREADYMUXM5;  
    wire         HSELM6;       
    wire  [31:0] HADDRM6;      
    wire   [1:0] HTRANSM6;     
    wire         HWRITEM6;     
    wire   [2:0] HSIZEM6;      
    wire   [2:0] HBURSTM6;     
    wire   [3:0] HPROTM6;      
    wire  [31:0] HWDATAM6;     
    wire         HMASTLOCKM6;  
    wire         HREADYMUXM6;  
    wire         HSELM7;       
    wire  [31:0] HADDRM7;      
    wire   [1:0] HTRANSM7;     
    wire         HWRITEM7;     
    wire   [2:0] HSIZEM7;      
    wire   [2:0] HBURSTM7;     
    wire   [3:0] HPROTM7;      
    wire  [31:0] HWDATAM7;     
    wire         HMASTLOCKM7;  
    wire         HREADYMUXM7;  
    wire   [31:0] HRDATAM3;       
    wire          HREADYOUTM3;    
    wire          HRESPM3;
    wire   [31:0] HRDATAM4;       
    wire          HREADYOUTM4;    
    wire          HRESPM4;
    wire   [31:0] HRDATAM5;       
    wire          HREADYOUTM5;    
    wire          HRESPM5;
    wire   [31:0] HRDATAM6;       
    wire          HREADYOUTM6;    
    wire          HRESPM6;
    wire   [31:0] HRDATAM7;       
    wire          HREADYOUTM7;    
    wire          HRESPM7;

// -----------------------------------------------------------------------------
// Signal declarations
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Beginning of main code
assign HSELM1       = (HADDRS1>=0 && HADDRS1<=32'h0000FFFF);
assign HADDRM1      =  HADDRS1;        
assign HTRANSM1     =  HTRANSS1;    
assign HWRITEM1     =  HWRITES1;     
assign HSIZEM1      =  HSIZES1;     
assign HBURSTM1     =  HBURSTS1;    
assign HPROTM1      =  HPROTS1;     
assign HWDATAM1     =  HWDATAS1;    
assign HMASTLOCKM1  =  HMASTLOCKS1;
assign HREADYMUXM1  =  HREADYOUTM1;

assign HSELM2       = (HADDRS1>=32'h00010000 && HADDRS1<=32'h0001FFFF);
//assign HADDRM2      =  HADDRS1;    
assign HADDRM2      =  HSELM2?   (HADDRS1 - 32'h00010000) : HADDRS1;    // todo
assign HTRANSM2     =  HTRANSS1;    
assign HWRITEM2     =  HWRITES1;     
assign HSIZEM2      =  HSIZES1;     
assign HBURSTM2     =  HBURSTS1;    
assign HPROTM2      =  HPROTS1;     
assign HWDATAM2     =  HWDATAS1;    
assign HMASTLOCKM2  =  HMASTLOCKS1;
assign HREADYMUXM2  =  HREADYOUTM2;

assign HSELM3       = (HADDRS1>=32'h00020000 && HADDRS1<=32'h0002FFFF);
assign HADDRM3      =  HADDRS1;        
assign HTRANSM3     =  HTRANSS1;   
assign HWRITEM3     =  HWRITES1;    
assign HSIZEM3      =  HSIZES1;    
assign HBURSTM3     =  HBURSTS1;   
assign HPROTM3      =  HPROTS1;    
assign HWDATAM3     =  HWDATAS1;   
assign HMASTLOCKM3  =  HMASTLOCKS1;
assign HREADYMUXM3  =  HREADYOUTM3;

assign HSELM4       = (HADDRS1>=32'h00030000 && HADDRS1<=32'h0003FFFF);
assign HADDRM4      =  HADDRS1;        
assign HTRANSM4     =  HTRANSS1;   
assign HWRITEM4     =  HWRITES1;     
assign HSIZEM4      =  HSIZES1;    
assign HBURSTM4     =  HBURSTS1;   
assign HPROTM4      =  HPROTS1;    
assign HWDATAM4     =  HWDATAS1;   
assign HMASTLOCKM4  =  HMASTLOCKS1;
assign HREADYMUXM4  =  HREADYOUTM4;

assign HSELM5       = (HADDRS1>=32'h00040000 && HADDRS1<=32'h0FFFFFFF);
assign HADDRM5      =  HADDRS1;         
assign HTRANSM5     =  HTRANSS1;    
assign HWRITEM5     =  HWRITES1;      
assign HSIZEM5      =  HSIZES1;     
assign HBURSTM5     =  HBURSTS1;    
assign HPROTM5      =  HPROTS1;     
assign HWDATAM5     =  HWDATAS1;    
assign HMASTLOCKM5  =  HMASTLOCKS1;
assign HREADYMUXM5  =  HREADYOUTM5;

assign HSELM6       = (HADDRS1>=32'h10000000 && HADDRS1<=32'h14FFFFFF);
assign HADDRM6      =  HADDRS1;         
assign HTRANSM6     =  HTRANSS1;    
assign HWRITEM6     =  HWRITES1;      
assign HSIZEM6      =  HSIZES1;     
assign HBURSTM6     =  HBURSTS1;    
assign HPROTM6      =  HPROTS1;     
assign HWDATAM6     =  HWDATAS1;    
assign HMASTLOCKM6  =  HMASTLOCKS1;
assign HREADYMUXM6  =  HREADYOUTM6;

assign HSELM7       = (HADDRS1>=32'h15000000 && HADDRS1<=32'h150FFFFF);
assign HADDRM7      =  HADDRS1;         
assign HTRANSM7     =  HTRANSS1;    
assign HWRITEM7     =  HWRITES1;      
assign HSIZEM7      =  HSIZES1;     
assign HBURSTM7     =  HBURSTS1;    
assign HPROTM7      =  HPROTS1;     
assign HWDATAM7     =  HWDATAS1;    
assign HMASTLOCKM7  =  HMASTLOCKS1;
assign HREADYMUXM7  =  HREADYOUTM7;

assign HRDATAS1 = HSELM1?   HRDATAM1 :
                  HSELM2?   HRDATAM2 :
                  HSELM3?   HRDATAM3 :
                  HSELM4?   HRDATAM4 :
                  HSELM5?   HRDATAM5 :
                  HSELM6?   HRDATAM6 :
                  HSELM7?   HRDATAM7 : 'd0;
assign HREADYS1 = HSELM1?   HREADYMUXM1 :
                  HSELM2?   HREADYMUXM2 :
                  HSELM3?   HREADYMUXM3 :
                  HSELM4?   HREADYMUXM4 :
                  HSELM5?   HREADYMUXM5 :
                  HSELM6?   HREADYMUXM6 :
                  HSELM7?   HREADYMUXM7 : 'd0;
assign HRESPS1 =  HSELM1?   HRESPM1 :
                  HSELM2?   HRESPM2 :
                  HSELM3?   HRESPM3 :
                  HSELM4?   HRESPM4 :
                  HSELM5?   HRESPM5 :
                  HSELM6?   HRESPM6 :
                  HSELM7?   HRESPM7 : 'd0;
// ----------------------------------------------------------------------------
reg [6:0] hselmx_trans;
reg [6:0] hselmx_trans_d1;
wire [6:0] hselmx;
wire [6:0] hselmx_trans_pos;
wire [6:0] htrans_on;
assign hselmx = {HSELM7,HSELM6,HSELM5,HSELM4,HSELM3,HSELM2,HSELM1};
assign htrans_on = {HTRANSM7[1],HTRANSM6[1],HTRANSM5[1],HTRANSM4[1],HTRANSM3[1],HTRANSM2[1],HTRANSM1[1]};
assign hselmx_trans = hselmx & htrans_on;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        hselmx_trans_d1 <= 'd0;
    else
        //hselmx_d1 <= hselmx;
        hselmx_trans_d1 <= hselmx_trans;
end
assign hselmx_trans_pos = hselmx_trans & ~hselmx_trans_d1 ;
assign trans_pend = |hselmx_trans_pos;

endmodule
module ahb_to_sram
#(
    parameter ADDR_WIDTH    = 32   ,   // 10~64
    parameter DATA_WIDTH    = 32  ,   // 8,16,32,64,128,256,512,1024
    parameter HBURST_WIDTH  = 3  ,   // 0,3
    parameter HPROT_WIDTH   = 0   ,   // 0,4,7
    parameter HMASTER_WIDTH = 8     // 0~8
)
(
    // ------ From system ------ //
    input                           HCLK        ,
    input                           HRESETn     ,
    // ------ From SRAM --------//
    input                           sram_rdy    ,
    input [DATA_WIDTH-1:0]          rdata       ,
    // ------ To SRAM ----------//
    output logic [ADDR_WIDTH-1:0]   raddr       ,  
    output logic                    re          ,
    output logic[DATA_WIDTH/8-1:0]  rsel        ,  
    output logic[ADDR_WIDTH-1:0]    waddr       ,
    output logic                    we          ,  
    output logic[DATA_WIDTH-1:0]    wdata       ,  
    output logic[DATA_WIDTH/8-1:0]  wsel        ,   
    // ------ From master ------ //
    input [ADDR_WIDTH-1:0]          HADDR       ,
    input [HBURST_WIDTH-1:0]        HBURST      ,
    input                           HMASTLOCK ,
    input [HPROT_WIDTH-1:0]         HPROT       ,
    input [2:0]                     HSIZE       ,
    input [1:0]                     HTRANS      ,
    input [DATA_WIDTH-1:0]          HWDATA      ,
    input                           HWRITE      ,
    // ------ From interconnect ------ //
    input                           HSEL        ,
    input                           HREADY      ,
    // ------ To interconnect ------ //
    output logic [DATA_WIDTH-1:0]   HRDATA      ,
    output logic                    HREADYOUT   ,
    output logic                    HRESP       
);
// AHB的从机一般是一些高速设备，比如memory之类；
// 此处代码假设slave是memory
// 以下定义了mem接口
/*
    we
    mem_ce
    raddr
    wdata
    rdata
*/
logic mem_ce;
logic transfer_on;
//assign transfer_on = HSEL && HREADY && HTRANS[1]; 
assign transfer_on = HSEL && HTRANS[1];   // HTRANS = NONSEQ/SEQ
typedef enum logic [1:0] {IDLE,MEM_W,MEM_R} state_t;
state_t state_c,state_n;
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        state_c <= IDLE;
    else
        state_c <= state_n;
end
always@(*) begin
    if(~HRESETn)
        state_n = IDLE;
    else begin
        state_n = IDLE;
        case(state_c) 
            IDLE: begin
                state_n = (transfer_on && HWRITE)?  MEM_W :
                          (transfer_on && ~HWRITE)? MEM_R :
                          IDLE;
            end
            MEM_W: begin
                state_n = transfer_on?    (HWRITE?    MEM_W : MEM_R) : IDLE;
            end
            MEM_R: begin
                state_n = transfer_on?    (HWRITE?    MEM_W : MEM_R) : IDLE;
            end
            default:    state_n = IDLE;
        endcase
    end
end
/*
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        mem_ce <= 1'b0;
    else if(state_n == MEM_W | state_n == MEM_R)
        mem_ce <= 1'b1;
    else 
        mem_ce <= 1'b0;
end
*/
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        we <= 1'b0;
    else if(state_n == MEM_W)
        we <= 1'b1;
    else 
        we <= 1'b0;
end
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        re <= 1'b0;
    else if(state_n == MEM_R)
        re <= 1'b1;
    else 
        re <= 1'b0;
end
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        raddr <= 'b0;
    else if(state_n == MEM_R)
        raddr <= HADDR;
    //else 
    //    raddr <= 'b0;
end
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        rsel <= 4'b1111;
    else if(state_n == MEM_R)
        rsel <= 4'b1111;
    //else 
    //    rsel <= 'b0;
end
/*
assign we = (state_n == MEM_W);
assign re = (state_n == MEM_R);
assign raddr = (state_n == MEM_R)?  HADDR : 'd0;
assign rsel = (state_n == MEM_R)?   4'b1111 : 'd0;
assign waddr = {HADDR[ADDR_WIDTH-1:2],2'b0};
*/
assign wdata = HWDATA;


always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        waddr <= 'b0;
    else if(state_n == MEM_W)
        waddr <= {HADDR[ADDR_WIDTH-1:2],2'b0};
    //else 
    //    waddr <= 'b0;
end

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        wsel <= 4'b1111;
    else if(state_n == MEM_W) begin
//always@(*) begin
        if(HSIZE==3'b000) begin
            wsel <= {4'b0001 << HADDR[1:0]};
        end
        else if(HSIZE==3'b001) begin
            wsel <= {4'b0011 << HADDR[1:0]};
        end
        else begin
            wsel <= 4'b1111;
        end
    end
    //else
    //  wsel <= 'b0;
end

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HRDATA <= 'b0;
    else if(state_c == MEM_R)
        HRDATA <= rdata;
end

//assign HRDATA = rdata;
assign HRESP = 1'b0;

logic first_trans;
logic re_pos;
logic we_pos;
logic re_d1;
logic we_d1;
assign first_trans = re_pos || we_pos;
//assign first_trans = we_pos;
assign re_pos = re && ~re_d1;
assign we_pos = we && ~we_d1;

always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)
        re_d1 <= 1'b0;
    else
        re_d1 <= re;
end

always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)
        we_d1 <= 1'b0;
    else
        we_d1 <= we;
end
/*
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HREADYOUT <= 1'b1;
    //else if(first_trans)
    //    HREADYOUT <= 1'b0;
    else //if(state_c == MEM_W | state_c == MEM_R)    // can add condition to extend transfer
        HREADYOUT <= sram_rdy && ~first_trans;
end
*/

assign HREADYOUT = (state_c == IDLE)?  1'b1 : (sram_rdy && ~first_trans);

//assign HREADYOUT = (state_c == MEM_W | state_c == MEM_R) && sram_rdy;

//assign HREADYOUT = ~((state_c == MEM_W | state_c == MEM_R) && ~sram_rdy);
endmodule
module ahb_to_slave
#(
    parameter ADDR_WIDTH    = 32   ,   // 10~64
    parameter DATA_WIDTH    = 32  ,   // 8,16,32,64,128,256,512,1024
    parameter HBURST_WIDTH  = 3  ,   // 0,3
    parameter HPROT_WIDTH   = 0   ,   // 0,4,7
    parameter HMASTER_WIDTH = 8     // 0~8
)
(
    // ------ From system ------ //
    input                           HCLK        ,
    input                           HRESETn     ,
    // ------ From SRAM --------//
    input                           slave_rdy   ,
    input [DATA_WIDTH-1:0]          rdata       ,
    // ------ To SRAM ----------//
    output logic [ADDR_WIDTH-1:0]   raddr       ,  
    output logic                    re          ,
    output logic[DATA_WIDTH/8-1:0]  rsel        ,  
    output logic[ADDR_WIDTH-1:0]    waddr       ,
    output logic                    we          ,  
    output logic[DATA_WIDTH-1:0]    wdata       ,  
    output logic[DATA_WIDTH/8-1:0]  wsel        ,   
    // ------ From master ------ //
    input [ADDR_WIDTH-1:0]          HADDR       ,
    input [HBURST_WIDTH-1:0]        HBURST      ,
    input                           HMASTLOCK   ,
    input [HPROT_WIDTH-1:0]         HPROT       ,
    input [2:0]                     HSIZE       ,
    input [1:0]                     HTRANS      ,
    input [DATA_WIDTH-1:0]          HWDATA      ,
    input                           HWRITE      ,
    // ------ From interconnect ------ //
    input                           HSEL        ,
    input                           HREADY      ,
    // ------ To interconnect ------ //
    output logic [DATA_WIDTH-1:0]   HRDATA      ,
    output logic                    HREADYOUT   ,
    output logic                    HRESP       
);




logic transfer_on;
//assign transfer_on = HSEL && HREADY && HTRANS[1];   // HTRANS = NONSEQ/SEQ
assign transfer_on = HSEL && HTRANS[1];   // HTRANS = NONSEQ/SEQ

typedef enum logic [1:0] {IDLE,SLV_W,SLV_R} state_t;
state_t state_c,state_n;
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        state_c <= IDLE;
    else
        state_c <= state_n;
end
always@(*) begin
    if(~HRESETn)
        state_n = IDLE;
    else begin
        state_n = IDLE;
        case(state_c) 
            IDLE: begin
                state_n = (transfer_on && HWRITE)?  SLV_W :
                          (transfer_on && ~HWRITE)? SLV_R :
                          IDLE;
            end
            SLV_W: begin
                state_n = transfer_on?    (HWRITE?    SLV_W : SLV_R) : IDLE;
            end
            SLV_R: begin
                state_n = transfer_on?    (HWRITE?    SLV_W : SLV_R) : IDLE;
            end
            default:    state_n = IDLE;
        endcase
    end
end

/*
assign we = (state_n == SLV_W);
assign re = (state_n == SLV_R);
assign raddr = (state_n == SLV_R)?  HADDR : 'd0;
assign rsel = (state_n == SLV_R)?   4'b1111 : 'd0;
assign waddr = {HADDR[ADDR_WIDTH-1:2],2'b0};
*/
assign wdata = HWDATA;

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        we <= 1'b0;
    else if(state_n == SLV_W)
        we <= 1'b1;
    else 
        we <= 1'b0;
end
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        re <= 1'b0;
    else if(state_n == SLV_R)
        re <= 1'b1;
    else 
        re <= 1'b0;
end
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        raddr <= 'b0;
    else if(state_n == SLV_R)
        raddr <= HADDR;
    //else 
    //    raddr <= 'b0;
end
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        rsel <= 4'b1111;
    else if(state_n == SLV_R)
        rsel <= 4'b1111;
    //else 
    //    rsel <= 'b0;
end


always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        waddr <= 'b0;
    else if(state_n == SLV_W)
        waddr <= {HADDR[ADDR_WIDTH-1:2],2'b0};
    //else 
    //    waddr <= 'b0;
end

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        wsel <= 4'b1111;
    else if(state_n == SLV_W) begin
//always@(*) begin
        if(HSIZE==3'b000) begin
            wsel <= {4'b0001 << HADDR[1:0]};
        end
        else if(HSIZE==3'b001) begin
            wsel <= {4'b0011 << HADDR[1:0]};
        end
        else begin
            wsel <= 4'b1111;
        end
    end
    //else
    //  wsel <= 'b0;
end

/*
always@(*) begin
        if(HSIZE==3'b000) begin
            wsel <= {4'b0001 << HADDR[1:0]};
        end
        else if(HSIZE==3'b001) begin
            wsel <= {4'b0011 << HADDR[1:0]};
        end
        else begin
            wsel <= 4'b1111;
        end
    end
*/
assign HRDATA = rdata;

assign HRESP = 1'b0;


always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HREADYOUT <= 1'b1;
    else //if(state_n == SLV_R || state_n == SLV_W)
        HREADYOUT <= slave_rdy; // slave inside first_trans
end


//assign HREADYOUT = slave_rdy;

endmodule
module ahb2apb_bridge #(
    parameter ADDR_WIDTH    = 32    ,  // max = 32
    parameter DATA_WIDTH    = 32    ,  // 8,16,32
    parameter HBURST_WIDTH  = 3     ,
    parameter HPROT_WIDTH   = 4
)
(
    // with AHB
    input                           HCLK                    ,   // From AHB
    input                           HRESETn                 ,   // From AHB
    input [ADDR_WIDTH-1:0]          HADDR                   ,   // From AHB
    input [HBURST_WIDTH-1:0]        HBURST                  ,   // From AHB
    input [2:0]                     HSIZE                   ,   // From AHB
    input [1:0]                     HTRANS                  ,   // From AHB
    input [DATA_WIDTH-1:0]          HWDATA                  ,   // From AHB
    
    //input [DATA_WIDTH/8-1:0]        hwstrb                  ,   // From AHB
    input                           HWRITE                  ,   // From AHB
    input                           HSEL                    ,   // From AHB
    input                           HREADY                  ,   // From AHB
    output logic                    HREADYOUT               ,   // To AHB
    output logic                    HRESP                   ,   // To AHB
    //output logic                    hexokay_o               ,   // To AHB
    output logic [DATA_WIDTH-1:0]   HRDATA                  ,   // To AHB
    input                           HMASTLOCK               ,
    input [HPROT_WIDTH-1:0]         HPROT                   ,    // with APB         
    input                           PCLK                    ,   // From APB
    input                           PRESETn                 ,   // From APB
    input                           PCLKen                  ,
    //output logic [ADDR_WIDTH-1:0]   PADDR                   ,   // To APB
    //output logic                    PENABLE                 ,   // To APB
    //output logic                    PWRITE                  ,   // To APB
    //output logic [DATA_WIDTH-1:0]   PWDATA                  ,   // To APB
    //output logic [DATA_WIDTH/8-1:0] pstrb                   ,   // To APB
    //input                           PREADY [0:PSLV_LEN]     ,   // From APBs
    //input [DATA_WIDTH-1:0]          PRDATA [0:PSLV_LEN]      // From APBs
    output logic                    PSELM1                    ,   // To APB
    output logic                    PSELM2                    , 
    output logic                    PSELM3                    , 
    output logic                    PSELM4                    , 
    output logic                    PSELM5                    , 
    output logic [ADDR_WIDTH-1:0]   PADDRM1                   ,
    output logic [ADDR_WIDTH-1:0]   PADDRM2                   ,
    output logic [ADDR_WIDTH-1:0]   PADDRM3                   ,
    output logic [ADDR_WIDTH-1:0]   PADDRM4                   ,
    output logic [ADDR_WIDTH-1:0]   PADDRM5                   ,
    output logic                    PENABLEM1                 ,
    output logic                    PENABLEM2                 ,
    output logic                    PENABLEM3                 ,
    output logic                    PENABLEM4                 ,
    output logic                    PENABLEM5                 ,
    output logic                    PWRITEM1                  ,
    output logic                    PWRITEM2                  ,
    output logic                    PWRITEM3                  ,
    output logic                    PWRITEM4                  ,
    output logic                    PWRITEM5                  ,
    output logic [DATA_WIDTH-1:0]   PWDATAM1                  ,
    output logic [DATA_WIDTH-1:0]   PWDATAM2                  ,
    output logic [DATA_WIDTH-1:0]   PWDATAM3                  ,
    output logic [DATA_WIDTH-1:0]   PWDATAM4                  ,
    output logic [DATA_WIDTH-1:0]   PWDATAM5                  ,
    input                           PREADYM1                  ,   // From APBs
    input [DATA_WIDTH-1:0]          PRDATAM1                  , // From APBs
    input                           PREADYM2                  ,
    input [DATA_WIDTH-1:0]          PRDATAM2                  ,
    input                           PREADYM3                  ,
    input [DATA_WIDTH-1:0]          PRDATAM3                  ,
    input                           PREADYM4                  ,
    input [DATA_WIDTH-1:0]          PRDATAM4                  ,
    input                           PREADYM5                  ,
    input [DATA_WIDTH-1:0]          PRDATAM5                  
);

/* APB Slave List */
// 0. UART                               0x40000000~0x4000ffff
// 1. SPI                                0x40010000~0x4001ffff
// 2. I2C                                0x40020000~0x4002ffff  
// 3. Memory                             0x40030000~0x4003ffff  
// 4. LED                                0x40040000~0x4004ffff   
// Reserved
/*
logic [PSLV_NUM-1:0] PSEL_tmp;
always@(*) begin
    case(HADDR[ADDR_WIDTH+11:ADDR_WIDTH])
        12'h0:  PSEL_tmp = 'b1;
        12'h1:  PSEL_tmp = 'b10;
        12'h2:  PSEL_tmp = 'b100;
        12'h3:  PSEL_tmp = 'b1000;
        12'h4:  PSEL_tmp = 'b10000;
        default:PSEL_tmp = 'b0;
    endcase
end
*/
logic PSEL;
logic PENABLE;
logic [ADDR_WIDTH-1:0] PADDR;
logic PWRITE;
logic [DATA_WIDTH-1:0] PWDATA;

logic [ADDR_WIDTH-1:0] haddr_lat;
logic hwrite_lat;
logic [DATA_WIDTH-1:0] hwdata_lat;

logic pready_mux;
logic [DATA_WIDTH-1:0] prdata_mux;

logic apb_sel;
assign apb_sel = HSEL && HREADY && HTRANS[1];

assign pready_mux = PSELM1?  PREADYM1 :
                    PSELM2?  PREADYM2 :
                    PSELM3?  PREADYM3 :
                    PSELM4?  PREADYM4 :
                    PSELM5?  PREADYM5 : 1'b0;

assign prdata_mux = PSELM1?  PRDATAM1 :
                    PSELM2?  PRDATAM2 :
                    PSELM3?  PRDATAM3 :
                    PSELM4?  PRDATAM4 :
                    PSELM5?  PRDATAM5 : 32'bx;

typedef enum logic [1:0] {IDLE,SETUP,ACCESS} state_t;
state_t state_c,state_n;
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        state_c <= IDLE;
    else 
        state_c <= state_n;
end

always@(*) begin
    state_n = IDLE;
    case(state_c)
        IDLE:   state_n = apb_sel?   SETUP:IDLE;
        SETUP:  state_n = PCLKen? ACCESS:SETUP;
        //ACCESS: state_n = (HSEL)?   ACCESS:IDLE;
        ACCESS: state_n = (pready_mux && PCLKen)?   (apb_sel?  SETUP : IDLE):ACCESS;
        default:state_n = IDLE;
    endcase
end

always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
        haddr_lat <= 'd0;
        hwrite_lat <= 1'b0;
        hwdata_lat <= 'd0;
    end
    else if(HSEL) begin
        haddr_lat <= HADDR;
        hwrite_lat <= HWRITE;
        hwdata_lat <= HWDATA;
    end
end

always_ff@(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn) begin
        PSEL <= 'd0;
        PENABLE <= 'd0;
        PADDR <= 'd0;
        PWRITE <= 'd0;
        PWDATA <= 'd0;
    end
    else if(state_c == IDLE)   begin
        PSEL <= 'd0;
        PENABLE <= 'd0;
        PADDR <= 'd0;
        PWRITE <= 'd0;
        PWDATA <= 'd0;
    end
    else if(state_c == SETUP)  begin    // Lock AHB information
        PSEL <= 1'b1;
        PENABLE <= 1'B0;
        PADDR  <= haddr_lat; 
        PWRITE <= hwrite_lat;
        PWDATA <= hwdata_lat;
    end
    else if(state_c == ACCESS) begin
        PENABLE <= 1'b1;
    end
end

//assign PADDR = HADDR[ADDR_WIDTH-1:0];
//assign PSEL = (state_c != IDLE)? ({{(PSLV_NUM-1){1'b0}},1'b1} << HADDR[ADDR_WIDTH+11:ADDR_WIDTH]) : 'd0;
//assign PSEL = PSEL_tmp;
//logic apb_psel;
//assign apb_psel = (state_c == ACCESS);
//assign apb_psel = (state_c == SETUP) || (state_c == ACCESS);
assign PSELM1 = PSEL && (PADDR >= 32'h10000000 && PADDR <= 32'h1000FFFF);
assign PSELM2 = PSEL && (PADDR >= 32'h10010000 && PADDR <= 32'h1001FFFF);
assign PSELM3 = PSEL && (PADDR >= 32'h10020000 && PADDR <= 32'h1002FFFF);
assign PSELM4 = PSEL && (PADDR >= 32'h10030000 && PADDR <= 32'h1003FFFF);
assign PSELM5 = PSEL && (PADDR >= 32'h10040000 && PADDR <= 32'h1004FFFF);

//assign PENABLE = (state_c == ACCESS);
//assign PWRITE = HWRITE;
//assign PWDATA = HWDATA;
//assign pstrb = hwstrb;
/*
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HRDATA <= 'd0;
    else if(state_c == ACCESS)
        HRDATA <= PRDATA[PSEL];
end
*/

assign HRDATA = prdata_mux;
/*
always_ff@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        HREADYOUT <= 1'b1;
    else if(state_c == ACCESS)
        HREADYOUT <= PREADY[PSEL];
    else 
        HREADYOUT <= 1'b1;
end
*/
//assign HREADYOUT = PCLKen & prdata_mux & (state_n == SETUP);
assign HREADYOUT =  (state_c == IDLE)?   1'b1 :
                    (state_c == SETUP)?  1'b0 : (PCLKen & pready_mux);

assign HRESP   = 1'b0;
//assign hexokay_o = 1'b1;

assign PADDRM1     = PADDR;
assign PADDRM2     = PADDR;
assign PADDRM3     = PADDR;
assign PADDRM4     = PADDR;
assign PADDRM5     = PADDR;
assign PENABLEM1   = PENABLE;
assign PENABLEM2   = PENABLE;
assign PENABLEM3   = PENABLE;
assign PENABLEM4   = PENABLE;
assign PENABLEM5   = PENABLE;
assign PWRITEM1    = PWRITE;
assign PWRITEM2    = PWRITE;
assign PWRITEM3    = PWRITE;
assign PWRITEM4    = PWRITE;
assign PWRITEM5    = PWRITE;
assign PWDATAM1    = PWDATA;
assign PWDATAM2    = PWDATA;
assign PWDATAM3    = PWDATA;
assign PWDATAM4    = PWDATA;
assign PWDATAM5    = PWDATA;


endmodule
module timer
#(
    parameter ADDR_WIDTH    = 32   ,
    parameter DATA_WIDTH    = 32   
)
(
    input                    clk               ,
    input                    rstn              ,
    output logic             slave_rdy         ,
    output logic             timer_int         ,
    input [ADDR_WIDTH-1:0]   raddr             ,
    input                    re                ,
    output logic  [DATA_WIDTH-1:0]   rdata             ,
    input [DATA_WIDTH/8-1:0] rsel              ,
    input [ADDR_WIDTH-1:0]   waddr             ,
    input                    we                ,
    input [DATA_WIDTH-1:0]   wdata             ,
    input [DATA_WIDTH/8-1:0] wsel   
);

logic    [2 :0]  timer_1_control_reg;   
logic    [31:0]  timer_1_load_count;    
logic            timer_1_raw_int_status; 
logic    [2 :0]  timer_2_control_reg;   
logic    [31:0]  timer_2_load_count;    
logic            timer_2_raw_int_status; 
logic    [2 :0]  timer_3_control_reg;   
logic    [31:0]  timer_3_load_count;    
logic            timer_3_raw_int_status; 
logic    [2 :0]  timer_4_control_reg;   
logic    [31:0]  timer_4_load_count;    
logic            timer_4_raw_int_status; 


logic    [31:0]  timer_1_current_value; 
logic            timer_1_int_clear;     
logic            timer_1_int_status;    
logic            timer_1_interrupt;     
logic    [31:0]  timer_2_current_value; 
logic            timer_2_int_clear;     
logic            timer_2_int_status;    
logic            timer_2_interrupt;     
logic    [31:0]  timer_3_current_value; 
logic            timer_3_int_clear;     
logic            timer_3_int_status;    
logic            timer_3_interrupt;     
logic    [31:0]  timer_4_current_value; 
logic            timer_4_int_clear;     
logic            timer_4_int_status;    
logic            timer_4_interrupt;     
logic    [3 :0]  timer_int;             
logic            timers_int_clear;  

logic first_trans;
logic re_d1;
logic we_d1;
logic re_pos;
logic we_pos;

counter  timer_1 (
  .interrupt              (timer_1_interrupt     ),
  .clk                    (clk                   ),
  .rstn                   (rstn                  ),
  .timer_current_value    (timer_1_current_value ),
  .timer_enable           (timer_1_control_reg[0]),
  .timer_load_count       (timer_1_load_count    ),
  .timer_mode             (timer_1_control_reg[1])
);

counter  timer_2 (
  .interrupt              (timer_2_interrupt     ),
  .clk                    (clk                   ),
  .rstn                   (rstn                  ),
  .timer_current_value    (timer_2_current_value ),
  .timer_enable           (timer_2_control_reg[0]),
  .timer_load_count       (timer_2_load_count    ),
  .timer_mode             (timer_2_control_reg[1])
);

counter  timer_3 (
  .interrupt              (timer_3_interrupt     ),
  .clk                    (clk                   ),
  .rstn                   (rstn                  ),
  .timer_current_value    (timer_3_current_value ),
  .timer_enable           (timer_3_control_reg[0]),
  .timer_load_count       (timer_3_load_count    ),
  .timer_mode             (timer_3_control_reg[1])
);

counter  timer_4 (
  .interrupt              (timer_4_interrupt     ),
  .clk                    (clk                   ),
  .rstn                   (rstn                  ),
  .timer_current_value    (timer_4_current_value ),
  .timer_enable           (timer_4_control_reg[0]),
  .timer_load_count       (timer_4_load_count    ),
  .timer_mode             (timer_4_control_reg[1])
);


always @(posedge clk or negedge rstn)
begin
  if(!rstn)
  begin
    timer_1_load_count <= 32'b0;
    timer_1_control_reg <= 3'b0;
    timer_2_load_count <= 32'b0;
    timer_2_control_reg <= 3'b0;
    timer_3_load_count <= 32'b0;
    timer_3_control_reg <= 3'b0;
    timer_4_load_count <= 32'b0;
    timer_4_control_reg <= 3'b0;
  end
  else
  begin // todo with wsel
    if(we)
    begin
      case(waddr[7:2])
        6'b000000:
        begin
          timer_1_load_count <= wdata;
        end
        6'b000010:
        begin
          timer_1_control_reg <= wdata[2:0];
        end
        6'b000101:
        begin
          timer_2_load_count <= wdata;
        end
        6'b000111:
        begin
          timer_2_control_reg <= wdata[2:0];
        end
        6'b001010:
        begin
          timer_3_load_count <= wdata;
        end
        6'b001100:
        begin
          timer_3_control_reg <= wdata[2:0];
        end
        6'b001111:
        begin
          timer_4_load_count <= wdata;
        end
        6'b010001:
        begin
          timer_4_control_reg <= wdata[2:0];
        end
      endcase
    end
  end
end
    

always @(posedge clk)
begin
  if(re)  begin
    case(raddr[7:2])
    6'b000000:
    begin
      rdata <= timer_1_load_count;
    end
    6'b000001:
    begin
      rdata <= timer_1_current_value;
    end
    6'b000010:
    begin
      rdata <= {29'b0, timer_1_control_reg};
    end
    6'b000011:
    begin
      rdata <= 32'b0;
    end
    6'b000100:
    begin
      rdata <= {31'b0, timer_1_int_status};
    end
    6'b000101:
    begin
      rdata <= timer_2_load_count;
    end
    6'b000110:
    begin
      rdata <= timer_2_current_value;
    end
    6'b000111:
    begin
      rdata <= {29'b0, timer_2_control_reg};
    end
    6'b001000:
    begin
      rdata <= 32'b0;
    end
    6'b001001:
    begin
      rdata <= {31'b0, timer_2_int_status};
    end
    6'b001010:
    begin
      rdata <= timer_3_load_count;
    end
    6'b001011:
    begin
      rdata <= timer_3_current_value;
    end
    6'b001100:
    begin
      rdata <= {29'b0, timer_3_control_reg};
    end
    6'b001101:
    begin
      rdata <= 32'b0;
    end
    6'b001110:
    begin
      rdata <= {31'b0, timer_3_int_status};
    end
    6'b001111:
    begin
      rdata <= timer_4_load_count;
    end
    6'b010000:
    begin
      rdata <= timer_4_current_value;
    end
    6'b010001:
    begin
      rdata <= {29'b0, timer_4_control_reg};
    end
    6'b010010:
    begin
      rdata <= 32'b0;
    end
    6'b010011:
    begin
      rdata <= {31'b0, timer_4_int_status};
    end
    6'b101000:
    begin
      rdata <= {28'b0, timer_int};
    end
    6'b101001:
    begin
      rdata <= 32'b0;
    end
    6'b101010:
    begin
      rdata <= {28'b0, timer_4_raw_int_status, timer_3_raw_int_status, timer_2_raw_int_status, timer_1_raw_int_status};
    end
    default:
    begin
      rdata <= 32'bx;
    end
    endcase
  end
  else
	begin
	  rdata <= 32'bx;
	end
end

assign timer_int = {timer_4_int_status, timer_3_int_status, timer_2_int_status, timer_1_int_status};

assign first_trans = re_pos || we_pos;
assign re_pos = re && ~re_d1;
assign we_pos = we && ~we_d1;

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        re_d1 <= 1'b0;
    else
        re_d1 <= re;
end

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        we_d1 <= 1'b0;
    else
        we_d1 <= we;
end

assign slave_rdy = ~first_trans;
//always @(posedge clk or negedge rstn) begin
//    if(!rstn)
//        slave_rdy <= 1'b1;
//    else if(first_trans)
//        slave_rdy <= 1'b0;
//    else
//        slave_rdy <= 1'b1;
//end


assign timer_1_int_clear = (raddr[7:2] == 6'b000011) && re;
assign timer_2_int_clear = (raddr[7:2] == 6'b001000) && re;
assign timer_3_int_clear = (raddr[7:2] == 6'b001101) && re;
assign timer_4_int_clear = (raddr[7:2] == 6'b010010) && re;
assign timers_int_clear =  (raddr[7:2] == 6'b101001) && re;




assign timer_1_int_status = timer_1_raw_int_status && !timer_1_control_reg[2];
always @(posedge clk or negedge rstn)
begin
  if(!rstn)
  begin
    timer_1_raw_int_status <= 1'b0;
  end
  else
  begin
    if(timer_1_control_reg[0])
    begin
      if(timer_1_interrupt)
      begin
        timer_1_raw_int_status <= 1'b1;
      end
      else
      begin
        if(timer_1_int_clear || timers_int_clear)
        begin
          timer_1_raw_int_status <= 1'b0;
        end
      end
    end
    else
    begin
      timer_1_raw_int_status <= 1'b0;
    end
  end
end




assign timer_2_int_status = timer_2_raw_int_status && !timer_2_control_reg[2];
always @(posedge clk or negedge rstn)
begin
  if(!rstn)
  begin
    timer_2_raw_int_status <= 1'b0;
  end
  else
  begin
    if(timer_2_control_reg[0])
    begin
      if(timer_2_interrupt)
      begin
        timer_2_raw_int_status <= 1'b1;
      end
      else
      begin
        if(timer_2_int_clear || timers_int_clear)
        begin
          timer_2_raw_int_status <= 1'b0;
        end
      end
    end
    else
    begin
      timer_2_raw_int_status <= 1'b0;
    end
  end
end




assign timer_3_int_status = timer_3_raw_int_status && !timer_3_control_reg[2];
always @(posedge clk or negedge rstn)
begin
  if(!rstn)
  begin
    timer_3_raw_int_status <= 1'b0;
  end
  else
  begin
    if(timer_3_control_reg[0])
    begin
      if(timer_3_interrupt)
      begin
        timer_3_raw_int_status <= 1'b1;
      end
      else
      begin
        if(timer_3_int_clear || timers_int_clear)
        begin
          timer_3_raw_int_status <= 1'b0;
        end
      end
    end
    else
    begin
      timer_3_raw_int_status <= 1'b0;
    end
  end
end




assign timer_4_int_status = timer_4_raw_int_status && !timer_4_control_reg[2];
always @(posedge clk or negedge rstn)
begin
  if(!rstn)
  begin
    timer_4_raw_int_status <= 1'b0;
  end
  else
  begin
    if(timer_4_control_reg[0])
    begin
      if(timer_4_interrupt)
      begin
        timer_4_raw_int_status <= 1'b1;
      end
      else
      begin
        if(timer_4_int_clear || timers_int_clear)
        begin
          timer_4_raw_int_status <= 1'b0;
        end
      end
    end
    else
    begin
      timer_4_raw_int_status <= 1'b0;
    end
  end
end


endmodule
module counter(
  input                 clk                 ,
  input                 rstn                ,
  input                 timer_enable        ,
  input                 timer_mode          ,
  input        [31:0]   timer_load_count    ,
  output logic [31:0]   timer_current_value ,
  output logic          interrupt           
);


logic     [31:0]  counter;            
logic             timer_enable_flop;  

logic            load_cnt_en;        


always @(posedge clk or negedge rstn)
begin
  if(!rstn)
  begin
      timer_enable_flop <=0;
  end
  else
  begin
      timer_enable_flop <=timer_enable ;
  end
end

assign load_cnt_en= (timer_enable && !timer_enable_flop)
                    || !(|counter[31:0]);

always @(posedge clk or negedge rstn)
begin
  if(!rstn)
  begin
      counter[31:0] <=32'hffffffff;
  end
  else if(load_cnt_en)
  begin
    if(timer_mode)
    begin
      counter[31:0]<=timer_load_count[31:0];
    end
    else 
    begin
      counter[31:0]<=32'hffffffff;
    end
  end
  else if (timer_enable)
  begin
    counter[31:0]<=counter[31:0]-1'b1;
  end
  else
  begin
    counter[31:0]<=counter[31:0];
  end
end

assign timer_current_value[31:0]=counter[31:0];


always @(posedge clk or negedge rstn)
begin
  if(!rstn)
  begin
    interrupt <=1'b0;
  end
  else if(!{|counter[31:0]})
  begin
    interrupt <=1'b1;
  end
  else
  begin
    interrupt<=1'b0 ;
  end
end


endmodule
module apb_to_slave
#(
    parameter ADDR_WIDTH    = 32   ,   // 10~64
    parameter DATA_WIDTH    = 32     // 8,16,32,64,128,256,512,1024
)
(
    // ------ From system ------ //
    input                           PCLK        ,
    input                           PRESETn     ,
    // ------ From slave --------//
    input                           slave_rdy   ,
    input [DATA_WIDTH-1:0]          rdata       ,
    // ------ To SRAM ----------//
    output logic [ADDR_WIDTH-1:0]   raddr       ,  
    output logic                    re          ,
    output logic[DATA_WIDTH/8-1:0]  rsel        ,  
    output logic[ADDR_WIDTH-1:0]    waddr       ,
    output logic                    we          ,  
    output logic[DATA_WIDTH-1:0]    wdata       ,  
    output logic[DATA_WIDTH/8-1:0]  wsel        ,   
    // ------ From master ------ //
    input [ADDR_WIDTH-1:0]          PADDR       ,
    input                           PENABLE     ,
    input [DATA_WIDTH-1:0]          PWDATA      ,
    input                           PWRITE      ,
    // ------ From interconnect ------ //
    input                           PSEL        ,
    // ------ To interconnect ------ //
    output logic [DATA_WIDTH-1:0]   PRDATA      ,
    output logic                    PREADY      ,
    output logic                    PSLVERR       
);




logic transfer_on;
//assign transfer_on = HSEL && HREADY && HTRANS[1];   // HTRANS = NONSEQ/SEQ
assign transfer_on = PENABLE;   // HTRANS = NONSEQ/SEQ

typedef enum logic [1:0] {IDLE,SLV_W,SLV_R} state_t;
state_t state_c,state_n;
always_ff@(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn)
        state_c <= IDLE;
    else
        state_c <= state_n;
end
always@(*) begin
    if(~PRESETn)
        state_n = IDLE;
    else begin
        state_n = IDLE;
        case(state_c) 
            IDLE: begin
                state_n = (transfer_on && PWRITE)?  SLV_W :
                          (transfer_on && ~PWRITE)? SLV_R :
                          IDLE;
            end
            SLV_W: begin
                state_n = transfer_on?    (PWRITE?    SLV_W : SLV_R) : IDLE;
            end
            SLV_R: begin
                state_n = transfer_on?    (PWRITE?    SLV_W : SLV_R) : IDLE;
            end
            default:    state_n = IDLE;
        endcase
    end
end

assign we = (state_n == SLV_W);
assign re = (state_n == SLV_R);
assign raddr = (state_n == SLV_R)?  PADDR : 'd0;
assign rsel = (state_n == SLV_R)?   4'b1111 : 'd0;
assign waddr = {PADDR[ADDR_WIDTH-1:2],2'b0};
assign wdata = PWDATA;

always@(*) begin
    wsel <= 4'b1111;
end

assign PRDATA = rdata;

assign PSLVERR = 1'b0;


always_ff@(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn)
        PREADY <= 1'b0;
    else if(state_c == IDLE)
        PREADY <= 1'b0;
    else 
        PREADY <= slave_rdy;
end


//assign HREADYOUT = slave_rdy;

endmodule
