module bin_to_dec (
    input [15:0]bin_temperature,
    input convert_en,
    input clk,
    input F1M,
    output wire pos_front_EoConvert,
    output reg [15:0]dec_temperature
    );
    
    reg [6:0]cn_bin;
    reg [15:0]cn_dec = 0;
    reg EoConvert = 1'b1;
    wire load_en;
    wire [10:0]u_bin_temperature = (bin_temperature[10:0] ^ {11{bin_temperature[11]}}) + {10'b0, bin_temperature[11]};

    reg prev_EoConvert;

    always @(posedge clk)
    begin
        if(F1M)
        begin
            if (load_en)
            begin
                cn_bin <= u_bin_temperature[10:4];
                cn_dec[15:4] <= 0;
                EoConvert <= 0;
                case (u_bin_temperature[3:0])
                    4'b0000: cn_dec[3:0] = 4'd0;
                    4'b0001: cn_dec[3:0] = 4'd1;
                    4'b0010: cn_dec[3:0] = 4'd1;
                    4'b0011: cn_dec[3:0] = 4'd2;
                    4'b0100: cn_dec[3:0] = 4'd3;
                    4'b0101: cn_dec[3:0] = 4'd3;
                    4'b0110: cn_dec[3:0] = 4'd4;
                    4'b0111: cn_dec[3:0] = 4'd4;
                    4'b1000: cn_dec[3:0] = 4'd5;
                    4'b1001: cn_dec[3:0] = 4'd6;
                    4'b1010: cn_dec[3:0] = 4'd6;
                    4'b1011: cn_dec[3:0] = 4'd7;
                    4'b1100: cn_dec[3:0] = 4'd8;
                    4'b1101: cn_dec[3:0] = 4'd8;
                    4'b1110: cn_dec[3:0] = 4'd9;
                    4'b1111: cn_dec[3:0] = 4'd9;
                endcase
            end
            else
            begin
                if (cn_bin != 0)
                begin
                    cn_bin <= cn_bin - 1'b1;
                    cn_dec[7:4] <= (cn_dec[7:4] != 4'b1001) ? cn_dec[7:4] + 4'b0001 : 0;
                    cn_dec[11:8] <= ((cn_dec[7:4] == 4'b1001) & (cn_dec[11:8] == 4'b1001)) ? 0                   :
                                    (cn_dec[7:4] == 4'b1001)                               ? cn_dec[11:8] + 1'b1 : cn_dec[11:8];
                    cn_dec[15:12] <= ((cn_dec[7:4] == 4'b1001) & (cn_dec[11:8] == 4'b1001)) ? cn_dec[15:12] + 1'b1 : cn_dec[15:12];
                end
                else
                begin
                    EoConvert <= 1'b1;
                    dec_temperature <= cn_dec;
                end
            end
        end
    end

    always @(posedge clk)
    begin
        if (F1M)
        begin
            prev_EoConvert <= EoConvert;
        end
    end

    assign load_en = convert_en & EoConvert;
    assign pos_front_EoConvert = ~prev_EoConvert & EoConvert;
    //assign dec_temperature = (EoConvert) ? cn_dec : dec_temperature;

endmodule


/*module bin_dec_counter #(parameter NoDigits = 4) (
    input clk,
    input [6:0]cn_bin,
    output [11:0]cn_dec
    );

    integer i;
    reg [3:0]digits[NoDigits-1:0];
    reg carry[NoDigits-1:0] = 0;

    always @(posedge clk)
    begin
        carry[0] <= (digits[0] == 4'b1001);
        digits[0] <= (digits[0] == 4'b1001) ? 0 : digits[0] + 1'b1;
        cn_bin <= cn_bin - 1'b1;
        for (i = 1; i < NoDigits; i = i + 1)
        begin
            carry[i] <= carry[i - 1] & (digits[i] == 4'b1001);
            digits[i] <= (digits[i] == 4'b1001 & carry[i - 1]) ? 0                :
                         (carry[i - 1])                        ? digits[i] + 1'b1 : digits[i];
        end
    end

endmodule*/
