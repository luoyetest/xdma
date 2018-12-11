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
        parameter COL_MAX_SIZE = 4,
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
    
    reg irq_req_q;
    
    //fifo rst
    wire rst_p;
    
    wire process_done;
    //partition
    wire [DATA_WIDTH-1:0]target;
    wire [DATA_WIDTH-1:0]second_row;
    wire paritition_done;
    wire [DATA_WIDTH-1:0]info_fifo_din;
    wire [COL_MAX_SIZE-1:0]info_fifo_wr_en;
    wire [COL_MAX_SIZE-1:0]info_fifo_full;
    wire [DATA_WIDTH-1:0]data_fifo_din;
    wire [COL_MAX_SIZE-1:0]data_fifo_wr_en;
    wire [COL_MAX_SIZE-1:0]data_fifo_full;
    
    //feedback
    wire [31:0]data_len;
    wire [DATA_WIDTH-1:0]fifo_dout;
    wire fifo_rd_en;
    wire fifo_empty;
    
    //back fifo port
    wire [DATA_WIDTH-1:0]fifo_din;
    wire fifo_wr_en;
    wire fifo_full;
    
    //info fifo port
    wire info_0_rd_en;
    wire [DATA_WIDTH-1:0]info_0_dout;
    wire info_0_empty;
    wire info_1_rd_en;
    wire [DATA_WIDTH-1:0]info_1_dout;
    wire info_1_empty;
    wire info_2_rd_en;
    wire [DATA_WIDTH-1:0]info_2_dout;
    wire info_2_empty;
    wire info_3_rd_en;
    wire [DATA_WIDTH-1:0]info_3_dout;
    wire info_3_empty;

    //data fifo port
    wire data_3_rd_en;
    wire [DATA_WIDTH-1:0]data_3_dout;
    wire data_3_empty;
    wire data_2_rd_en;
    wire [DATA_WIDTH-1:0]data_2_dout;
    wire data_2_empty;
    wire data_1_rd_en;
    wire [DATA_WIDTH-1:0]data_1_dout;
    wire data_1_empty;
    wire data_0_rd_en;
    wire [DATA_WIDTH-1:0]data_0_dout;
    wire data_0_empty;
    
    assign irq_req = irq_req_q;
    assign rst_p = ~user_rst;

	partition
    #(
        .TCQ(TCQ),
        .DATA_WIDTH(DATA_WIDTH),
        .COL_MAX_SIZE(COL_MAX_SIZE),
        .ALIGN_BITS(DATA_WIDTH)
    )partition_i(
        .user_clk			(user_clk),
        .user_rst			(user_rst),
        //h2c datapath
        .s_axis_h2c_tdata	(s_axis_h2c_tdata),
        .s_axis_h2c_tlast	(s_axis_h2c_tlast),
        .s_axis_h2c_tvalid	(s_axis_h2c_tvalid),
        .s_axis_h2c_tready	(s_axis_h2c_tready),
        .s_axis_h2c_tkeep	(s_axis_h2c_tkeep),
        //info fifo
        .info_fifo_din		(info_fifo_din),
        .info_fifo_wr_en	(info_fifo_wr_en),
        .info_fifo_full		(info_fifo_full),
        //data fifo
        .data_fifo_din		(data_fifo_din),
        .data_fifo_wr_en	(data_fifo_wr_en),
        .data_fifo_full		(data_fifo_full),
        //
        .process_done		(process_done),
        .paritition_done	(paritition_done),
        .target_o			(target),
        .second_row_o		(second_row)
    );
    
    feedback #(
        .TCQ(TCQ),
        .DATA_WIDTH(DATA_WIDTH)
    )feedback_i(
        .user_clk(user_clk),
        .user_rst(user_rst),
        //c2h datapath
        .m_axis_c2h_tdata(m_axis_c2h_tdata),
        .m_axis_c2h_tlast(m_axis_c2h_tlast),
        .m_axis_c2h_tvalid(m_axis_c2h_tvalid),
        .m_axis_c2h_tready(m_axis_c2h_tready),
        .m_axis_c2h_tkeep(m_axis_c2h_tkeep),
        //fifo
        .fifo_dout(fifo_dout),
        .fifo_rd_en(fifo_rd_en),
        .fifo_empty(fifo_empty),
        //
        .process_done(process_done),
        .data_len(data_len)
    );
    
    back back_i(
        .clk(user_clk),
        .srst(rst_p),
        .din(fifo_din),
        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .dout(fifo_dout),
        .full(fifo_full),
        .empty(fifo_empty)
    );
    
    info_0 info_0_i(
        .clk(user_clk),
        .srst(rst_p),
        .din(info_fifo_din),
        .wr_en(info_fifo_wr_en[0]),
        .rd_en(info_0_rd_en),
        .dout(info_0_dout),
        .full(info_fifo_full[0]),
        .empty(info_0_empty)
    );    

    info_1 info_1_i(
        .clk(user_clk),
        .srst(rst_p),
        .din(info_fifo_din),
        .wr_en(info_fifo_wr_en[1]),
        .rd_en(info_1_rd_en),
        .dout(info_1_dout),
        .full(info_fifo_full[1]),
        .empty(info_1_empty)
    );  
    
    info_2 info_2_i(
        .clk(user_clk),
        .srst(rst_p),
        .din(info_fifo_din),
        .wr_en(info_fifo_wr_en[2]),
        .rd_en(info_2_rd_en),
        .dout(info_2_dout),
        .full(info_fifo_full[2]),
        .empty(info_2_empty)
    );  
    
    info_3 info_3_i(
        .clk(user_clk),
        .srst(rst_p),
        .din(info_fifo_din),
        .wr_en(info_fifo_wr_en[3]),
        .rd_en(info_3_rd_en),
        .dout(info_3_dout),
        .full(info_fifo_full[3]),
        .empty(info_3_empty)
    );  
    
    data_3 data_3_i(
        .clk(user_clk),
        .srst(rst_p),
        .din(data_fifo_din),
        .wr_en(data_fifo_wr_en[3]),
        .rd_en(data_3_rd_en),
        .dout(data_3_dout),
        .full(data_fifo_full[3]),
        .empty(data_3_empty)
    ); 
    data_2 data_2_i(
        .clk(user_clk),
        .srst(rst_p),
        .din(data_fifo_din),
        .wr_en(data_fifo_wr_en[2]),
        .rd_en(data_2_rd_en),
        .dout(data_2_dout),
        .full(data_fifo_full[2]),
        .empty(data_2_empty)
    ); 
    data_1 data_1_i(
        .clk(user_clk),
        .srst(rst_p),
        .din(data_fifo_din),
        .wr_en(data_fifo_wr_en[1]),
        .rd_en(data_1_rd_en),
        .dout(data_1_dout),
        .full(data_fifo_full[1]),
        .empty(data_1_empty)
    ); 
    data_0 data_0_i(
        .clk(user_clk),
        .srst(rst_p),
        .din(data_fifo_din),
        .wr_en(data_fifo_wr_en[0]),
        .rd_en(data_0_rd_en),
        .dout(data_0_dout),
        .full(data_fifo_full[0]),
        .empty(data_3_empty)
    ); 
    
endmodule
