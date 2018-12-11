`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/10 15:11:59
// Design Name: 
// Module Name: feedback
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


module feedback #(
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
        //fifo
        input	[DATA_WIDTH-1:0]fifo_dout,
        output	fifo_rd_en,
        input	fifo_empty,
        //
        input   process_done,
        input   [31:0]data_len
    );
    
    localparam RST = 3'b000, PREPARE = 3'b001, PREPARE_END = 3'b011, WAIT_READY = 3'b111, TRANSMIT = 3'b110;
    
    reg [2:0]state;
    
    reg [31:0]count;
    
    reg m_axis_c2h_tlast_q;
    reg m_axis_c2h_tvalid_q;
    reg [BYTE_BIT_ENABLE-1:0]m_axis_c2h_tkeep_q;
    
    //reg fifo_rd_en_q;
    
    assign m_axis_c2h_tdata = fifo_dout;
    assign m_axis_c2h_tlast = m_axis_c2h_tlast_q;
    assign m_axis_c2h_tvalid = m_axis_c2h_tvalid_q;
    assign m_axis_c2h_tkeep = m_axis_c2h_tkeep_q;
    //assign fifo_rd_en = fifo_rd_en_q;
    assign fifo_rd_en = m_axis_c2h_tvalid & m_axis_c2h_tready;
    
    always@(posedge user_clk) begin
        if(!user_rst) begin
            m_axis_c2h_tlast_q <= #TCQ 1'b0;
            m_axis_c2h_tvalid_q <= #TCQ 1'b0;
            m_axis_c2h_tkeep_q <= #TCQ 16'hFFFF;
            //fifo_rd_en_q <= #TCQ 1'b0;
            state <= #TCQ RST;
        end
        else begin
            case(state)
                RST: begin
                    m_axis_c2h_tlast_q <= #TCQ 1'b0;
                    m_axis_c2h_tvalid_q <= #TCQ 1'b0;
                    m_axis_c2h_tkeep_q <= #TCQ 16'hFFFF;
                    //fifo_rd_en_q <= #TCQ 1'b0;
                    if(process_done) begin
                        state <= #TCQ PREPARE;
                    end
                    else begin
                        state <= #TCQ RST;
                    end
                end
                PREPARE: begin
                    count <= #TCQ data_len;
                    state <= #TCQ WAIT_READY;
                end
                WAIT_READY: begin
                    m_axis_c2h_tvalid_q <= #TCQ 1'b1;
                    if(m_axis_c2h_tready) begin
                        count <= #TCQ count-1'b1;
                        state <= #TCQ TRANSMIT;
                    end
                end
                TRANSMIT: begin
                	if(m_axis_c2h_tready) begin
                		count <= #TCQ count-1'b1;
                	end
                	if(count == 1) begin
                		m_axis_c2h_tlast_q <= #TCQ 1'b1;
                		state <= #TCQ RST;
                	end
                end
            endcase
        end
    end
    
endmodule
