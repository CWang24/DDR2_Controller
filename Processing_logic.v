////////////////////////top///////////////////////////
`define TCMD	9'd002 
`define TGET0	`TCMD+1
`define TJUDGE	`TGET0+2

///////////////////////scr/////////////////////////////
`define RNOP1	9'd010 
`define RACT1	`RNOP1+2
`define RNOP2	`RACT1+2
`define RREAD1	`RNOP2+2
`define RNOP3	`RREAD1+2

`define RNOP4	`RNOP3+6 	//AL=4
`define RNOP5	`RNOP4+6	 //set listen
`define	RNOP6	`RNOP5+2	//reset listen
`define	RNOP16	`RNOP6+1
`define	RNOP7	`RNOP6+2	//withdraw data  16clock+additive  put=1
`define	RNOP8	`RNOP7+1	//put=0
`define	RNOP9	`RNOP8+1
`define	RNOP10	`RNOP9+1
`define	RNOP11	`RNOP10+1
`define	RNOP12	`RNOP11+1
`define	RNOP13	`RNOP12+1
`define	RNOP14	`RNOP13+1
`define	RNOP15	`RNOP14+1
/////////////////////scw/////////////////////////////////
`define WNOP1	9'd200 
`define WACT1	`WNOP1+2
`define WNOP2	`WACT1+2
`define WWRITE1	`WNOP2+2
`define WNOP3	`WWRITE1+2
`define WNOP4	`WNOP3+6 //AL = 4
`define WNOP5	`WNOP4+5//CL-1=3     +DQSS
`define WNOP6	`WNOP5+1	//send DATA_get signal
`define WDQS0	`WNOP6+1 //generate DQS
`define WDQS1	`WDQS0+1
`define WDQS2	`WDQS1+1
`define WDQS3	`WDQS2+1
`define WDQS4	`WDQS3+1
`define WDQS5	`WDQS4+1
`define WDQS6	`WDQS5+1
`define WDQS7	`WDQS6+1
`define	WNOP8	`WDQS7+1
`define WNOP7	`WACT1+40 //RAS+RP=29   +5ADDITIVE

/////////////////////////atomic//////////////////////////
`define ARNOP1	9'd300 
`define ARACT1	`ARNOP1+2
`define ARNOP2	`ARACT1+2
`define ARREAD1	`ARNOP2+2
`define ARNOP3	`ARREAD1+2

`define ARNOP4	`ARNOP3+6 	//AL=4
`define ARNOP5	`ARNOP4+6	 //set listen
`define	ARNOP6	`ARNOP5+2	//reset listen
`define	ARNOP7	`ARNOP6+1
`define	ARNOP10	`ARNOP7+1
`define	ARNOP8	`ARNOP7+2	//withdraw data  16clock+additive  put=1
`define	ARNOP9	`ARNOP8+8



`define AWNOP1	`ARNOP9+1 
`define AWACT1	`AWNOP1+2
`define AWNOP2	`AWACT1+2
`define AWWRITE1	`AWNOP2+2
`define AWNOP3	`AWWRITE1+2
`define AWNOP4	`AWNOP3+6 //AL = 4
`define AWNOP5	`AWNOP4+5//CL-1=3     +DQSS
`define AWNOP6	`AWNOP5+1	//send DATA_get signal
`define AWDQS0	`AWNOP6+1 //generate DQS
`define AWDQS1	`AWDQS0+1
`define AWDQS2	`AWDQS1+1
`define AWDQS3	`AWDQS2+1
`define AWDQS4	`AWDQS3+1
`define AWDQS5	`AWDQS4+1
`define AWDQS6	`AWDQS5+1
`define AWDQS7	`AWDQS6+1
`define	AWNOP8	`AWDQS7+1
`define AWNOP7	`AWACT1+40 //RAS+RP=29   +5ADDITIVE

///////////////////REFRESH/////////////////////
`define FF1		9'd401
`define FNOP1	`FF1+2
`define FNOP2	`FNOP1+50




module Processing_logic(
   // Outputs
   DATA_get, 
   CMD_get, //top
   RETURN_put, 
   RETURN_address, RETURN_data,  //construct RETURN_data_in
   cs_bar, ras_bar, cas_bar, we_bar,  // read/write function
   BA, A, DM,
   DQS_out, DQ_out,
   ts_con,
   // Inputs
   clk, ck, reset, ready, 
   CMD_empty, //top
   CMD_data_out, //all for top, patial for read
   DATA_data_out,
   RETURN_full,
   DQS_in, DQ_in
   );

   parameter BL = 4'b1000; // Burst Lenght = 8
   parameter BT = 1'b0;   // Burst Type = Sequential
   parameter CL = 3'b100;  // CAS Latency (CL) = 4
   parameter AL = 3'b100;  // Posted CAS# Additive Latency (AL) = 4

   
   input 	 clk, ck, reset, ready;
   input 	 CMD_empty, RETURN_full;
   input [32:0]	 CMD_data_out;
   input [15:0]  DATA_data_out;
   input [15:0]  DQ_in;
   input [1:0]   DQS_in;
 
   output reg CMD_get;
   output reg	DATA_get, RETURN_put;
   output reg [24:0] RETURN_address;
   output wire [15:0] RETURN_data;
   output reg	cs_bar, ras_bar, cas_bar, we_bar;
   output reg [1:0]	 BA;
   output reg [12:0] A;
   output reg [1:0]	 DM;
   output reg [15:0]  DQ_out;
   output reg [1:0]   DQS_out;
   output reg ts_con;
   
   reg	[15:0]	data_temp;
   reg listen;

   reg DM_flag;
   
   reg	[15:0]	DQ;
   
   reg	[12:0]	refresh_counter;
   reg	[8:0]	counter;
   reg	[2:0]	Pointer;
   reg	[2:0]	add_counter;
   reg	[2:0]	cmd_counter;
   reg	[24:0]	addr;
   reg			block_flag;
   reg			atomic_flag;
   reg			atomic_read_flag;
always @(posedge clk)
	if(reset)
		begin
		counter <= 1;
		refresh_counter <= 0;
		
		/////////TOP////////
		CMD_get <= 0;
		/////////SCR////////
		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
		A <= 0;
		BA <= 0;
		listen <= 0;
		Pointer <= 3'b000;
		RETURN_put <= 0;
		////////////SCW///////////
	//	DQS_out[0] <= 0;
		DATA_get <= 0;
		DM_flag <= 0;
		
		ts_con <= 0;
		add_counter <= 0;
		block_flag <= 0;
		atomic_flag <= 0;
		atomic_read_flag <= 0;
		end
	else if (ready)
		begin
		counter <=counter + 1;
		refresh_counter <= refresh_counter+1;
		case (counter)
		
		///////////////TOP////////////////
		`TCMD:
			begin
			
		//////////////REFRESH//////////////
			if (refresh_counter >= 6000)
				begin
				counter <= 9'd400;
				end
				
			else
				begin
				if (!CMD_empty)
					begin
					CMD_get <= 1;
					end
				else
					counter <= 1;
				end
			end
			
		`TGET0:
			begin
			CMD_get <= 0;
			end
		
		`TJUDGE:
			begin
	//		CMD_get <= 0;
			addr <= CMD_data_out[32:8];
			cmd_counter <= CMD_data_out[4:3];
			
			///////////block read////////////
			if (CMD_data_out[7:5] == 3'b011)
				begin
				counter <= 8'd010;
				block_flag <= 1;
				end
			
			///////////scalar read////////////
			else if (CMD_data_out[7:5] == 3'b001)
				begin
				counter <= 8'd010; //`RNOP1
				block_flag <= 0;
				cmd_counter <= 0;
				end
				
			///////////////scalar write///////////////	
			else if(CMD_data_out[7:5] == 3'b010)
				begin
				counter <= 8'd200; //`WNOP1;
				block_flag <= 0;
		//		cmd_counter <= CMD_data_out[4:3];
				cmd_counter <= 0;
				end
				
			/////////////////block write///////////////////	
			else if (CMD_data_out[7:5] == 3'b100)
				begin
				counter <= 8'd200; //`WNOP1;
				block_flag <= 1;
				end
			/////////////////////atomic read//////////////////////
			else if (CMD_data_out[7:5] == 3'b101)
				begin
				counter <= 9'd300;
				atomic_flag <= 1;
				atomic_read_flag <= 1;
				end
			/////////////////////atomic write//////////////////////
			else if (CMD_data_out[7:5] == 3'b110)
				begin
				counter <= 9'd300;
				atomic_flag <= 1;
				
				end	
				
			else
				counter <= 1;
			end
		
		
		
		///////////////SCR////////////////
		`RNOP1:
			begin
			ts_con <= 0;
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
			
		`RACT1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0011;
			A <= addr[24:12];
			BA <= addr[11:10];
			end
			
		`RNOP2:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
		
		`RREAD1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0101;
			A[9:0] <= addr[9:0];
			A[10] <= 1;
			add_counter <= 0;
			//BA <= CMD_data_out[19:18];
			end
		
		`RNOP3:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
			
			
		`RNOP5:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		listen <= 1;
			end
		
		`RNOP6:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		listen <= 0;
			listen <= 1;
			
			end
			
		`RNOP16:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			Pointer <= 3'b000;
	//		RETURN_address <= add_counter ^ addr;
	//		add_counter <= add_counter+1;

			end	
		
		// `RNOP17:
			// begin
			// RETURN_put <= block_flag;
			// end
		
		
		`RNOP7:
			begin
			listen <= 0;
			RETURN_put <= 1;
			
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
		//	RETURN_put <= 1;
		//	Pointer <= Pointer + 1;
			RETURN_address <= add_counter ^ addr;
			add_counter <= add_counter+1;
			end
		
		`RNOP8:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			RETURN_put <= block_flag;
			
			Pointer <= Pointer + 1;
			RETURN_address <= add_counter ^ addr;
			add_counter <= add_counter+1;
			end
			
		`RNOP9:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		RETURN_put <= 0;
			Pointer <= Pointer + 1;
			RETURN_address <= add_counter ^ addr;
			add_counter <= add_counter+1;
			end	
			
		`RNOP10:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		RETURN_put <= 0;
			Pointer <= Pointer + 1;
			RETURN_address <= add_counter ^ addr;
			add_counter <= add_counter+1;
			end	

		`RNOP11:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		RETURN_put <= 0;
			Pointer <= Pointer + 1;
			RETURN_address <= add_counter ^ addr;
			add_counter <= add_counter+1;
			end	

		`RNOP12:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		RETURN_put <= 0;
			Pointer <= Pointer + 1;
			RETURN_address <= add_counter ^ addr;
			add_counter <= add_counter+1;
			end	
			
		`RNOP13:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		RETURN_put <= 0;
			Pointer <= Pointer + 1;
			RETURN_address <= add_counter ^ addr;
			add_counter <= add_counter+1;
			end	
			
		`RNOP14:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		RETURN_put <= 0;
			
			
			Pointer <= Pointer + 1;
			RETURN_address <= add_counter ^ addr;
			add_counter <= add_counter+1;
			end		
			
		`RNOP15:
			begin
			RETURN_put <= 0;
			if (cmd_counter == 2'b00)
				counter <= 1;
			else
				begin
				cmd_counter <= cmd_counter-1;
				addr <= addr+8;
				counter <= 8'd9;
				end
				
			end
		
	///////////////////////////////SCW///////////////////////
		
		`WNOP1:
			begin
			ts_con <= 1;
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
			
		`WACT1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0011;
			A <= addr[24:12];
			BA <= addr[11:10];
			end
		
		`WNOP2:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
		
		`WWRITE1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0100;
			A[9:0] <= addr[9:0];
			A[10] <= 1;
			//BA <= CMD_data_out[19:18];
			end
		
		`WNOP3:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
		
		`WNOP4:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
		
		`WNOP5:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		DQS_out[0] <= 0;
			DATA_get <= 1;
			DQS_out <= 0;
			end
		
		`WNOP6:
			begin
			DM_flag <= 1;
			DATA_get <= block_flag;
		//	DQS_out[0] <= 0;
			end
		
		
		
		`WDQS0:
			begin
			DQS_out <= ~DQS_out;
			DM_flag <= block_flag;
			end
		
		`WDQS1:
			begin
			DQS_out <= ~DQS_out;
			
			end
		
		`WDQS2:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			end
		
		`WDQS3:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			end
		
		`WDQS4:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			end
		
		`WDQS5:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			end
		
		`WDQS6:
			begin
			DQS_out <= ~DQS_out;
			DATA_get <= 0;
			end
		
		`WDQS7:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			
			DM_flag <= 0;
			end
			
		`WNOP8:
			begin
			ts_con <= 0;
			end
			
		`WNOP7:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
				
			if (cmd_counter == 2'b00)
				counter <= 1;
			else
				begin
				cmd_counter <= cmd_counter-1;
				addr <= addr+8;
				counter <= 8'd199;
				end
			end
			
///////////////////////////////ATOMIC///////////////////////////////////			
		`ARNOP1:
			begin
			ts_con <= 0;
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
			
		`ARACT1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0011;
			A <= addr[24:12];
			BA <= addr[11:10];
			end
			
		`ARNOP2:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
		
		`ARREAD1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0101;
			A[9:0] <= addr[9:0];
			A[10] <= 1;
			add_counter <= 0;
			//BA <= CMD_data_out[19:18];
			end
		
		`ARNOP3:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
			
			
		`ARNOP5:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		listen <= 1;
			end
		
		`ARNOP6:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		listen <= 0;
			listen <= 1;
			Pointer <= 3'b000;
			RETURN_address <= addr;
			end
			
		`ARNOP7:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			
			DATA_get <= 1;
			end	

		`ARNOP10:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			DATA_get <= 0;
			RETURN_put <= atomic_read_flag;
			listen <= 0;
			end	
		
		`ARNOP8:
			begin
			RETURN_put <= 0;
			data_temp <= RETURN_data;
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
		//	RETURN_put <= 1;
			
			end
			
		`ARNOP9:
			begin
		//	counter <= 1;
			case(CMD_data_out[2:0])
				0:	DQ <= data_temp - DATA_data_out;
				1:	DQ <= ~(DATA_data_out & data_temp);
				2:	DQ <= DATA_data_out + data_temp;
				3:	DQ <= DATA_data_out ^ data_temp;
				4:	DQ <= ~(DATA_data_out | data_temp);
				5:	DQ <= {	data_temp[0],data_temp[1],data_temp[2],data_temp[3],
							data_temp[4],data_temp[5],data_temp[6],data_temp[7],
							data_temp[8],data_temp[9],data_temp[10],data_temp[11],
							data_temp[12],data_temp[13],data_temp[14],data_temp[15]};
				6:	DQ <= {data_temp[15],data_temp[15:1]};
				7:	DQ <= {data_temp[14:0],1'b0};
			endcase	
			end
			
		`AWNOP1:
			begin
			ts_con <= 1;
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
			
		`AWACT1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0011;
			A <= addr[24:12];
			BA <= addr[11:10];
			end
		
		`AWNOP2:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
		
		`AWWRITE1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0100;
			A[9:0] <= addr[9:0];
			A[10] <= 1;
			//BA <= CMD_data_out[19:18];
			end
		
		`AWNOP3:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
		
		`AWNOP4:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
		
		`AWNOP5:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
	//		DQS_out[0] <= 0;
	//		DATA_get <= 1;
			DQS_out <= 0;
			end
		
		`AWNOP6:
			begin
			DM_flag <= 1;
		//	DATA_get <= 0;
		//	DQS_out[0] <= 0;
			end
		
		
		
		`AWDQS0:
			begin
			DQS_out <= ~DQS_out;
			DM_flag <= 0;
			end
		
		`AWDQS1:
			begin
			DQS_out <= ~DQS_out;
			
			end
		
		`AWDQS2:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			end
		
		`AWDQS3:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			end
		
		`AWDQS4:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			end
		
		`AWDQS5:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			end
		
		`AWDQS6:
			begin
			DQS_out <= ~DQS_out;
			DATA_get <= 0;
			end
		
		`AWDQS7:
			begin
			DQS_out <= ~DQS_out;
	//		DM_flag <= 0;
			
		//	DM_flag <= 0;
			end
			
		`AWNOP8:
			begin
			ts_con <= 0;
			end
			
		`AWNOP7:
			begin
	//		{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
				
			counter <= 1;
			atomic_flag <= 0;
			atomic_read_flag <= 0;
			end	
		
	////////////////REFRESH/////////////////	
		`FF1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0001;
			refresh_counter <= 0;
			end
			
		`FNOP1:
			begin
			{cs_bar, ras_bar, cas_bar, we_bar} <= 4'b0111;
			end
			
		`FNOP2:
			begin
			counter <= 1;
			end	
		
		endcase
		
		
		
		end

ddr2_ring_buffer8 ring_buffer(RETURN_data, listen, DQS_in[0], Pointer[2:0], DQ_in, reset);


always @(negedge clk)
  begin
    DQ_out <= (atomic_flag) ? DQ : DATA_data_out;
    if(DM_flag)
        DM <= 2'b00;
    else
        DM <= 2'b11;	
  end
 
endmodule // ddr2_controller
