`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/11 11:28:40
// Design Name: 
// Module Name: feedback_tb
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


module feedback_tb();
    parameter TCQ = 1;
    parameter DATA_WIDTH = 128;
    parameter BYTE_BIT_ENABLE = DATA_WIDTH/8;
    
    reg clk;
    reg rst;
    
    wire [DATA_WIDTH-1:0]tdata;
    wire tlast;
    wire tvalid;
    wire [BYTE_BIT_ENABLE-1:0]tkeep;
    reg tready;
    
    reg process_done;
    
    reg [DATA_WIDTH-1:0]data;
    reg [31:0]dlen;
    
    reg wr_en;
    reg start;
    
    initial begin
        clk <= 1'b0;
        rst <= #TCQ 1'b0;
        tready <= #TCQ 1'b1;
        process_done <= #TCQ 1'b0;
        data <= #TCQ 0;
        dlen <= #TCQ 0;
        start <= #TCQ 0;
        wr_en <= #TCQ 1'b0;
        #16
        rst <= #TCQ 1'b1;
        #80
        start <= #TCQ 1;
        #100
        start <= #TCQ 0;
        #8
        process_done <= #TCQ 1'b1;
        #4
        process_done <= #TCQ 1'b0;
    end
    
    always #2 clk <= ~clk;
    
    always@(posedge clk) begin
        if(start) begin
            data <= #TCQ data + 1;
            dlen <= #TCQ dlen + 1;
            wr_en <= #TCQ 1'b1;
        end
        else begin
            wr_en <= #TCQ 1'b0;
        end
    end
    
    feedback_top #(
            .TCQ(TCQ),
            .DATA_WIDTH(DATA_WIDTH)
        )top(
            .user_clk(clk),
            .user_rst(rst),
            //c2h datapath
            .m_axis_c2h_tdata(tdata),
            .m_axis_c2h_tlast(tlast),
            .m_axis_c2h_tvalid(tvalid),
            .m_axis_c2h_tready(tready),
            .m_axis_c2h_tkeep(tkeep),
            //
            .process_done(process_done),
            .data_len(dlen),
            .din(data),
            .wr_en(wr_en)
        );
    
endmodule
