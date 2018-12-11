`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/11 11:18:34
// Design Name: 
// Module Name: feedback_top
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


module feedback_top #(
        parameter TCQ = 1,
        parameter DATA_WIDTH = 128,
        parameter BYTE_BIT_ENABLE = DATA_WIDTH/8
    )(
        input   user_clk,
        input   user_rst,
        //c2h datapath
        output  [DATA_WIDTH-1:0]m_axis_c2h_tdata,
        output  m_axis_c2h_tlast,
        output  m_axis_c2h_tvalid,
        input   m_axis_c2h_tready,
        output  [BYTE_BIT_ENABLE-1:0]m_axis_c2h_tkeep,
        //
        input   process_done,
        input   [31:0]data_len,
        //
        input   [DATA_WIDTH-1:0]din,
        input   wr_en
    );
    
    wire [DATA_WIDTH-1:0]fifo_dout;
    wire fifo_rd_en;
    wire fifo_empty;
    
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
    fifo_generator_0 fifo_i(
            .clk(user_clk),
            .srst(~user_rst),
            .din(din),
            .wr_en(wr_en),
            .rd_en(fifo_rd_en),
            .dout(fifo_dout),
            .full(),
            .empty(fifo_empty)
          );
endmodule
