`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/12 16:57:58
// Design Name: 
// Module Name: app_tp
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


module app_tp();

parameter TCQ = 1;
parameter DATA_WIDTH = 128;
parameter BYTE_BIT_ENABLE = DATA_WIDTH/8;

reg clk;
reg rst;

//h2c
reg [DATA_WIDTH-1:0]tdata;
reg tlast;
reg tvalid;
reg [BYTE_BIT_ENABLE-1:0]tkeep;
wire tready;

//c2h
wire [DATA_WIDTH-1:0]c2h_tdata;
wire c2h_tlast;
wire c2h_tvalid;
wire c2h_tkeep;
reg c2h_tready;

reg [DATA_WIDTH-1:0]data[1024:0];
integer i;
initial begin
    clk <= 1'b0;
    rst <= #TCQ 1'b0;
    tvalid <= #TCQ 1'b0;
    tlast <= #TCQ 1'b0;
    tkeep <= #TCQ 16'hFFFF;
    c2h_tready <= #TCQ 1'b0;
    i <= #TCQ 0;
    $readmemh("D:/data", data);
    #16
    rst <= #TCQ 1'b1;
    #100
    c2h_tready <= #TCQ 1'b1;
end

always #2 clk <= ~clk;

always@(posedge clk) begin
    if(tready) begin
        if(i<113) begin
            tvalid <= #TCQ 1'b1;
            tdata <= #TCQ data[i];
            i <= #TCQ i+1;
        end
        else begin
            tvalid <= #TCQ 1'b0;
        end
    end
end

     app 
    #(
       .TCQ(TCQ),
       .DATA_WIDTH(DATA_WIDTH),
       .BYTE_BIT_ENABLE(BYTE_BIT_ENABLE)
    )
    app_i(
       .user_clk           (clk),
       .user_rst           (rst),
       .m_axis_c2h_tdata   (c2h_tdata),
       .m_axis_c2h_tlast   (c2h_tlast),
       .m_axis_c2h_tvalid  (c2h_tvalid),
       .m_axis_c2h_tready  (c2h_tready),
       .m_axis_c2h_tkeep   (c2h_tkeep),
       .s_axis_h2c_tdata   (tdata),
       .s_axis_h2c_tlast   (tlast),
       .s_axis_h2c_tvalid  (tvalid),
       .s_axis_h2c_tready  (tready),
       .s_axis_h2c_tkeep   (tkeep),
       .irq_req            (),
       .irq_ack            ()
    );

endmodule
