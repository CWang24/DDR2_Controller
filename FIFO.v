module FIFO (clk, reset, data_in, put, get, data_out, fillcount, empty, full);
input put, get, reset, clk;
output data_out, fillcount, empty, full;

parameter WIDTH=16;//4'h08;
parameter DEPTH_P = 3;
parameter DEPTH_P2=8;//4'h10;

input [WIDTH-1 : 0] data_in;
reg [DEPTH_P-1:0] wr_ptr,rd_ptr;
reg [DEPTH_P:0] fillcount;
reg [WIDTH-1:0] stack [0:DEPTH_P2-1];
reg [WIDTH-1:0]data_out;
reg full;
reg empty;
//assign full = (fillcount == DEPTH_P2);
// assign empty = (fillcount == 0);
always@(posedge clk)
	begin
		if (reset==1)
			begin
				fillcount<=3'b000; 
				wr_ptr<=3'b000;
				rd_ptr<=3'b000;
				full<=0;
				empty<=1;
				// stack[0]<=16'h0000;
				// stack[1]<=16'h0000;
				// stack[2]<=16'h0000;
				// stack[3]<=16'h0000;
				// stack[4]<=16'h0000;
				// stack[5]<=16'h0000;
				// stack[6]<=16'h0000;
				// stack[7]<=16'h0000;
			end
		else
			begin
				if((put)&&(!full))
					begin
						stack[wr_ptr]<=data_in;
						wr_ptr<=wr_ptr+1;
						fillcount<=fillcount+1;
						if(fillcount==DEPTH_P2-1)
							full<=1;
						if(empty==1)
							empty<=0;
					end
				if((get)&&(!empty))
					begin
						data_out<=stack[rd_ptr];
						rd_ptr<=rd_ptr+1;
						fillcount<=fillcount-1;	
						if(full==1)
							full<=0;
						if(fillcount==1)
							empty<=1;
					end
				if((get)&&(put)&&(!empty)&&(!full))
					begin
						// stack[wr_ptr]<=data_in;
						//wr_ptr<=wr_ptr+1;
						// data_out<=stack[rd_ptr];
						//rd_ptr<=rd_ptr+1;
						fillcount<=fillcount;
						full<=full;
						empty<=empty;
					end
				// if((get)&&(put)&&(empty))
					// begin
						// fillcount<=fillcount+1;
						// // stack[wr_ptr]<=data_in;
						// wr_ptr<=wr_ptr+1;
					// end
				// if((get)&&(put)&&(full))
					// begin
						// fillcount<=fillcount-1;
						// // data_out<=stack[rd_ptr];
						// rd_ptr<=rd_ptr+1;
					// end
			end
	end//end of always
endmodule
