`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/04 16:18:57
// Design Name: 
// Module Name: dma_ep
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


module dma_ep
    #(
        parameter LINK_WIDTH = 8,
        parameter DATA_WIDTH = 128,
        parameter IRQ_WIDTH = 1,
        parameter BYTE_BIT_ENABLE = DATA_WIDTH/8
    )(
        input   sys_clk_p,
        input   sys_clk_n,
        input   sys_rst_n,
        output  [LINK_WIDTH-1:0]pci_exp_txp,
        output  [LINK_WIDTH-1:0]pci_exp_txn,
        input   [LINK_WIDTH-1:0]pci_exp_rxp,
        input   [LINK_WIDTH-1:0]pci_exp_rxn,
        output  [3:0]led
    );
    
    localparam TCQ = 1;

    wire    sys_clk;
    wire    sys_rst_n_c;
    wire    user_link_up;
    wire    user_clk;
    wire    user_aresetn;
    wire    [IRQ_WIDTH-1:0]usr_irq_req;
    wire    [IRQ_WIDTH-1:0]usr_irq_ack;
	wire    msi_enable;
	wire    [2:0]msi_vector_width;
	
	wire	[DATA_WIDTH-1:0]s_axis_c2h_tdata;
	wire	s_axis_c2h_tlast;
	wire	s_axis_c2h_tvalid;
	wire	s_axis_c2h_tready;
	wire	[BYTE_BIT_ENABLE-1:0]s_axis_c2h_tkeep;
	
	wire	[DATA_WIDTH-1:0]m_axis_h2c_tdata;
	wire	m_axis_h2c_tlast;
	wire	m_axis_h2c_tvalid;
	wire	m_axis_h2c_tready;
	wire	[BYTE_BIT_ENABLE-1:0]m_axis_h2c_tkeep;
	
	reg		[25:0]heartbeat;
        
    
    assign led[0] = user_link_up;
    assign led[1] = heartbeat[25];
    assign led[2] = msi_enable;
    assign led[3] = user_aresetn;
    
    //-----------------------------I/O BUFFERS------------------------//
    IBUF   sys_reset_n_ibuf (.O(sys_rst_n_c), .I(sys_rst_n));
    IBUFDS_GTE2 refclk_ibuf (.O(sys_clk), .ODIV2(), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));
    
    always@(posedge user_clk)
    begin
        heartbeat <= #TCQ heartbeat + 1'b1;
    end
     
    //xdma ip     
    xdma_0 xdma_0_i(
        .sys_clk				(sys_clk),
        .sys_rst_n				(sys_rst_n_c),
        .user_lnk_up			(user_link_up),
        .pci_exp_txp			(pci_exp_txp),
        .pci_exp_txn			(pci_exp_txn),
        .pci_exp_rxp			(pci_exp_rxp),
        .pci_exp_rxn			(pci_exp_rxn),
        .axi_aclk				(user_clk),
        .axi_aresetn			(user_aresetn),
		.usr_irq_req			(usr_irq_req),
		.usr_irq_ack			(usr_irq_ack),
		.msi_enable				(msi_enable),
		.msi_vector_width		(msi_vector_width),
		.cfg_mgmt_addr  		( 19'b0 ),
		.cfg_mgmt_write 		( 1'b0 ),
		.cfg_mgmt_write_data 	( 32'b0 ),
		.cfg_mgmt_byte_enable 	( 4'b0 ),
		.cfg_mgmt_read 		 	( 1'b0 ),
		.cfg_mgmt_read_data 	(),
		.cfg_mgmt_read_write_done 		(),
		.cfg_mgmt_type1_cfg_reg_access 	( 1'b0 ),
		.s_axis_c2h_tdata_0		(s_axis_c2h_tdata),
		.s_axis_c2h_tlast_0		(s_axis_c2h_tlast),
		.s_axis_c2h_tvalid_0	(s_axis_c2h_tvalid),
		.s_axis_c2h_tready_0	(s_axis_c2h_tready),
		.s_axis_c2h_tkeep_0		(s_axis_c2h_tkeep),
		.m_axis_h2c_tdata_0		(m_axis_h2c_tdata),
		.m_axis_h2c_tlast_0		(m_axis_h2c_tlast),
		.m_axis_h2c_tvalid_0	(m_axis_h2c_tvalid),
		.m_axis_h2c_tready_0	(m_axis_h2c_tready),
		.m_axis_h2c_tkeep_0		(m_axis_h2c_tkeep)
     );
     
     app 
     #(
        .TCQ(TCQ),
        .DATA_WIDTH(DATA_WIDTH),
        .IRQ_WIDTH(IRQ_WIDTH),
        .BYTE_BIT_ENABLE(BYTE_BIT_ENABLE)
     )
     app_i(
        .user_clk           (user_clk),
        .user_rst           (user_aresetn),
        .m_axis_c2h_tdata   (s_axis_c2h_tdata),
        .m_axis_c2h_tlast   (s_axis_c2h_tlast),
        .m_axis_c2h_tvalid  (s_axis_c2h_tvalid),
        .m_axis_c2h_tready  (s_axis_c2h_tready),
        .m_axis_c2h_tkeep   (s_axis_c2h_tkeep),
        .s_axis_h2c_tdata   (m_axis_h2c_tdata),
        .s_axis_h2c_tlast   (m_axis_h2c_tlast),
        .s_axis_h2c_tvalid  (m_axis_h2c_tvalid),
        .s_axis_h2c_tready  (m_axis_h2c_tready),
        .s_axis_h2c_tkeep   (m_axis_h2c_tkeep),
        .irq_req            (usr_irq_req),
        .irq_ack            (usr_irq_ack)
     );
endmodule
