`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/07 10:01:16
// Design Name: 
// Module Name: paritition_tb
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


module paritition_tb();

parameter TCQ = 1;
parameter DATA_WIDTH = 128;
parameter BYTE_BIT_ENABLE = DATA_WIDTH/8;

reg clk;
reg rst;

reg [DATA_WIDTH-1:0]tdata;
reg tlast;
reg tvalid;
reg [BYTE_BIT_ENABLE-1:0]tkeep;
wire tready;

reg process_done;
wire paritition_done;

reg [DATA_WIDTH-1:0]data[1024:0];
integer i;
initial begin
    clk <= 1'b0;
    rst <= #TCQ 1'b0;
    tvalid <= #TCQ 1'b0;
    tlast <= #TCQ 1'b0;
    tkeep <= #TCQ 16'hFFFF;
    process_done <= #TCQ 1'b0;
    i <= #TCQ 0;
    $readmemh("D:/data", data);
    #16
    rst <= #TCQ 1'b1;
    #100
    $stop;
end

always #2 clk <= ~clk;

always@(posedge clk) begin
    if(tready) begin
        if(i<8) begin
            tvalid <= #TCQ 1'b1;
            tdata <= #TCQ data[i];
            i <= #TCQ i+1;
        end
        else begin
            tvalid <= #TCQ 1'b0;
        end
    end
end

partition test(
    .user_clk		(clk),
    .user_rst		(rst),
        //h2c datapath
    .s_axis_h2c_tdata(tdata),
    .s_axis_h2c_tlast(tlast),
    .s_axis_h2c_tvalid(tvalid),
    .s_axis_h2c_tready(tready),
    .s_axis_h2c_tkeep(tkeep),
        //info fifo
    .info_fifo_din	(),
    .info_fifo_wr_en(),
    .info_fifo_full	(),
        //data fifo
    .data_fifo_din	(),
    .data_fifo_wr_en(),
    .data_fifo_full	(),
        //
    .process_done	(process_done),
    .paritition_done(paritition_done)
    );

endmodule
