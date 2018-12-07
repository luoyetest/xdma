`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/04 17:41:39
// Design Name: 
// Module Name: app
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module app
    #(
        parameter TCQ = 1,
        parameter DATA_WIDTH = 128,
        parameter IRQ_WIDTH = 1,
        parameter BYTE_BIT_ENABLE = DATA_WIDTH/8
    )(
        input   user_clk,
        input   user_rst,
        output  [DATA_WIDTH-1:0]m_axis_c2h_tdata,
        output  m_axis_c2h_tlast,
        output  m_axis_c2h_tvalid,
        input   m_axis_c2h_tready,
        output  [BYTE_BIT_ENABLE-1:0]m_axis_c2h_tkeep,
        input   [DATA_WIDTH-1:0]s_axis_h2c_tdata,
        input   s_axis_h2c_tlast,
        input   s_axis_h2c_tvalid,
        output  s_axis_h2c_tready,
        input   [BYTE_BIT_ENABLE-1:0]s_axis_h2c_tkeep,
        output  [IRQ_WIDTH-1:0]irq_req,
        input   [IRQ_WIDTH-1:0]irq_ack
    );
    
    reg temp;
    reg irq_req_q;
    
    reg [DATA_WIDTH-1:0]m_axis_c2h_tdata_q;
    reg m_axis_c2h_tlast_q;
    reg m_axis_c2h_tvalid_q;
    reg [BYTE_BIT_ENABLE-1:0]m_axis_c2h_tkeep_q;
    
    
    assign irq_req = irq_req_q;
    assign m_axis_c2h_tdata = m_axis_c2h_tdata_q;
    assign m_axis_c2h_tlast = m_axis_c2h_tlast_q;
    assign m_axis_c2h_tvalid = m_axis_c2h_tvalid_q;
    assign m_axis_c2h_tkeep = m_axis_c2h_tkeep_q;
    
    
    always@(posedge user_clk)
    begin
        if(!user_rst)
            temp <= #TCQ 0;
        else
            temp <= #TCQ 1;
    end
    
endmodule
