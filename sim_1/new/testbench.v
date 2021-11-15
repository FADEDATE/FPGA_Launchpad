`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/04 20:01:49
// Design Name: 
// Module Name: testbench
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


module testbench(

    );
    reg clk;
    reg rst;
    reg [7:0] button;
    wire result;
    reg [7:0] music_msg;
    top te(
    .clkin(clk),
    .rst(rst),
    .button(button),
    .result(result),
    .music_msg(music_msg)

    );
    
    initial begin button=0;
        clk=0;rst=0;#8 rst=1;#10 rst=0;music_msg=8'b1110_0001;
        forever #1 clk=~clk;
        end
    
endmodule
