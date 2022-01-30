/********
kpdecode.sv

Written by Jimmy Bates (A01035957)

ELEX 7660-Digital System Design
Lab 2

Date created: January 20,2022

Decodes the KPR and KPC bits into the associated button pressed
Done by concatenating KPR and KPC and decoding as a single block
*********/
module kpdecode (	input logic [3:0] kpr,
			input logic [3:0] kpc, 
			output logic kphit,
			output logic [3:0] num );

	logic [7:0] kpc_kpr_conc; //concatenate kpc and kpr

	assign kphit = ~(&kpr);	// compile all bits of kpr and nand them

	always_comb begin
	kpc_kpr_conc = { kpc, kpr };
	//Combination logic that decodes kpr and kpc to output a num
		case (kpc_kpr_conc)
			'b01110111 : num = 'h1;
			'b01111011 : num = 'h4;
			'b01111101 : num = 'h7; 
			'b01111110 : num = 'he;
			'b10110111 : num = 'h2;
			'b10111011 : num = 'h5;
			'b10111101 : num = 'h8;
			'b10111110 : num = 'h0;
			'b11010111 : num = 'h3;
			'b11011011 : num = 'h6;
			'b11011101 : num = 'h9;
			'b11011110 : num = 'hf;
			'b11100111 : num = 'ha;
			'b11101011 : num = 'hb;
			'b11101101 : num = 'hc;
			'b11101110 : num = 'hd;
			default : num = 'h0;
		endcase	
	end						
endmodule