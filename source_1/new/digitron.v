`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/09 13:41:31
// Design Name: 
// Module Name: digitron
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


module digitron( 
input wire [9:0] score,
input wire [9:0] combo,
input wire clock,
input wire rst_n,
output reg [7:0] QC_OUT,
output reg [7:0]QC1_OUT,
output reg [3:0]QA_OUT,
output reg [3:0]QA1_OUT

    );
   
    parameter     Cnt = 18'd150000;
               reg [19:0] jishu_96hz=0;
               reg clk_96hz=0;
             
    reg [7:0] Q1;//低八位用来存连击数
    reg [7:0] Q2;
    reg [7:0] Q3;
    reg [7:0] Q4;
    reg [7:0] Q5;//高八位用来存得分 最高9999
    reg [7:0] Q6;
    reg [7:0] Q7;
    reg [7:0] Q8;
    reg [7:0] Q;
    reg [7:0] Q11;
   
    reg Scucess;//表示通关与否
    reg clk_50ms=0;

 /*                 
             
    always@(posedge clk_50ms or negedge rst_n)   //每隔50ms比对一次 得分模块
        begin 
            if(!rst_n)
                  Score <=14'b0;
            else if(Score == 9999)
                begin
                  Score <=14'b0;
                  Scucess <= 1'b1;
                end
            else if(weizhi == anjian ) 
                begin
                  if(Frequency < Fre1)
                      begin
                          Score <= Score+14'b1;
                          Scucess <= 1'b0;
                      end
                  else if(Frequency < Fre2)
                      begin
                          Score <= Score+2;
                          Scucess <= 1'b0; 
                      end
                  else if(Frequency < Fre3)
                      begin
                          Score <= Score+3;
                          Scucess <= 1'b0;
                      end
                  else 
                      begin
                          Score <= Score+4;
                          Scucess <= 1'b0;
                      end
                end
          end
    always@(posedge clk_50ms or negedge rst_n)   //每隔50ms比对一次 得分模块
        begin 
            if(!rst_n)
                  Frequency <=14'b0;
            else if(Frequency == 9999)
                  Frequency <=14'b0;
            else if(weizhi == anjian)  //位置信息与按键信息相同且上次连击不为0
                  Frequency <= Frequency+14'b1;    //连击数高了效果是加高得分 频率变快
            else
                  Frequency <= 14'b0;
        end
    //数码管数值计算
    
    */
    always@(posedge clock or negedge rst_n)  
        begin
            if(!rst_n)
                begin
                        Q1<=4'b0;
                        Q2<=4'b0;
                        Q3<=4'b0;
                        Q4<=4'b0;
                        Q5<=4'b0;
                        Q6<=4'b0;
                        Q7<=4'b0;
                        Q8<=4'b0;
                end
            else 
                begin
                    Q1  <=(combo % 10);
                    Q2  <=((combo/10)  %  10);
                    Q3  <=((combo/100) % 10);
                    Q4  <=(combo/1000);
                    Q5  <= (score % 10);
                    Q6  <= ((score/10)  %  10);
                    Q7  <= ((score/100) % 10);
                    Q8  <= (score/1000);
                end
            end
    //数码管余晖应保证8位在下一次扫描前显示完 50*8=400hz  100000000/400=250000
    
           
            
             always@(posedge clock or negedge rst_n)
               begin
                if(!rst_n)
                begin
                    jishu_96hz<=0;
                     clk_96hz<=0;
                end
                else if(jishu_96hz==Cnt)
                     begin
                        jishu_96hz<=0;
                         clk_96hz<=~clk_96hz;
                     end
                 else
                      begin
                        jishu_96hz<=jishu_96hz+1;
                        clk_96hz<=clk_96hz;
                      end 
                end
    
    
    //数码管译码  共阳
       always @(posedge clk_96hz or negedge rst_n)
       if(!rst_n)
        begin
             QC_OUT <= 8'b11000000; 
             QC1_OUT <= 8'b11000000; 
             end
             else
              begin
                  case(Q)
                      0:       QC_OUT = 8'b11000000; 
                      1:       QC_OUT = 8'b11111001;   
                      2:      QC_OUT = 8'b10100100;     
                      3:      QC_OUT = 8'b1011_0000;  
                      4:       QC_OUT = 8'b10011001;   
                      5:      QC_OUT=8'b10010010;   
                      6:      QC_OUT=8'b10000010;   
                      7:      QC_OUT=8'b11111000;   
                      8:      QC_OUT=8'b10000000;   
                      9:      QC_OUT=8'b1001_0000;   
                     default:   QC_OUT = 8'b11000000;           
                  endcase   
                   case(Q11)
                      0:       QC1_OUT= 8'b11000000; 
                      1:       QC1_OUT = 8'b11111001;   
                      2:      QC1_OUT = 8'b10100100;     
                      3:      QC1_OUT = 8'b1011_0000;  
                      4:       QC1_OUT = 8'b10011001;   
                      5:      QC1_OUT=8'b10010010;   
                      6:      QC1_OUT=8'b10000010;   
                      7:      QC1_OUT=8'b11111000;   
                      8:      QC1_OUT=8'b10000000;   
                      9:      QC1_OUT=8'b1001_0000;   
                     default:   QC1_OUT = 8'b11000000;           
                  endcase                     
              end
    
    //片选
    always@(posedge clk_96hz or negedge rst_n )
    if(!rst_n)
        begin
            QA_OUT<= 4'b0111;
            Q<= 0;
            QA1_OUT<= 4'b0111;
            Q11<= 0;
            end
            else
            begin
           case(QA_OUT)
               4'b0111:
                   begin
                        Q<=Q2;
                        QA_OUT<= 4'b1110;                 
                   end
               4'b_1110:
                   begin
                        Q<=Q3;
                        QA_OUT<=8'b1101;
                        end
                4'b1101:
                   begin
                           Q<=Q4;          
                        QA_OUT<=4'b1011;
                        end
              4'b1011:
                   begin
                        Q<=Q1;
                        QA_OUT<=4'b0111;
                        end
                   
                 default : begin 
                    QA_OUT<=4'b0000;
                    end
               endcase
               
               case(QA1_OUT)
               4'b0111:
                   begin
                        Q11<=Q6;
                        QA1_OUT<= 4'b1110;                 
                   end
               4'b1110:
                   begin
                        Q11<=Q7;
                        QA1_OUT<=4'b1101;
                        end
                4'b1101:
                   begin
                           Q11<=Q8;          
                        QA1_OUT<=8'b1011;
                        end
                 4'b1011:
                   begin
                        Q11<=Q5;
                        QA1_OUT<=4'b0111;
                        end
               
                   
                 default : begin 
                    QA1_OUT<=4'b0000;
                    end
               endcase
               end
endmodule
