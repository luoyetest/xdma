`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/12 15:41:47
// Design Name: 
// Module Name: filter
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


module filter #(
        parameter TCQ = 1,
        parameter DATA_WIDTH = 128
    )(
        input   user_clk,
        input   user_rst,
        //
        input   paritition_done,
        output  process_done,
        //data out fifo port
        output  [DATA_WIDTH-1:0]dout,
        output  wr_en,
        input   full,
        output	[31:0]len,
        //
        input	[DATA_WIDTH-1:0]target,
        input	[DATA_WIDTH-1:0]second_row,
        //info in fifo port
        output  info_0_rd_en,
        input   [DATA_WIDTH-1:0]info_0_dout,
        input   info_0_empty,
        output  info_1_rd_en,
        input   [DATA_WIDTH-1:0]info_1_dout,
        input   info_1_empty,
        output  info_2_rd_en,
        input   [DATA_WIDTH-1:0]info_2_dout,
        input   info_2_empty,
        output  info_3_rd_en,
        input   [DATA_WIDTH-1:0]info_3_dout,
        input   info_3_empty, 
        //data in fifo port
        output  data_0_rd_en,
        input   [DATA_WIDTH-1:0]data_0_dout,
        input   data_0_empty,
        output  data_1_rd_en,
        input   [DATA_WIDTH-1:0]data_1_dout,
        input   data_1_empty,
        output  data_2_rd_en,
        input   [DATA_WIDTH-1:0]data_2_dout,
        input   data_2_empty,
        output  data_3_rd_en,
        input   [DATA_WIDTH-1:0]data_3_dout,
        input   data_3_empty
    );
    
    localparam RST = 3'b000, PROCESS = 3'b001, WRITE_FULL = 3'b011, DONE = 3'b111;

    reg [2:0]state;

    reg [DATA_WIDTH-1:0]dout_q;
    reg wr_en_q;
    reg [31:0]len_q;
    reg [31:0]count;
    
    reg process_done_q;
    
    reg info_0_rd_en_q;
    reg info_1_rd_en_q;
    reg info_2_rd_en_q;
    reg info_3_rd_en_q;
    
    reg data_0_rd_en_q;
    reg data_1_rd_en_q;
    reg data_2_rd_en_q;
    reg data_3_rd_en_q;
    
    assign dout = dout_q;
    assign wr_en = wr_en_q;
    assign len = len_q;
    assign process_done = process_done_q;
    assign info_0_rd_en = info_0_rd_en_q;
    assign info_1_rd_en = info_1_rd_en_q;
    assign info_2_rd_en = info_2_rd_en_q;
    assign info_3_rd_en = info_3_rd_en_q;
    assign data_0_rd_en = data_0_rd_en_q;
    assign data_1_rd_en = data_1_rd_en_q;
    assign data_2_rd_en = data_2_rd_en_q;
    assign data_3_rd_en = data_3_rd_en_q;
    
    always@(posedge user_clk) begin
        if(!user_rst) begin
            dout_q <= #TCQ 0;
            wr_en_q <= #TCQ 1'b0;
            len_q <= #TCQ 0;
            count <= #TCQ 0;
            process_done_q <= #TCQ 1'b0;
            info_0_rd_en_q <= #TCQ 1'b0;
            info_1_rd_en_q <= #TCQ 1'b0;
            info_2_rd_en_q <= #TCQ 1'b0;
            info_3_rd_en_q <= #TCQ 1'b0;
            data_0_rd_en_q <= #TCQ 1'b0;
            data_1_rd_en_q <= #TCQ 1'b0;
            data_2_rd_en_q <= #TCQ 1'b0;
            data_3_rd_en_q <= #TCQ 1'b0;
            state <= #TCQ RST;
        end
        else begin
            case(state)
            	RST: begin
            		dout_q <= #TCQ 0;
		            wr_en_q <= #TCQ 1'b0;
		            count <= #TCQ 0;
		            process_done_q <= #TCQ 1'b0;
		            info_0_rd_en_q <= #TCQ 1'b0;
		            info_1_rd_en_q <= #TCQ 1'b0;
		            info_2_rd_en_q <= #TCQ 1'b0;
		            info_3_rd_en_q <= #TCQ 1'b0;
		            data_0_rd_en_q <= #TCQ 1'b0;
		            data_1_rd_en_q <= #TCQ 1'b0;
		            data_2_rd_en_q <= #TCQ 1'b0;
		            data_3_rd_en_q <= #TCQ 1'b0;
		            if(paritition_done) begin
		            	state <= #TCQ PROCESS;
		            end
            	end
            	PROCESS: begin
            		if(~data_3_empty) begin
            			dout_q <= #TCQ data_3_dout;
            			data_3_rd_en_q <= #TCQ 1'b1;
            			wr_en_q <= #TCQ 1'b1;
            			count <= #TCQ count + 1;
            		end
            		else begin
            			data_3_rd_en_q <= #TCQ 1'b0;
            			wr_en_q <= #TCQ 1'b0;
            			state <= WRITE_FULL;
            		end
            	end
            	WRITE_FULL: begin
            		if(count <= 64) begin
            			dout_q <= #TCQ count;
            			wr_en_q <= #TCQ 1'b1;
            			count <= #TCQ count + 1;
            		end
            		else begin
            			wr_en_q <= #TCQ 1'b0;
            			state <= DONE;
            		end
            	end
            	DONE: begin
            		process_done_q <= #TCQ 1'b1;
            		len_q <= #TCQ count;
            		state <= RST;
            	end

            endcase
        end
    end
endmodule
