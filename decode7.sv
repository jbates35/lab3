/********
decode7.sv (MODIFIED)

Written by Jimmy Bates (A01035957)

ELEX 7660-Digital System Design
Lab 2

Date created: January 14, 2022
Modified: January 20, 2022

This module implements a 4 bit decoder to 7 segment display 
for the input 0000->1111 equalling 0-e in hex

Note: this segment is active low
*********/

module decode7 (input logic [3:0] num , output logic [7:0] leds);

	//Decoder
	always_comb
		case (num)
			//				  .GFEDCBA
			'h0 : leds = 'b11000000;
			'h1 : leds = 'b11111001; 
			'h2 : leds = 'b10100100; 
			'h3 : leds = 'b10110000;
			'h4 : leds = 'b10011001; 
			'h5 : leds = 'b10010010; 
			'h6 : leds = 'b10000010; 
			'h7 : leds = 'b11111000; 
			'h8 : leds = 'b10000000; 
			'h9 : leds = 'b10010000; 
			'ha : leds = 'b10001000; 
			'hb : leds = 'b10000011; 
			'hc : leds = 'b11000110; 
			'hd : leds = 'b10100001; 
			'he : leds = 'b10000110; 
			'hf : leds = 'b10001110; 
		endcase
	
endmodule