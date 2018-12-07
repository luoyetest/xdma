`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 11:25:15
// Design Name: 
// Module Name: partition
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


module partition
    #(
        parameter TCQ = 1,
        parameter DATA_WIDTH = 128,
        parameter BYTE_BIT_ENABLE = DATA_WIDTH/8,
        parameter COL_MAX_SIZE = 4,
        parameter ALIGN_BITS = 128
    )(
        input   user_clk,
        input   user_rst,
        //h2c datapath
        input   [DATA_WIDTH-1:0]s_axis_h2c_tdata,
        input   s_axis_h2c_tlast,
        input   s_axis_h2c_tvalid,
        output  s_axis_h2c_tready,
        input   [BYTE_BIT_ENABLE-1:0]s_axis_h2c_tkeep,
        //info fifo
        output	[DATA_WIDTH-1:0]info_fifo_din,
        output	[COL_MAX_SIZE-1:0]info_fifo_wr_en,
        input	[COL_MAX_SIZE-1:0]info_fifo_full,
        //data fifo
        output	[DATA_WIDTH-1:0]data_fifo_din,
        output	[COL_MAX_SIZE-1:0]data_fifo_wr_en,
        input	[COL_MAX_SIZE-1:0]data_fifo_full,
        //
        input   process_done,
        output  paritition_done
    );
    
    localparam RST = 3'b000, WAIT_TARGET = 3'b001, SET_COUNT = 3'b011, SET_INFO = 3'b111, SET_DATA = 3'b110, WAIT_PROCESS = 3'b100;
    
    reg s_axis_h2c_tready_q;
    reg paritition_done_q;
    reg [2:0]state;
    
    //the format of data
    reg [ALIGN_BITS-1:0]target;
    reg [ALIGN_BITS-1:0]second_row;
    reg [31:0]total_rows;
    reg [15:0]info_rows;
    reg [15:0]data_rows;
    
	reg [COL_MAX_SIZE-1:0]info_seq;
	reg info_head_flag;
	reg [15:0]info_len;
	
	reg [COL_MAX_SIZE-1:0]data_seq;
	reg data_head_flag;
	reg [15:0]d_len;
    reg [15:0]d0_len;
	reg [15:0]d1_len;
	reg [15:0]d2_len;
	reg [15:0]d3_len;

    assign data_fifo_wr_en = s_axis_h2c_tvalid? data_seq:4'b0000;
    assign info_fifo_wr_en = s_axis_h2c_tvalid? info_seq:4'b0000;
    assign s_axis_h2c_tready = s_axis_h2c_tready_q;
    assign paritition_done = paritition_done_q;
    
    assign data_fifo_din = s_axis_h2c_tdata;
    assign info_fifo_din = s_axis_h2c_tdata;
    
    always@(posedge user_clk)
    begin
        if(!user_rst)
        begin
            s_axis_h2c_tready_q <= #TCQ 1'b0;
            paritition_done_q <= #TCQ 1'b0;
            target <= #TCQ 128'h00000000000000000000000000000000;
            second_row <= #TCQ 128'h00000000000000000000000000000000;
            total_rows <= #TCQ 32'h00000000;
            info_rows <= #TCQ 16'h0000;
            data_rows <= #TCQ 16'h0000;
            info_seq <= #TCQ 4'b0000;
            data_seq <= #TCQ 4'b0000;
            state <= #TCQ RST;
        end
        else
        begin
            case(state)
                RST:begin
                    s_axis_h2c_tready_q <= #TCQ 1'b0;
                    paritition_done_q <= #TCQ 1'b0;
                    target <= #TCQ 128'h00000000000000000000000000000000;
                    second_row <= #TCQ 128'h00000000000000000000000000000000;
                    total_rows <= #TCQ 32'h00000000;
                    info_rows <= #TCQ 16'h0000;
                    data_rows <= #TCQ 16'h0000;
                    info_seq <= #TCQ 4'b0000;
                    data_seq <= #TCQ 4'b0000;
                    state <= #TCQ WAIT_TARGET;
                end
                WAIT_TARGET:begin
                    s_axis_h2c_tready_q <= #TCQ 1'b1;
                    if(s_axis_h2c_tvalid)
                    begin
                        target <= #TCQ s_axis_h2c_tdata;
                        state <= #TCQ SET_COUNT;
                    end
                    else
                    begin
                        state <= #TCQ WAIT_TARGET;
                    end
                end
                SET_COUNT:begin
                    if(s_axis_h2c_tvalid)
                    begin
                        second_row <= #TCQ s_axis_h2c_tdata;
                        total_rows <= #TCQ s_axis_h2c_tdata[63:32];
                        info_rows <= #TCQ s_axis_h2c_tdata[31:16];
                        data_rows <= #TCQ s_axis_h2c_tdata[15:0];
						info_seq <= #TCQ 4'b0001;
						info_head_flag <= #TCQ 1'b1;
                        state <= #TCQ SET_INFO;
                    end
                    else
                    begin
                        state <= #TCQ SET_COUNT;
                    end
                end
                SET_INFO:begin
                	//format
                    if(s_axis_h2c_tvalid && info_rows>0 && info_head_flag)
                    begin
						info_len <= #TCQ {3'b0000, s_axis_h2c_tdata[95:84]} - s_axis_h2c_tdata[83:80]>0?0:1;
						//
						if(s_axis_h2c_tdata[95:84]>0)
						begin
							info_head_flag <= #TCQ 1'b0;
						end
						else
						begin
							//if true, will change state
							if(info_rows==1) begin
								info_seq <= #TCQ 4'b0000;
							end
							else begin
								info_seq <= #TCQ {info_seq[2:0], 1'b0};
							end
							//info_head_flag <= #TCQ 1'b1;
						end
						//need to debug
						case(info_seq)
							4'b0001:begin
								d0_len <= #TCQ s_axis_h2c_tdata[127:112];
							end
							4'b0010:begin
								d1_len <= #TCQ s_axis_h2c_tdata[127:112];
							end
							4'b0100:begin
								d2_len <= #TCQ s_axis_h2c_tdata[127:112];
							end
							4'b1000:begin
								d3_len <= #TCQ s_axis_h2c_tdata[127:112];
							end
						endcase
						//end
						info_rows <= #TCQ info_rows-1'b1;
                    end
					else if(s_axis_h2c_tvalid && info_rows>0 && ~info_head_flag)
					begin
						if(info_len>1)
						begin
							info_len <= #TCQ info_len-1'b1;
						end
						else
						begin
							//if true, will change state
							if(info_rows==1) begin
								info_seq <= #TCQ 4'b0000;
							end
							else begin
								info_seq <= #TCQ {info_seq[2:0], 1'b0};
							end
							info_head_flag <= #TCQ 1'b1;
						end
						info_rows <= #TCQ info_rows-1'b1;
					end
					//change state
					if(s_axis_h2c_tvalid && info_rows==1)
					begin
						data_seq <= #TCQ 4'b0001;
						data_head_flag <= #TCQ 1'b1;
						state <= #TCQ SET_DATA;
					end
					else begin
						state <= #TCQ SET_INFO;
					end
                end
				SET_DATA:begin
					if(s_axis_h2c_tvalid && data_rows>0 && data_head_flag)
					begin
						case(data_seq)
							4'b0001:begin
								d_len <= #TCQ {3'b0000, d0_len[15:4]} - d0_len[3:0]>0?0:1;
								if(d0_len[15:4]>0)
								begin
									data_head_flag <= #TCQ 1'b0;
								end
								else
								begin
									if(data_rows==1) begin
										data_seq <= #TCQ 4'b0000;
									end
									else begin
										data_seq <= #TCQ {data_seq[2:0], 1'b0};
									end
									//data_head_flag <= #TCQ 1'b1;
								end
							end
							4'b0010:begin
								d_len <= #TCQ {3'b0000, d1_len[15:4]} - d1_len[3:0]>0?0:1;
								if(d1_len[15:4]>0)
								begin
									data_head_flag <= #TCQ 1'b0;
								end
								else
								begin
									if(data_rows==1) begin
										data_seq <= #TCQ 4'b0000;
									end
									else begin
										data_seq <= #TCQ {data_seq[2:0], 1'b0};
									end
									//data_head_flag <= #TCQ 1'b1;
								end
							end
							4'b0100:begin
								d_len <= #TCQ {3'b0000, d2_len[15:4]} - d2_len[3:0]>0?0:1;
								if(d2_len[15:4]>0)
								begin
									data_head_flag <= #TCQ 1'b0;
								end
								else
								begin
									if(data_rows==1) begin
										data_seq <= #TCQ 4'b0000;
									end
									else begin
										data_seq <= #TCQ {data_seq[2:0], 1'b0};
									end
									//data_head_flag <= #TCQ 1'b1;
								end
							end
							4'b1000:begin
								d_len <= #TCQ {3'b0000, d3_len[15:4]} - d3_len[3:0]>0?0:1;
								if(d3_len[15:4]>0)
								begin
									data_head_flag <= #TCQ 1'b0;
								end
								else
								begin
									data_seq <= #TCQ {data_seq[2:0], 1'b0};
									//data_head_flag <= #TCQ 1'b1;
								end
							end
						endcase
						data_rows <= #TCQ data_rows-1'b1;
					end
					else if(s_axis_h2c_tvalid && data_rows>0 && ~data_head_flag)
					begin
						if(d_len>1)
						begin
							d_len <= #TCQ d_len-1'b1;
						end
						else begin
							if(data_rows==1) begin
								data_seq <= #TCQ 4'b0000;
							end
							else begin
								data_seq <= #TCQ {data_seq[2:0], 1'b0};
							end
							data_head_flag <= #TCQ 1'b1;
						end
						data_rows <= #TCQ data_rows-1'b1;
					end
					//change state
					if(s_axis_h2c_tvalid && data_rows==1)
					begin
						s_axis_h2c_tready_q <= #TCQ 1'b0;
						paritition_done_q <= #TCQ 1'b1;
						state <= #TCQ WAIT_PROCESS;
					end
					else begin
						state <= #TCQ SET_DATA;
					end
				end
				WAIT_PROCESS:begin
					if(process_done)
					begin
						state <= #TCQ RST;
					end
					else begin
					    paritition_done_q <= #TCQ 1'b0;
						state <= #TCQ WAIT_PROCESS;
					end
				end
            endcase
        end
    end

endmodule
