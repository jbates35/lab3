/********
adcinterface.sv

Written by Jimmy Bates (A01035957)

ELEX 7660-Digital System Design
Lab 3

Date created: January 20,2022

Implements the state of the ADC machine

code for modelsim:
vsim work.adcinterface_tb; add wave sim:*; run -all

*********/

`define SCK_COUNT_MAX 'd11
`define N 12

module adcinterface(
    input logic clk, reset_n, //Clock and reset
    input logic [2:0] chan, // ADC channel to sample
    output logic [11:0] result, //ADC result

    // ltc2308 signals
    output logic ADC_CONVST, ADC_SCK, ADC_SDI,
    input logic ADC_SDO
);

    logic [`N:0] SPI_word_in, SPI_word_in_next; //If channel gets switched, need to make new word
    logic [(`N-1):0] SPI_word_out; //This might be unnecessary - will store the result that gets stuffed into "result"
    logic [3:0] count, count_next; // Which bit in the result that is currently being updated
    logic ADC_CONVST_next, ADC_SDI_next; // Take care of inversion and next config big
    logic word_finished; // Take rising edge and stuff word into result
    logic reset_count;  // Bit that resets count

    //////////// STATE MACHINE  /////////////
    typedef enum { S_START = 'h0, S_OFF = 'h1, S_HOLD = 'h2, S_ACTIVE = 'h4, S_FINISH = 'h8 } state_t;
        state_t ADC_curr = S_START;
        state_t ADC_next;

    always_comb begin : statemachines
        //Multiplex state machine
        ADC_next = ADC_curr;

        case(ADC_curr)
            S_START: ADC_next = S_OFF;
            S_OFF: ADC_next = (ADC_CONVST=='b1) ? S_HOLD : S_OFF; //Lets CONVST go high for one cycle
            S_HOLD: ADC_next = S_ACTIVE; //Wait one cycle before taking ADC bits
            S_ACTIVE: ADC_next = (count==0) ? S_FINISH : S_ACTIVE; //Continue taking bits until count is 0
            S_FINISH: ADC_next = S_OFF; //Wait one cycle before allowed to reset cycle
        endcase
    end : statemachines


    ///////////// ASSIGNMENTS ////////////////
    always_comb begin : assignments

        //Sets anytime
        count_next = (count == 0) ? 0 : count-1; //Assign next counts

        //Sets during ADC OFF
        SPI_word_in_next = (ADC_curr == S_OFF) ? { 1'b1, chan[0], chan[2:1], 9'b1_0000_0000 } : SPI_word_in; //Config word gets set 
        ADC_CONVST_next = (ADC_curr == S_OFF) ? ~ADC_CONVST : 'b0; //CONVST turns on to activate ADC

        //Sets when ADC HOLD
        reset_count = (ADC_curr == S_HOLD) ? 'b1 : 'b0; //SPI_word_in and count get set when this is high

        //Sets when ADC ACTIVE
        ADC_SCK = (ADC_curr == S_ACTIVE) ? clk : 1'b0; //Assign clock to SCK if correct state
        
        //MSB of the Config word needs to get activated on the clock *before* SCK activates
        case(ADC_curr)
            S_HOLD: ADC_SDI_next = SPI_word_in[`N];
            S_ACTIVE: ADC_SDI_next = SPI_word_in[count];
            default: ADC_SDI_next = 0;
        endcase
    end

    always_ff @(posedge ADC_SCK) SPI_word_out[count] <= ADC_SDO; //Capture word coming in from SDI Out of ADC
    always_ff @(negedge ADC_SCK, posedge reset_count) count <= reset_count ? `SCK_COUNT_MAX : count_next; //Reset count to max value (11) or count-1 or 0
    always_ff @(posedge ADC_curr[4]) result <= SPI_word_out; //update result once ADC is finished

    //State machine clock
    always_ff @(negedge clk, negedge reset_n) begin: clock_ffs 
        //Reset ADC
        if(~reset_n) begin
            ADC_curr <= S_START; // Reset State machine
            ADC_SDI <= 'b0; // Reset SDI bit
            ADC_CONVST <= 'b0; // Rset CONVST in case
        end
        //Else, take next state of state machine
        else begin
            ADC_CONVST <= ADC_CONVST_next; // Activate ADC
            ADC_curr <= ADC_next; // move state machine forward
            SPI_word_in <= SPI_word_in_next; //Config message
            ADC_SDI <= ADC_SDI_next; //Config message
        end
    end : clock_ffs    
endmodule