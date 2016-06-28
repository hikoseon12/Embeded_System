// ***********************************************************************
// TITLE       : Testbench for Thresholding_Top   
// AUTHOR      : Jiseon Kim 
// AFFILIATION : Dept. of CS, Sookmyung Women's University 
// DESCRIPTION : Testbench simulating Thresholding_Top Module                     
// ***********************************************************************
`timescale 1 ns/1 ns

`define A_WIDTH 17
`define D_WIDTH 8

module Testbench_Top();
	reg			Go_t_s;
	wire			Done_t_s;
	reg			Rst_Core_s;
	reg [31:0]		MP_di31_s;
	wire [(`D_WIDTH-1):0]	MP_di8_s; //dummy
	wire [31:0]		MP_do31_s; //dummy
	reg [14:0]		MP_Addr15_s;
	reg			MP_enb_s;
	reg			MP_web_s;
	reg			Rst_P_s;
	wire [7:0]		MB_di8_2_s; //dummy
	wire [7:0]		MB_do8_s; //dummy
	wire [7:0]		MB_do8_2_s; 
	reg [16:0]		MB_Addr17_2_s;
	reg			MB_ena_s;
	reg			MB_wea_s;
	reg			Rst_B_s;
	reg			Clk_s;

	reg [31:0] P [0:(19200-1)];
	reg [(`D_WIDTH-1):0] Ref [0:(76800-1)];
	reg [17:0] Count;
	reg [16:0] correct, incorrect;
	parameter ClkPeriod = 20;

	// Clock Procedure
	always begin
		Clk_s <= 0; #(ClkPeriod/2);
		Clk_s <= 1; #(ClkPeriod/2);
	end

	Thresholding_Top CompToTest_Top(
	Go_t_s,
	Done_t_s,
	Rst_Core_s,
	MP_di31_s,
	MP_di8_s,
	MP_do31_s,
	MP_Addr15_s,
	MP_enb_s,
	MP_web_s,
	Rst_P_s,
	MB_di8_2_s,
	MB_do8_s,
	MB_do8_2_s,
	MB_Addr17_2_s,
	MB_ena_s,
	MB_wea_s,
	Rst_B_s,
	Clk_s
	);

	//Initialize Arrays
	initial $readmemh("../sw/MemP_4.txt", P);
	initial $readmemh("../sw/sw_result.txt", Ref);

	initial begin
		Rst_P_s <= 1; Rst_B_s <= 1; Rst_Core_s <= 1;
		Go_t_s <= 0;
		MP_enb_s <= 1'b0; MB_ena_s <= 1'b0;
		MP_web_s <= 1'b0; MB_wea_s <= 1'b0;
		@(posedge Clk_s);
		
		Rst_P_s <= 0; Rst_B_s <= 0;
		@(posedge Clk_s);

		for(Count = 0;Count < 19200;Count = Count + 1) begin 
			MP_enb_s <= 1'b1;
			MP_web_s <= 1'b1;
			MP_Addr15_s <= Count;
			MP_di31_s <= P[Count];
			@(posedge Clk_s);
		end

		MP_enb_s <= 1'b0;
		MP_web_s <= 1'b0;
		@(posedge Clk_s);

		//Running Thresholding-Core
		Rst_Core_s <= 0; Go_t_s <= 1;
		@(posedge Clk_s);

		Go_t_s <= 0;
		@(posedge Clk_s);

		while(Done_t_s != 1'b1)
      	  		@(posedge Clk_s);

		correct <= 0; incorrect <= 0;
		@(posedge Clk_s);

		for(Count = 0; Count < 76800; Count = Count + 1) begin
			MB_Addr17_2_s <= Count;
			MB_ena_s <= 1;
			MB_wea_s <= 0;
			@(posedge Clk_s);
			@(posedge Clk_s);
			if(MB_do8_2_s == Ref[Count]) begin
				$display("%d.MB_do8_2_s : %d and is equal to sw_result: %d", Count, MB_do8_2_s, Ref[Count]);
				correct <= correct + 1;
			end			
			else begin
				$display("FAILED!! %d.MB_do8_2_s : %d and is not equal to sw_result: %d", Count, MB_do8_2_s, Ref[Count]);
				incorrect <= incorrect + 1;			
			end
			@(posedge Clk_s);
		end
		$display("correct : %d, incorrect : %d", correct, incorrect);
		$stop;
	end


endmodule
