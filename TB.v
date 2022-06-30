module TB  (
    input signal,
    input clk,
    input wire pon,
    input F1M,
    input [7:0]in_byte,
    input change_state,
    output wire OE_to_tri,     
	output reg [9:0]state = 0,
    output reg [7:0]byte,
    output reg EoB = 0,
	output reg presense = 0
    );

    assign OE_to_tri = OE | measure | read_presense;



    reg [10:0]delay_measure = 0;
    reg measure = 0;
    wire inv_OE = ~OE;
    reg [2:0]one_byte_counter = 0;
    reg OE = 0;
    wire START = pon | EoB; 
    wire read_presense = (state == 5'd1) | (state == 5'd22);
    wire reset = (state == 5'd0) | (state == 5'd21);
    reg [9:0]counter = 0;



    always @(posedge clk)
    begin
        if (F1M)
        begin
            if(START)
            begin
                EoB <= 1'b0;
                byte <= in_byte;
                measure <= (delay_measure < 1600) & (delay_measure > 0);
            end
            else
            begin
                if (counter < 60)
                begin
                    OE <= ((counter == 0) | (counter == 10'b1)) ? 0       :  
                          (counter == 2)                        ? byte[0] : OE;
                    byte <= (counter == 15) ? {signal, byte[7:1]} : byte;
                    counter <= counter + 1'b1;
                end
                else
                begin
                    counter <= 0;
                    one_byte_counter <= one_byte_counter + 1'b1;

                    OE <= (one_byte_counter == 7) ? 1 : ~reset;
                    delay_measure <= (one_byte_counter != 7) ? delay_measure : (measure | state == 10'd24) ? delay_measure + 11'b1 : 0;                   
                    EoB <= (one_byte_counter == 7) ? 1'b1 : EoB;
                    state <= (one_byte_counter != 7) ? state : ((~(&byte) & read_presense) | (~measure)) ? state + 1 : 0;
                    presense <= (one_byte_counter == 7) ? ~(&byte) & read_presense : presense;
                end
            end        
        end
    end


endmodule
