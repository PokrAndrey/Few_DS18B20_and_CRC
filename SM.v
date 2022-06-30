module SM (
    input [9:0]state,
    input [7:0]one_byte_of_address,
    output reg [7:0]command
    );

    always @(*)
    begin
        case (state)
            10'd0: command <= 8'h00;
            10'd1: command <= 8'hFF; //чтение
            10'd2: command <= 8'h55;
            10'd3: command <= one_byte_of_address;
            10'd4: command <= one_byte_of_address;
            10'd5: command <= one_byte_of_address;
            10'd6: command <= one_byte_of_address;
            10'd7: command <= one_byte_of_address;
            10'd8: command <= one_byte_of_address;
            10'd9: command <= one_byte_of_address;
            10'd10: command <= one_byte_of_address;
            10'd11: command <= 8'hBE;
            10'd12: command <= 8'hFF; //чтение
            10'd13: command <= 8'hFF; //чтение
            10'd14: command <= 8'hFF; //чтение
            10'd15: command <= 8'hFF; //чтение
            10'd16: command <= 8'hFF; //чтение
            10'd17: command <= 8'hFF; //чтение
            10'd18: command <= 8'hFF; //чтение
            10'd19: command <= 8'hFF; //чтение
            10'd20: command <= 8'hFF; //чтение
            10'd21: command <= 8'h00;
            10'd22: command <= 8'hFF; //чтение
            10'd23: command <= 8'hCC;
            10'd24: command <= 8'h44;
            default: command <= 8'h00;
        endcase
    end

endmodule

