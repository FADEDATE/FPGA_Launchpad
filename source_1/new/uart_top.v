

module uart_top
(
//input                           sys_clk_p,         //system clock positive
//input                           sys_clk_n, 
//output tone_flag,
//output tx_data,
//output tone_d0,
//output wire[7:0] tonee,
input                           sys_clk,       //system clock negative 
input                           rst_n,             //reset ,low active
input                           uart_rx,
input      wire[7:0]            tone, 
output    wire[7:0]             rx_data,          //fpga receive data
output                          uart_tx 


         //fpga send data
);
//assign tonee=tone;
parameter                       clk_fre = 100;    //Mhz
localparam                       IDLE =  0;
localparam                       SEND =  1;         //send HELLO ALINX\r\n
localparam                       WAIT =  2;         //wait 1 second and send uart received data
reg[7:0]                         tx_data;          //sending data
reg[7:0]                         tx_str;
reg                              tx_data_valid;    //sending data valid
wire                             tx_data_ready;    //singal for sending data
reg[7:0]                         tx_cnt=0; 
          //receiving data
wire                             rx_data_valid;    // receiving data valid
wire                             rx_data_ready;    // singal for receiving data
reg[31:0]                        wait_cnt=0;
reg[3:0]                         state=0;  
//wire[7:0]                       tone;
//wire                             sys_clk; 
wire [31:0] sonic_dist;         //single end clock
/*************************************************************************
generate single end clock
**************************************************************************/
/*IBUFDS sys_clk_ibufgds   
(
.O                      (sys_clk                  ),
.I                      (sys_clk_p                ),
.IB                     (sys_clk_n                )
); */
assign rx_data_ready = 1'b1;//always can receive data,
							//if HELLO ALINX\r\n is being sent, the received data is discarded
/*************************************************************************
1 second sends a packet HELLO ALINX\r\n , FPGA has been receiving state
****************************************************************************/
always@(posedge sys_clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		wait_cnt <= 32'd0;
		tx_data <= 8'd0;
		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else
	case(state)
		IDLE:
		begin
		 
		 // if(pwm_cnt1 == 32'd18_999_999)//500ms
		      if(tone_flag)
			     state <= SEND;
			     else state <= IDLE;
			end
		SEND:
		begin
			wait_cnt <= 32'd0;
			tx_data <= tone_d0;

			if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 &&( tx_cnt))//Send 12 bytes data
			begin
				tx_cnt <= tx_cnt + 8'd1; //Send data counter
			end
			else  if(tx_data_valid && tx_data_ready )//last byte sent is complete
			begin
			// if(tx_cnt > 6)
				tx_cnt <= 8'd0;
				//else tx_cnt <= tx_cnt + 1'b1;
				tx_data_valid <= 1'b0;
				state <= IDLE;
			end
			else if(~tx_data_valid)
			begin
				tx_data_valid <= 1'b1;
			end
		end
		WAIT:
		begin
			wait_cnt <= wait_cnt + 32'd1;
            // 等待1s 数据的时候
			if(rx_data_valid == 1'b1) // 如果接收到数据
			begin
				tx_data_valid <= 1'b1; //使得发送数据使能，
				tx_data <= rx_data;   // send uart received data
			end
			else if(tx_data_valid && tx_data_ready)
			begin
				tx_data_valid <= 1'b0;
			end else
//			else if(wait_cnt >= clk_fre * 1000000) // wait for 1 second
				state <= IDLE;
		end
		default:
			state <= IDLE;
	endcase
end
reg[7:0] tone_d0;
reg tone_flag;
//always@(posedge sys_clk or negedge rst_n)begin
// if(!rst_n)
//        begin
            
            
//        end
//    else
//        begin
            
            
//           end
//  end   
always@(posedge sys_clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            tone_d0<=0;
            tone_flag<=0;
        end
    else
        begin
            tone_d0[7:0]<=tone[7:0];
            if(tone!=tone_d0)tone_flag<=1;
            else tone_flag <=0;
       
             
        
            end
end


/*************************************************************************
combinational logic  Send "HELLO ALINX\r\n"

/***************************************************************************
calling uart_tx module and uart_rx module
****************************************************************************/
uart_rx#
(
.clk_fre(clk_fre),
.baud_rate(9600)
) uart_rx_inst
(
.clk                        (sys_clk                  ),
.rst_n                      (rst_n                    ),
.rx_data                    (rx_data                  ),
.rx_data_valid              (rx_data_valid            ),
.rx_data_ready              (rx_data_ready            ),
.rx_pin                     (uart_rx                  )
);

uart_tx#
(
.clk_fre(clk_fre),
.baud_rate(9600)
) uart_tx_inst
(
.clk                        (sys_clk                  ),
.rst_n                      (rst_n                    ),
.tx_data                    (tx_data                  ),
.tx_data_valid              (tx_data_valid            ),
.tx_data_ready              (tx_data_ready            ),
.tx_pin                     (uart_tx                  )
);
















//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




endmodule



