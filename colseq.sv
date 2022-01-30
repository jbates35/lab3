/********
colseq.sv

Written by Jimmy Bates (A01035957)

ELEX 7660-Digital System Design
Lab 2

Date created: January 20,2022

Implements a state machine that moves kpc along to its next value
Essentially, KPC should advance if kpr isn't pressed, when theres a rising
edge of the clock.

*********/
module colseq (input logic [3:0] kpr,
					output logic [3:0] kpc,
					input logic clk, reset_n);
					
	logic [3:0] kpc_next; //Intermediary node to take care of the next KPC value	
	
	//Multiplexer taking care of the next kpc bit (quasi state machine)
	//Checks each case to see if any button is pressed before taking next val
	always_comb
		case (kpc) 
			'h7 : kpc_next = &kpr ? 'hb : kpc;
			'hb : kpc_next = &kpr ? 'hd : kpc;
			'hd : kpc_next = &kpr ? 'he : kpc;
			'he : kpc_next = &kpr ? 'h7 : kpc;
			default: kpc_next = kpc;
		endcase

	always_ff @(posedge (clk), negedge reset_n)
        if (~reset_n) //Original value in case of reset
            kpc <= 'h7; 
        else //Otherwise, take kpc_next into the value of the FF
            kpc <= kpc_next; 
				
endmodule