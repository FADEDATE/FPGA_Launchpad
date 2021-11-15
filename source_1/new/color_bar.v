//*************************************************************************\
//==========================================================================
//   Description:
//  彩条发生模块
//==========================================================================
//   Revision History:
//	Date		  By			Revision	Change Description
//--------------------------------------------------------------------------
//2013/5/7                     1.2         remove some warning
//2013/4/18                    1.1         vs timing
//2013/4/16	        		   1.0			Original
//*************************************************************************/
module color_bar(
//output wire result,
//input wire[7:0] music_msg,
	input clk,            //像素时钟输入，1280x720@60P的像素时钟为74.25
	input rst,  
	
	input wire mstart,
	input wire clear,
	input wire [4:0] button,          //复位,高有效
	output hs,            //行同步、高有效
	output vs,            //场同步、高有效
	output de,  
	output reg [9:0] combo,
    output reg finish, 
	output reg [9:0] score,        //数据有效
	output[7:0] rgb_r,    //像素数据、红色分量
	output[7:0] rgb_g,
	    //像素数据、绿色分量
	output[7:0] rgb_b     //像素数据、蓝色分量
);
/*********视频时序参数定义******************************************/
//video timing parameter definition
`define 	VIDEO_1280_720


`ifdef  VIDEO_1280_720
parameter H_ACTIVE = 16'd1280;           //horizontal active time (pixels)
parameter H_FP = 16'd110;                //horizontal front porch (pixels)
parameter H_SYNC = 16'd40;               //horizontal sync time(pixels)
parameter H_BP = 16'd220;                //horizontal back porch (pixels)
parameter V_ACTIVE = 16'd720;            //vertical active Time (lines)
parameter V_FP  = 16'd5;                 //vertical front porch (lines)
parameter V_SYNC  = 16'd5;               //vertical sync time (lines)
parameter V_BP  = 16'd20;                //vertical back porch (lines)
parameter HS_POL = 1'b1;                 //horizontal sync polarity, 1 : POSITIVE,0 : NEGATIVE;
parameter VS_POL = 1'b1;                 //vertical sync polarity, 1 : POSITIVE,0 : NEGATIVE;
`endif

//480x272 9Mhz
`ifdef  VIDEO_480_272
parameter H_ACTIVE = 16'd480; 
parameter H_FP = 16'd2;       
parameter H_SYNC = 16'd41;    
parameter H_BP = 16'd2;       
parameter V_ACTIVE = 16'd272; 
parameter V_FP  = 16'd2;     
parameter V_SYNC  = 16'd10;   
parameter V_BP  = 16'd2;     
parameter HS_POL = 1'b0;
parameter VS_POL = 1'b0;
`endif

//640x480 25.175Mhz
`ifdef  VIDEO_640_480
parameter H_ACTIVE = 16'd640; 
parameter H_FP = 16'd16;      
parameter H_SYNC = 16'd96;    
parameter H_BP = 16'd48;      
parameter V_ACTIVE = 16'd480; 
parameter V_FP  = 16'd10;    
parameter V_SYNC  = 16'd2;    
parameter V_BP  = 16'd33;    
parameter HS_POL = 1'b0;
parameter VS_POL = 1'b0;
`endif

//800x480 33Mhz
`ifdef  VIDEO_800_480
parameter H_ACTIVE = 16'd800; 
parameter H_FP = 16'd40;      
parameter H_SYNC = 16'd128;   
parameter H_BP = 16'd88;      
parameter V_ACTIVE = 16'd480; 
parameter V_FP  = 16'd1;     
parameter V_SYNC  = 16'd3;    
parameter V_BP  = 16'd21;    
parameter HS_POL = 1'b0;
parameter VS_POL = 1'b0;
`endif

//800x600 40Mhz
`ifdef  VIDEO_800_600
parameter H_ACTIVE = 16'd800; 
parameter H_FP = 16'd40;      
parameter H_SYNC = 16'd128;   
parameter H_BP = 16'd88;      
parameter V_ACTIVE = 16'd600; 
parameter V_FP  = 16'd1;     
parameter V_SYNC  = 16'd4;    
parameter V_BP  = 16'd23;    
parameter HS_POL = 1'b1;
parameter VS_POL = 1'b1;
`endif

//1024x768 65Mhz
`ifdef  VIDEO_1024_768
parameter H_ACTIVE = 16'd1024;
parameter H_FP = 16'd24;      
parameter H_SYNC = 16'd136;   
parameter H_BP = 16'd160;     
parameter V_ACTIVE = 16'd768; 
parameter V_FP  = 16'd3;      
parameter V_SYNC  = 16'd6;    
parameter V_BP  = 16'd29;     
parameter HS_POL = 1'b0;
parameter VS_POL = 1'b0;
`endif

//1920x1080 148.5Mhz
`ifdef  VIDEO_1920_1080
parameter H_ACTIVE = 16'd1920;
parameter H_FP = 16'd88;
parameter H_SYNC = 16'd44;
parameter H_BP = 16'd148; 
parameter V_ACTIVE = 16'd1080;
parameter V_FP  = 16'd4;
parameter V_SYNC  = 16'd5;
parameter V_BP  = 16'd36;
parameter HS_POL = 1'b1;
parameter VS_POL = 1'b1;
`endif





















/*

parameter H_ACTIVE = 16'd1280;  //行有效长度（像素时钟周期个数）
parameter H_FP = 16'd110;       //行同步前肩长度
parameter H_SYNC = 16'd40;      //行同步长度
parameter H_BP = 16'd220;       //行同步后肩长度
parameter V_ACTIVE = 16'd720;   //场有效长度（行的个数）
parameter V_FP 	= 16'd5;        //场同步前肩长度
parameter V_SYNC  = 16'd5;      //场同步长度
parameter V_BP	= 16'd20;       //场同步后肩长度
   */
parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//行总长度
parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//场总长度
/*********彩条RGB color bar颜色参数定义*****************************/
parameter WHITE_R 		= 8'hff;
parameter WHITE_G 		= 8'hff;
parameter WHITE_B 		= 8'hff;
parameter YELLOW_R 		= 8'hff;
parameter YELLOW_G 		= 8'hff;
parameter YELLOW_B 		= 8'h00;                              	
parameter CYAN_R 		= 8'h00;
parameter CYAN_G 		= 8'hff;
parameter CYAN_B 		= 8'hff;                             	
parameter GREEN_R 		= 8'h00;
parameter GREEN_G 		= 8'hff;
parameter GREEN_B 		= 8'h00;
parameter MAGENTA_R 	= 8'hff;
parameter MAGENTA_G 	= 8'h00;
parameter MAGENTA_B 	= 8'hff;
parameter RED_R 		= 8'hff;
parameter RED_G 		= 8'h00;
parameter RED_B 		= 8'h00;
parameter BLUE_R 		= 8'h00;
parameter BLUE_G 		= 8'h00;
parameter BLUE_B 		= 8'hff;
parameter BLACK_R 		= 8'h00;
parameter BLACK_G 		= 8'h00;
parameter BLACK_B 		= 8'h00;
reg hs_reg;//定义一个寄存器,用于行同步
reg vs_reg;//定义一个寄存器,用户场同步
reg hs_reg_d0;//hs_reg一个时钟的延迟
              //所有以_d0、d1、d2等为后缀的均为某个寄存器的延迟
reg vs_reg_d0;//vs_reg一个时钟的延迟
reg[11:0] h_cnt;//用于行的计数器
reg[11:0] v_cnt;//用于场（帧）的计数器
reg[11:0] active_x;//有效图像的的坐标x
reg[11:0] active_y;//有效图像的坐标y
reg[7:0] rgb_r_reg;//像素数据r分量
reg[7:0] rgb_g_reg;//像素数据g分量
reg[7:0] rgb_b_reg;//像素数据b分量
reg h_active;//行图像有效
reg v_active;//场图像有效
wire video_active;//一帧内图像的有效区域h_active & v_active
reg video_active_d0;


//////////////////////////////////////////////////////////
reg [15:0] ram_addr;
reg pos_vs_d0;
reg pos_vs_d1;
reg region_active;
reg region_active_d0;
wire  [23:0] q;
parameter OSDW_START  = 12'd562;
parameter OSDH_START = 12'd225;
parameter OSD_WIDTH   =  12'd156;	//设置OSD的宽度，可根据字符生成软件设置
parameter OSD_HEGIHT  =  12'd269;	//设置OSD的高度，可根据字符生成软件设置

wire region_active1;
assign region_active1=region_active;
////////////////////////////////////////////////
wire arst;
assign arst=clear|rst;
assign hs = hs_reg_d0;
assign vs = vs_reg_d0;
assign video_active = h_active & v_active;
assign de = video_active_d0;
assign rgb_r = rgb_r_reg;
assign rgb_g = rgb_g_reg;
assign rgb_b = rgb_b_reg;
always@(posedge clk or posedge rst)
begin
	if(rst)
		begin
			hs_reg_d0 <= 1'b0;
			vs_reg_d0 <= 1'b0;
			video_active_d0 <= 1'b0;
		end
	else
		begin
			hs_reg_d0 <= hs_reg;
			vs_reg_d0 <= vs_reg;
			video_active_d0 <= video_active;
		end
end






always@(posedge clk or posedge rst)
begin
	if(rst)
		h_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL - 1)//行计数器到最大值清零
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		active_x <= 12'd0;
	else if(h_cnt >= H_FP + H_SYNC + H_BP - 1)//计算图像的x坐标
		active_x <= h_cnt - (H_FP[11:0] + H_SYNC[11:0] + H_BP[11:0] - 12'd1);
	else
		active_x <= active_x;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		active_y <= 12'd0;
	else if(v_cnt >= V_FP + V_SYNC + V_BP - 1)//horizontal video active
		active_y <= v_cnt - (V_FP[11:0] + V_SYNC[11:0] + V_BP[11:0] - 12'd1);
	else
		active_y <= active_y;
end



always@(posedge clk or posedge rst)
begin
	if(rst)
		v_cnt <= 12'd0;
	else if(h_cnt == H_FP  - 1)//在行数计算器为H_FP - 1的时候场计数器+1或清零
		if(v_cnt == V_TOTAL - 1)//场计数器到最大值了，清零
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;//没到最大值，+1
	else
		v_cnt <= v_cnt;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		hs_reg <= 1'b0;
	else if(h_cnt == H_FP - 1)//行同步开始了...
		hs_reg <= 1'b1;
	else if(h_cnt == H_FP + H_SYNC - 1)//行同步这时候要结束了
		hs_reg <= 1'b0;
	else
		hs_reg <= hs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		h_active <= 1'b0;
	else if(h_cnt == H_FP + H_SYNC + H_BP - 1)
		h_active <= 1'b1;
	else if(h_cnt == H_TOTAL - 1)
		h_active <= 1'b0;
	else
		h_active <= h_active;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		vs_reg <= 1'd0;
	else if((v_cnt == V_FP - 1) && (h_cnt == H_FP - 1))
		vs_reg <= 1'b1;
	else if((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP - 1))
		vs_reg <= 1'b0;	
	else
		vs_reg <= vs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		v_active <= 1'd0;
	else if((v_cnt == V_FP + V_SYNC + V_BP - 1) && (h_cnt == H_FP - 1))
		v_active <= 1'b1;
	else if((v_cnt == V_TOTAL - 1) && (h_cnt == H_FP - 1))
		v_active <= 1'b0;	
	else
		v_active <= v_active;
end
/*
always@(posedge clk or posedge rst)
begin
	if(rst)
		begin
			rgb_r_reg <= 8'h00;
			rgb_g_reg <= 8'h00;
			rgb_b_reg <= 8'h00;
		end
	else if(video_active)
		if(active_x == 12'd0)
			begin
				rgb_r_reg <= WHITE_R;
				rgb_g_reg <= WHITE_G;
				rgb_b_reg <= WHITE_B;
			end
		else if(active_x == (H_ACTIVE/8) * 1)
			begin
				rgb_r_reg <= YELLOW_R;
				rgb_g_reg <= YELLOW_G;
				rgb_b_reg <= YELLOW_B;
			end			
		else if(active_x == (H_ACTIVE/8) * 2)
			begin
				rgb_r_reg <= CYAN_R;
				rgb_g_reg <= CYAN_G;
				rgb_b_reg <= CYAN_B;
			end
		else if(active_x == (H_ACTIVE/8) * 3)
			begin
				rgb_r_reg <= GREEN_R;
				rgb_g_reg <= GREEN_G;
				rgb_b_reg <= GREEN_B;
			end
		else if(active_x == (H_ACTIVE/8) * 4)
			begin
				rgb_r_reg <= MAGENTA_R;
				rgb_g_reg <= MAGENTA_G;
				rgb_b_reg <= MAGENTA_B;
			end
		else if(active_x == (H_ACTIVE/8) * 5)
			begin
				rgb_r_reg <= RED_R;
				rgb_g_reg <= RED_G;
				rgb_b_reg <= RED_B;
			end
		else if(active_x == (H_ACTIVE/8) * 6)
			begin
				rgb_r_reg <= BLUE_R;
				rgb_g_reg <= BLUE_G;
				rgb_b_reg <= BLUE_B;
			end	
		else if(active_x == (H_ACTIVE/8) * 7)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end
		else
			begin
				rgb_r_reg <= rgb_r_reg;
				rgb_g_reg <= rgb_g_reg;
				rgb_b_reg <= rgb_b_reg;
			end			
	else
		begin
			rgb_r_reg <= 8'h00;
			rgb_g_reg <= 8'h00;
			rgb_b_reg <= 8'h00;
		end
end  */
/*
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        pos_vs_d0 <= 1'b0;
        pos_vs_d1 <= 1'b0;
        end
       else
    begin
        pos_vs_d0 <= vs_reg_d0;
        pos_vs_d1 <= pos_vs_d0;
    end
end
*/
always@(posedge clk)
begin
	region_active_d0 <= region_active;
//	region_active_d1 <= region_active_d0;
//	region_active_d2 <= region_active_d1;
end
/*
always@(posedge clk)
begin
	if(active_y >= 12'd9 && active_y <= 12'd9 + OSD_HEGIHT - 12'd1 && active_x >= 12'd9 && active_x  <= 12'd9 + OSD_WIDTH - 12'd1)
		begin 
		region_active <= 1'b1;
		osd_ram_addr <= osd_ram_addr + 12'd1;
		end
	else
	begin
		region_active <= 1'b0;
		osd_ram_addr <= 12'd0;
		end
end  



*/
/*
always @ (posedge clk or posedge rst)
if(rst)
    begin
        osd_ram_addr <= 16'b0;
        region_active <= 1'b0;
        end
    else
begin
  if(((active_y >= OSDH_START) && (active_y <= OSDH_START +OSD_HEGIHT - 16'b1) )&&((active_x >= OSDW_START) && (active_x <= OSDW_START+OSD_WIDTH-16'b1)))
        begin
              osd_ram_addr   <= (active_y - OSDH_START)*OSD_WIDTH + (active_x-OSDW_START);
              region_active <= 1'b1;
              end
  else begin 
            osd_ram_addr<=16'b0;
            region_active <= 1'b0;
            end
  
end     

*/
    /*
always @(posedge clk or posedge rst)
if(rst)
    begin  
        osd_ram_addr <= 16'd0;
        end
    else
begin
    if(pos_vs_d0 == 1'b0 && pos_vs_d1 == 1'b1)
       osd_ram_addr <= 16'd0;
    else if(region_active == 1'b1)
        osd_ram_addr <= osd_ram_addr + 16'd1 ; 
end
*/
parameter music_len = 54;
parameter grid_size = 142;
parameter thick_line = 3;
parameter thin_line = 1; 
parameter grid_start = (H_ACTIVE - 5*grid_size - 2*thick_line - 4*thin_line)/2;
parameter grid_end = H_ACTIVE-grid_start;
parameter first_grid_center_x = grid_start + grid_size/2 + thick_line -1;
parameter first_grid_center_y =  grid_size/2 + thick_line -1;
parameter daoqilan = 24'h1E90ff;
parameter yuebaise = 24'hb0dfe5;
parameter haitanghong = 24'hdb5a6b;
parameter shuilvse =24'h33cccc;
parameter kejilan = 24'h7b68ee;
parameter liangjin = 24'hFAFA9D;
parameter lianghong = 24'hFF3632;

parameter button_time = 32'd200_000;
parameter music_time = 32'd200_000;
/////////////////////////////////////////////////////////////////////////////
reg [31:0] ratio;
reg [31:0] clk_cnt;
reg [4:0] button_d0;
reg [4:0] button_d1;
reg [4:0] button_d2;
reg [4:0] button_d3;
reg button_flag;
reg button_flag_1;
reg button_flag_2;
reg [31:0] ratio1;
reg [31:0] ratio2;
always@(posedge clk or posedge rst)
begin
if(rst)
    ratio<=0;
    else
        if(button_flag)
            if(ratio == 70) begin ratio<=0 ;end
            else if(clk_cnt==button_time)ratio<= ratio+1'b1;           
 end
 

 always@(posedge clk or posedge rst)
begin
if(rst)
    ratio1<=0;
    else
        if(button_flag_1)
            if(ratio1 == 70) begin ratio1<=0 ;end
            else if(clk_cnt==button_time)ratio1<= ratio1+1'b1;           
 end
 
  always@(posedge clk or posedge rst)
begin
if(rst)
    ratio2<=0;
    else
        if(button_flag_2)
            if(ratio2 == 70) begin ratio2<=0 ;end
            else if(clk_cnt==button_time)ratio2<= ratio2+1'b1;           
 end
 
/////////////////////////////////////////////////////////////////////////////////
reg bflag; 
reg bflag_d0;
always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
        button_flag<=0;
        button_flag_1<=0;
        button_flag_2<=0;
     
        button_d1 <=0;
        button_d2 <=0;
        button_d3 <=0;
       
        end
    else 
    begin
        if(bflag==1)
        begin          
            if(ratio==0)
            begin
            button_flag =1;
            button_d1=button_d0-1;
            end
            else if(ratio1==0)
                begin   
                      button_flag_1 =1;
                      button_d2=button_d0-1; 
                    end
                    else if(ratio2==0)
                        begin   
                            button_flag_2 =1;
                            button_d3=button_d0-1; 
                            end
            
         end
           if(ratio>=70)
           begin
                button_flag =0;
                button_d1=0;
                end
             if(ratio1>=70)
           begin
                button_flag_1 =0;
                button_d2=0;
                end
            if(ratio2>=70)
           begin
                button_flag_2 =0;
                button_d3=0;
                end    
        end
 end

always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
     
        button_d0 <=0;
        bflag_d0<=0;
        bflag<=0;
        end
    else 
    begin
        button_d0 <= button;
        if((button_d0 != button) && button)
        begin
            bflag<=1;           
        end
        else bflag<=0;
        bflag_d0<=bflag;
     end
 end
 
 ////////////////////////////////////////////////////////////////////////////////////////////
 


always@(posedge clk or posedge rst)
begin
    if(rst)
    begin 
        clk_cnt <= 24'd0;
    end
        else  
            begin             
                if(clk_cnt == button_time )              
                clk_cnt <= 0;                               
                    else clk_cnt <= clk_cnt + 1'b1;
              end                          
end        
////////////////////////////////////////////////////////////////////////////
reg [31:0] mclk_cnt;
wire result;
wire [7:0] music_msg;
reg [4:0] music_loc;
reg [2:0] music_speed;
reg music_r;
reg [15:0] mratio;
reg music_flag;
reg music_v_flag;
reg mstart_d0;
reg res_flag;
reg res_d0;
reg result_d0;
reg result_d1;
assign result = (button==music_loc+1)?1'b1:1'b0;
always@(posedge clk or posedge arst)begin
if(arst)
begin
    result_d0<=0;
    result_d1<=0;
    end
    else
        result_d0<=result;
        result_d1<=result_d0;

end
always@(posedge clk or posedge arst)
begin
    if(arst)
    begin
        
        res_flag<=0;
        combo<=0;
        res_d0<=0;

        end
        else
        if(mstart )
        begin
            res_d0<=res_flag;
            if( music_v_flag && (bflag ||mratio==141) && (!res_flag))
            begin                             
                res_flag<=1;
               
                if( result_d0)
                    begin                                       
                    combo <= combo +1'b1;                    
                    end
                    else 
                        combo<=0;
                end
                else 
                begin
             
                combo<=combo;
                end
            if(mratio==141)
                res_flag<=0;              
       end         
       else 
        begin
            res_flag<= res_flag;                      
            combo<=combo; 
            res_d0<=res_d0;    
            end
            
 end     
always@(posedge clk or posedge arst)
begin
    if(arst)
    begin                   
        score<=0;      
        end
        else
        if(mstart )
        begin
            if( res_d0!=res_flag && res_flag)
            begin                                                        
                if( result_d0)
                    begin
                   
                     score <= score + (combo+1)/16 +1'b1;
                                                         
                    end                                      
                   end
                else 
                begin
                score<=score;
                end           
       end         
       else 
        begin
            score<=score;
            end          
 end       


always@(posedge clk or posedge arst)
begin
    if(arst)
    begin 
        mclk_cnt <= 24'd0;
        music_flag<=0;
        music_v_flag<=0;
    end
        else  
            begin    
               if(mstart_d0)
                begin
                if(mclk_cnt == music_time*music_speed )              
                mclk_cnt <= 0;                               
                    else mclk_cnt <= mclk_cnt + 1'b1;
                    
              if(music_r) 
                
                   music_v_flag<=1;  
                  else            
                 music_flag<=1;       
                 if(mratio>=141)
                 begin
                    music_flag<=0;
                    music_v_flag<=0;
                    end
                   
                 end
                 else
                    begin   
                         music_flag<=music_flag;
                         music_v_flag<=music_v_flag;
                         end
              end                          
end   

always@(posedge clk or posedge arst)
if(arst)
    begin
        ram_addr<=0;
        music_r<=0;
        music_speed<=0;
        music_loc<=0;
        mstart_d0<=0;
        finish<=0;
        end
        else 
            begin
             mstart_d0<=mstart;
                if(mstart)
            begin
               
                music_r<=music_msg[7];
                music_speed<=music_msg[6:5];
                music_loc<=music_msg[4:0]-1;
                if(mratio >=141 && finish==0)
                    begin
                        if(ram_addr==music_len )begin
                            ram_addr<=0;finish<=1;
                            end
                        else
                        ram_addr<=ram_addr + 1;
                end
                else if(mstart!=mstart_d0 && mstart==0)finish<=0;
          end
  end              
            
    


  always@(posedge clk or posedge arst)
begin
if(arst)
    mratio<=0;
    else
    if(mstart_d0)
    begin
    if(!finish)begin
        if(music_flag || music_v_flag)
            if(mratio == 141) begin mratio<=0 ;end
            else if(mclk_cnt==music_time*music_speed)mratio<= mratio+1'b1;    
            end
             else mratio<=mratio;       
          end
        else mratio<=0;  
 end
/////////////////////////////////////////////////////////////////////////////

wire [23:0] thick_line_color;
wire [23:0] thin_line_color;
wire [23:0] grid_color;
wire [23:0] background_color;
wire [23:0] grid_color_c;
wire [23:0] grid_color_g;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 
assign thick_line_color=daoqilan;
assign thin_line_color=haitanghong;
assign grid_color=shuilvse;
assign background_color=yuebaise;
assign grid_color_c=lianghong;
assign grid_color_g=liangjin;
wire [31:0] mlimit_x1;
wire [31:0] mlimit_x2;
wire [31:0] mlimit_y1;
wire [31:0] mlimit_y2;

assign mlimit_x1= 284+142*(music_loc%5);
assign mlimit_x2= 425+142*(music_loc%5);
assign mlimit_y1= 3+143*(music_loc/5) ;
assign mlimit_y2= 3+143*(music_loc/5)+mratio;



wire [31:0] limit_x1;
wire [31:0] limit_x2;
wire [31:0] limit_y1;
wire [31:0] limit_y2;
assign limit_x1= first_grid_center_x+143*((button_d1)%5) - ratio;
assign limit_x2= first_grid_center_x+143*((button_d1)%5) + ratio +1;
assign limit_y1= first_grid_center_y+143*((button_d1)/5) -ratio;
assign limit_y2= first_grid_center_y+143*((button_d1)/5) +ratio+1;

wire [31:0] limit_x1_1;
wire [31:0] limit_x2_1;
wire [31:0] limit_y1_1;
wire [31:0] limit_y2_1;
assign limit_x1_1= first_grid_center_x+143*((button_d2)%5) - ratio1;
assign limit_x2_1= first_grid_center_x+143*((button_d2)%5) + ratio1 +1;
assign limit_y1_1= first_grid_center_y+143*((button_d2)/5) -ratio1;
assign limit_y2_1= first_grid_center_y+143*((button_d2)/5) +ratio1+1;

wire [31:0] limit_x1_2;
wire [31:0] limit_x2_2;
wire [31:0] limit_y1_2;
wire [31:0] limit_y2_2;
assign limit_x1_2= first_grid_center_x+143*((button_d3)%5) - ratio2;
assign limit_x2_2= first_grid_center_x+143*((button_d3)%5) + ratio2 +1;
assign limit_y1_2= first_grid_center_y+143*((button_d3)/5) -ratio2;
assign limit_y2_2= first_grid_center_y+143*((button_d3)/5) +ratio2+1;

wire button_flag_t;
assign button_flag_t = button_flag | button_flag_1 | button_flag_2;

reg result_flag;
always@(posedge clk or posedge arst)begin
if(arst)
    result_flag<=0;
    else
        begin
            if(res_d0 && result_d1)
                result_flag<=1;
             if(mratio==141)
                result_flag<=0; 
        
        
        end
        
        
        
 end       
always@(posedge clk or posedge rst)
begin
    if(rst == 1'b1)
        begin
            rgb_r_reg <= 8'h00;
            rgb_g_reg <= 8'h00;
            rgb_b_reg <= 8'h00;
         end
    else if(video_active)
            begin
                if(active_x >=grid_start && active_x < grid_end )
                begin
                    if(active_y <=  thick_line -1 || active_y >= V_ACTIVE - thick_line )
                    begin
                         rgb_r_reg <= thick_line_color[23:16];
                         rgb_g_reg <= thick_line_color[15:8];
                         rgb_b_reg <= thick_line_color[7:0];
                        end
                        else if(active_y == thick_line + grid_size || active_y == thick_line + 2*grid_size +1 || active_y == thick_line + 3*grid_size +1 || active_y == thick_line + 4*grid_size +1 )
                        begin
                         rgb_r_reg <= thin_line_color[23:16];
                         rgb_g_reg <= thin_line_color[15:8];
                         rgb_b_reg <= thin_line_color[7:0];
                         end
                         else if(active_x <= grid_start + thick_line -1 || active_x >= grid_end - thick_line )
                            begin
                                rgb_r_reg <=thick_line_color[23:16];
                                rgb_g_reg <=thick_line_color[15:8];
                                rgb_b_reg <= thick_line_color[7:0];
                                end
                                else if(active_x == grid_start + thick_line || active_x ==grid_start + thick_line +grid_size+1 || active_x ==grid_start + thick_line +2*grid_size+1|| active_x ==grid_start + thick_line +3*grid_size+1 || active_x ==grid_start + thick_line +4*grid_size+1)
                                begin
                                rgb_r_reg <= thin_line_color[23:16];
                                rgb_g_reg <= thin_line_color[15:8];
                                rgb_b_reg <= thin_line_color[7:0];
                                end
                                else 
                                begin
                                
                                if(button_flag_t!= 0 ||music_v_flag )
                                    begin                                                                      
                                     if(!result_flag && music_v_flag && active_x >= mlimit_x1 && active_x <= mlimit_x2 && active_y >= mlimit_y1 && active_y <= mlimit_y2 )
                                     begin
                                        rgb_r_reg <= grid_color_g[23:16];
                                        rgb_g_reg <= grid_color_g[15:8];
                                        rgb_b_reg <= grid_color_g[7:0];
                                     end
                                     else
                                        if(button_flag && active_x >= limit_x1 && active_x <= limit_x2 && active_y >= limit_y1 && active_y <= limit_y2 )
                                        begin
                                        rgb_r_reg <= grid_color_c[23:16];
                                        rgb_g_reg <= grid_color_c[15:8];
                                        rgb_b_reg <= grid_color_c[7:0];
                                        end
                                        else if(button_flag_1 && active_x >= limit_x1_1 && active_x <= limit_x2_1 && active_y >= limit_y1_1 && active_y <= limit_y2_1)
                                            begin
                                        rgb_r_reg <= grid_color_c[23:16];
                                        rgb_g_reg <= grid_color_c[15:8];
                                        rgb_b_reg <= grid_color_c[7:0];   
                                            end
                                         else if(button_flag_2 && active_x >= limit_x1_2 && active_x <= limit_x2_2 && active_y >= limit_y1_2 && active_y <= limit_y2_2)
                                            begin
                                        rgb_r_reg <= grid_color_c[23:16];
                                        rgb_g_reg <= grid_color_c[15:8];
                                        rgb_b_reg <= grid_color_c[7:0];   
                                            end
                                            else  
                                        begin
                                        rgb_r_reg <= grid_color[23:16];
                                        rgb_g_reg <= grid_color[15:8];
                                        rgb_b_reg <= grid_color[7:0];
                                        end
                                    end
                                    else begin
                                        rgb_r_reg <= grid_color[23:16];
                                        rgb_g_reg <= grid_color[15:8];
                                        rgb_b_reg <= grid_color[7:0];
                                        end
                                end
                end
                else
                begin
                    rgb_r_reg <= background_color[23:16];
                    rgb_g_reg <= background_color[15:8];
                    rgb_b_reg <= background_color[7:0];
                end
            end     
    
    else
        begin
            rgb_r_reg <= 8'h00;
            rgb_g_reg <= 8'h00;
            rgb_b_reg <= 8'h00;
        end
end
//////////////////////////////////////////////////////////////////////////////////////////////////////////



blk_mem_gen_0 your_instance_name (
  .clka(clk),    // input wire clka
  .addra(ram_addr),  // input wire [15 : 0] addra
  .douta(music_msg)  // output wire [23 : 0] douta
);
endmodule 