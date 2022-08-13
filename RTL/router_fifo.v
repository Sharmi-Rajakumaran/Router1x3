module router_fifo(clk_in,resetn_in,soft_reset_in,write_enb_in,read_enb_in,lfd_state_in,data_in,full_out,empty_out,data_out);
//INPUT,OUTPUT
input clk_in,resetn_in,soft_reset_in,write_enb_in,read_enb_in,lfd_state_in;
input [7:0]data_in;
output reg full_out,empty_out;
output reg [7:0]data_out;
//internal Data types
reg [5:0]read_ptr,write_ptr;
reg [5:0]count;
reg [8:0]fifo[15:0];//9 BIT DATA WIDTH 1 BIT EXTRA FOR HEADER AND 16 DEPTH SIZE
integer i;
reg temp;
//reg [6:0] increamenter;

//------------------------------------------------------------------------------
//lfd_state
always@(posedge clk_in)
	begin
		if(!resetn_in)
			temp<=1'b0;
		else 
			temp<=lfd_state_in;
	end 


//-------------------------------------------------------------------------------------------------------------------
/*Incrementer

always @(posedge clk_in )
begin
   if( !resetn_in )
       incrementer <= 0;

   else if( (!full_ouy && write_enb_in) && ( !empty && read_enb_in ) )
          incrementer<= incrementer;

   else if( !full_out && write_enb_in )
          incrementer <=    incrementer + 1;					//inc is increased because data is written

   else if( !empty_out && read_enb_in )									// inc is decrease because data is read
          incrementer <=    incrementer - 1;
   else
         incrementer <=    incrementer;
end

//full and empty logic
always @(incrementer)
begin
if(incrementer==0)      //nothing in fifo
  empty_out = 1 ;
  else
  empty_out = 0;

  if(incrementer==4'b1111)  // fifo is full
   full_out = 1;
   else
   full_out = 0;
end 
//----------------------------------------
//-----------------------------
*/
//Fifo write logic
always@(posedge clk)
	begin
		if(!resetn || soft_reset)
			begin
				for(i=0;i<16;i=i+1)
					fifo[i]<=0; 
			end
		
		else if(write_enb && !full)
				{fifo[write_ptr[3:0]][8],fifo[write_ptr[3:0]][7:0]}<={temp,datain}; //temp=1 for header data and 0 for other data
	
	end

//
//----------------------------------------------------------------------------------------------------------------------------------------
//FIFO READ logic
always@(posedge clk)
	begin
		if(!resetn)
			dataout<=8'd0;

		else if(soft_reset)
			dataout<=8'bzz;
		
		else
			begin 
				if(read_enb && !empty)
					dataout<=fifo[read_ptr[3:0]];
				if(count==0) // COMPLETELY READ
					dataout<=8'bz;
			end
	end
//------------------------------------------------------------------------------------------------------------------------------------
//counter logic
always@(posedge clk_in)
	begin
		
		 if(read_enb_in && !empty_out)
			begin
				if(fifo[read_ptr[3:0]][8])                          //a header byte is read, an internal counter is loaded with the payload length
                                                               //length of the packet plus(parity byte) and starts decrementing every clock till it reached 
					count<=fifo[read_ptr[3:0]][7:2]+1'b1;  // header byte + payload length in bits 2 to 7 and finally parity bit loaded       

				else if(count!=6'd0)
					count<=count-1'b1;  // if count is not 0 decreament it till 0 --> so that all items are read
				
			end
	
	end
//----------------------------------------
//pointer logic
always@(posedge clk)
	begin
		if(!resetn || soft_reset)
			begin
				read_ptr=5'd0;
				write_ptr=5'd0;
			end

		else if ((write_enb && !full)&&(read_enb && !empty))
			begin
				write_ptr <= write_ptr;
				read_ptr=read_ptr;
			end
		else if(write_enb && !full)
					write_ptr=write_ptr+1'b1;
					else 
					write_ptr <= write_ptr;
		else if(read_enb && !empty)
					read_ptr=read_ptr+1'b1;
					else 
						read_ptr = read_ptr;
	end
	assign empty_out = (write_ptr == read_ptr) ? 1'b1:1'b0;
	assign full_out = (w)
endmodule