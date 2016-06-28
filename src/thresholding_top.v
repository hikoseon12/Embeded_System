// ***********************************************************************
// TITLE       : Thresholding_Top Module   
// AUTHOR      : Jiseon Kim 
// AFFILIATION : Dept. of CS, Sookmyung Women's University 
// DESCRIPTION : Top module including Tresholding and Dual-Port SRAM                     
// ***********************************************************************

`timescale 1 ns/1 ns

`define A_WIDTH 17
`define D_WIDTH 8

module Thresholding_Top(Go_t, Done_t, Rst_Core, 
			MP_di31, MP_di8, MP_do31, MP_Addr15, MP_enb, MP_web, Rst_P,
			MB_di8_2, MB_do8, MB_do8_2, MB_Addr17_2, MB_ena, MB_wea, Rst_B,
			Clk);


	//Thresholding_Core interface
	input Go_t;
	output Done_t;
	input Rst_Core;

	//Dual-port SRAM_P Interface 
	input [31:0] MP_di31;
	input [7:0] MP_di8;	//not used!
	output [31:0] MP_do31;	//not used!
	input [14:0] MP_Addr15;
	input MP_enb, MP_web;
	input Rst_P;
	
	//Dual-port SRAM_B Interface 
	input [7:0] MB_di8_2;	//not used!
	output [7:0] MB_do8, MB_do8_2;	//do8: not used!
	input [16:0] MB_Addr17_2;
	input MB_ena, MB_wea;
	input Rst_B;

	//Interface between Thresholdingn_Core and Dual_port SRAM_P
	wire [(`D_WIDTH-1):0] MP_do8;
   	wire [(`A_WIDTH-1):0] MP_Addr17;
   	wire MP_ena, MP_wea;

	//Interface between Thresholdingn_Core and Dual_port SRAM_B
	wire [(`D_WIDTH-1):0] MB_di8;
   	wire [(`A_WIDTH-1):0] MB_Addr17; 
   	wire MB_enb, MB_web;

	//Common Interface 
   	input Clk;

	Tresholding T_Core(Go_t, MP_Addr17, MP_do8, MB_Addr17, MP_wea, MP_ena, MB_web, MB_enb,
			 Done_t, MB_di8, Clk, Rst_Core);

	dp_sram_coregen_p MemP(
	MP_Addr17,//addra,
	MP_Addr15,//addrb,
	Clk,//clka,
	Clk,//clkb,
	MP_di8,//dina,
	MP_di31,//dinb,
	MP_do8,//douta,
	MP_do31,//doutb,
	MP_ena,//ena,
	MP_enb,//enb,
	Rst_P,//sinita,
	Rst_P,//sinitb,
	MP_wea,//wea,
	MP_web);//web);
   
   	dp_sram_coregen_b MemB(
	MB_Addr17_2,//addra,
	MB_Addr17,//addrb,
	Clk,//clka,
	Clk,//clkb,
	MB_di8_2,//dina,
	MB_di8,//dinb,
	MB_do8_2,//douta,
	MB_do8,//doutb,
	MB_ena,//ena,
	MB_enb,//enb,
	Rst_B,//sinita,
	Rst_B,//sinitb,
	MB_wea,//wea,
	MB_web);//web);

endmodule

