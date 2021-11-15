//*************************************************************************\
// HDMI输出彩条测试，分辨率1280x720,帧率60Hz,颜色空间为RGB
//==========================================================================
//   Revision History:
//	Date		  By			Revision	Change Description
//--------------------------------------------------------------------------
//2013/5/7	          		    1.0			Original
//*************************************************************************/
module top(
	//sys
//	output wire tone_flag,
//	output wire[7:0] tx_data,
//	output wire [7:0] tone_d0,
//	output wire [7:0] tonee,
//    output wire result,
//    input wire[7:0] music_msg,
	input wire clkin,	
	input wire rst,
	input wire clear,
	input wire mstart,
	input wire uart_rx,
	output wire uart_tx,
	output wire tx1,
	input wire [7:0] button,                       //晶振输入50Mhz
	//input sys_key0,                    //按键输入
	//hdmi  
	output reg[2:0] led_rgb,

	output wire [3:0] QA_OUT,
	output wire [7:0] QC_OUT,
	output wire [3:0] QA1_OUT,
	output wire [7:0] QC1_OUT,
	output wire  TMDS_CLK_P,
	  output wire  TMDS_CLK_N,   
	  output wire    [2:0] TMDS_DATA_P,

	  output wire [9:0] led,
	//  output q,
	//  output osd_ram_addrr,
	//  output wire region_active1,
	   output wire    [2:0] TMDS_DATA_N                
	        //红色
);
assign tx1 = uart_tx;
    wire hdmi_out_clk;            //时钟
	wire hdmi_out_hs;               //行同步
	wire hdmi_out_vs;                //场同步
	wire hdmi_out_de;                //数据有效
	wire[7:0]  hdmi_out_rgb_b;       //蓝色
	wire[7:0]  hdmi_out_rgb_g;       //绿色
	wire[7:0]  hdmi_out_rgb_r;
	wire [23:0] q;   
	wire[15:0]osd_ram_addrr;
	 wire arst;
//1280x720@60的视频需要74.25Mhz的时钟，因为50Mhz不能通过PLL产生74.25MHz的时钟
//所以先通过pll_27M产生一个27Mhz的时钟，在通过pll_video产生74.25Mhz的时钟
wire locked;
wire hdmi_clk;
wire uclk;
clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(hdmi_out_clk),     // output clk_out1
    .clk_out2(hdmi_clk),
    .clk_out3(uclk),
       // output clk_out2
    // Status and control signals
    .reset(rst), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clkin)); 
 wire [7:0] rx_data;   
    uart_top inf(
//    .tone_flag(tone_flag),
//    .tx_data(tx_data),
//    .tone_d0(tone_d0),
//    .tonee(tonee),
     .sys_clk(uclk),
     .rst_n(~arst),
     .rx_data(rx_data),
     .tone(button),
     .uart_tx(uart_tx),
     .uart_rx(uart_rx)   
        );
  wire [9:0] combo;
  wire [13:0] score; 
wire finish;
assign led = rx_data;
    assign arst =( rst|(~locked));
color_bar hdmi_color_bar(
	.clk(hdmi_out_clk),
	.rst(arst),
//	.result(result),
//	.music_msg(music_msg),
	.clear(clear),
	.finish(finish),
	.mstart(mstart),
	.button(rx_data[4:0]),
	.hs(hdmi_out_hs),
	.vs(hdmi_out_vs),
	.de(hdmi_out_de),
	.rgb_r(hdmi_out_rgb_r),
	.rgb_g(hdmi_out_rgb_g),
	.rgb_b(hdmi_out_rgb_b),
	.combo(combo),
	.score(score)
);
always@(posedge uclk or posedge arst)begin
    if(arst)
        led_rgb<=3'b111;
        else
            if(mstart)begin
                if(finish)
                    led_rgb<=3'b010;
                        else
                            led_rgb<=3'b001;
                 end
                 else led_rgb<=3'b100;
  end  


digitron u2(
.clock(hdmi_out_clk),
.rst_n(~arst),
.score(score),
.combo(combo),
.QC_OUT(QC_OUT),
.QA_OUT(QA_OUT),
.QC1_OUT(QC1_OUT),
.QA1_OUT(QA1_OUT)
);


hdmi_tx_0 your_instance_name (
  .pix_clk(hdmi_out_clk),                // input wire pix_clk
  .pix_clkx5(hdmi_clk),            // input wire pix_clkx5
  .pix_clk_locked(locked),  // input wire pix_clk_locked
  .rst(arst),                        // input wire rst
  .red( hdmi_out_rgb_r),                        // input wire [7 : 0] red
  .green( hdmi_out_rgb_g),                    // input wire [7 : 0] green
  .blue( hdmi_out_rgb_b),                      // input wire [7 : 0] blue
  .hsync(hdmi_out_hs),                    // input wire hsync
  .vsync(hdmi_out_vs),                    // input wire vsync
  .vde(hdmi_out_de),                        // input wire vde
  .aux0_din(4'b0000),              // input wire [3 : 0] aux0_din
  .aux1_din(4'b0000),              // input wire [3 : 0] aux1_din
  .aux2_din(4'b0000),              // input wire [3 : 0] aux2_din
  .ade(1'b0),                        // input wire ade
  .TMDS_CLK_P(TMDS_CLK_P),          // output wire TMDS_CLK_P
  .TMDS_CLK_N(TMDS_CLK_N),          // output wire TMDS_CLK_N
  .TMDS_DATA_P(TMDS_DATA_P),        // output wire [2 : 0] TMDS_DATA_P
  .TMDS_DATA_N(TMDS_DATA_N)        // output wire [2 : 0] TMDS_DATA_N
);

endmodule 