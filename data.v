module data  #(parameter Num_of_Dev = 4)(
    input [7:0]byte,
    input clk,
    input [9:0]state,
    input F1M,
    input EoB,
    input [2/*log(Num_of_Dev)*/:0]device,
    input [2/*log(Num_of_Dev)*/:0]choosing_device_for_seg,
    output wire [6:0]first_segment, 
    output wire [6:0]second_segment,
    output wire [6:0]third_segment,
    output wire [6:0]fourth_segment 
    );
 
    assign first_segment  = segments[0] | {7{mask_seg}};
    assign second_segment = segments[1] | {7{mask_seg}};
    assign third_segment  = segments[2] | {7{mask_seg}};
    assign fourth_segment = segments[3] | {7{mask_seg}};
    wire mask_seg = mass_en_show[choosing_device_for_seg] ? Blink : 0;

    reg [15:0]bin_temperature[Num_of_Dev-1:0];
    reg [7:0]TH[Num_of_Dev-1:0];
    reg [7:0]TL[Num_of_Dev-1:0];
    reg [7:0]configure[Num_of_Dev-1:0];
    reg [6:0]segments[3:0];
    reg [7:0]CRC[Num_of_Dev-1:0]; 
    reg [2/*log(Num_of_Dev)*/:0]convert_en;
    wire oneWireConvertEn;
    wire [15:0]dec_temperature;
    reg [7:0]reserve1;
    reg [7:0]reserve2;
    reg [7:0]reserve3;
    wire [4:0]prev_srate = state - 5'b1;
    wire [6:0]sign = {7{bin_temperature[choosing_device_for_seg][15]}};

    reg [15:0]mass_dec_temperature[2/*log(Num_of_Dev)*/:0];
    wire EndOfConvert;

    wire check_sum = F1M & (prev_srate == 5'd21) & EoB;

    wire en_show;
    reg [2/*log(Num_of_Dev)*/:0]mass_en_show = 0;
    wire we_en_show;

    reg [9:0]counterTimeOfBlink;
    wire Blink = counterTimeOfBlink[9];


    bin_to_dec bin_to_dec (.bin_temperature(bin_temperature[device]), .dec_temperature(dec_temperature), .convert_en(oneWireConvertEn), .clk(clk), .F1M(F1M), .pos_front_EoConvert(EndOfConvert));

    CRC_mod CRC_mod (.en_conv(oneWireConvertEn), 
                    .check_sum(check_sum), 
                    .en_show(en_show),
                    .we(we_en_show),
                    .F1M(F1M),
                    .clk(clk),
                    .bytes_of_mem({CRC[device], reserve3, reserve2, reserve1, configure[device], TL[device], TH[device], bin_temperature[device]}));


    always @(posedge clk)
    begin
        if (F1M)
        begin
            mass_dec_temperature[device] <= (EndOfConvert) ? dec_temperature : mass_dec_temperature[device];
            mass_en_show[device] <= (we_en_show)? en_show : mass_en_show[device];
        end
    end

    always @(posedge clk)
    begin
        if (F1M & EoB)
        begin
            counterTimeOfBlink <= counterTimeOfBlink + 1;
            
        end
    end

    
    always @(posedge clk)
    begin
        if (F1M & EoB)
        begin
            case (prev_srate)
                10'd12: bin_temperature[device][7:0] = byte;
                10'd13: bin_temperature[device][15:8] = byte;
                10'd14: TH[device] = byte;
                10'd15: TL[device] = byte;
                10'd16: configure[device] = byte;
                10'd17: reserve1 = byte;
                10'd18: reserve2 = byte;
                10'd19: reserve3 = byte;
                10'd20: CRC[device] = byte;
            endcase
        end        
    end

    always @(*) 
    begin
        case (mass_dec_temperature[choosing_device_for_seg][7:4])/* abcdefg */
            4'h0: segments[1] =    7'b1000000;
            4'h1: segments[1] =    7'b1111001;
            4'h2: segments[1] =    7'b0100100;
            4'h3: segments[1] =    7'b0110000;
            4'h4: segments[1] =    7'b0011001;
            4'h5: segments[1] =    7'b0010010;
            4'h6: segments[1] =    7'b0000010;
            4'h7: segments[1] =    7'b1111000;
            4'h8: segments[1] =    7'b0000000;
            4'h9: segments[1] =    7'b0010000;
            //4'ha: segments = 7'b0001000;
            //4'hb: segments = 7'b0000011;
            //4'hc: segments = 7'b1000110;
            //4'hd: segments = 7'b0100001;
            //4'he: segments = 7'b0000011;
            //4'hF: segments = 7'b0001110;
            default: segments[1] = 7'b1111111;
        endcase
    end

    always @(*) 
    begin
        case (mass_dec_temperature[choosing_device_for_seg][11:8])/* abcdefg */
            4'h0: segments[2] =    7'b1000000;
            4'h1: segments[2] =    7'b1111001;
            4'h2: segments[2] =    7'b0100100;
            4'h3: segments[2] =    7'b0110000;
            4'h4: segments[2] =    7'b0011001;
            4'h5: segments[2] =    7'b0010010;
            4'h6: segments[2] =    7'b0000010;
            4'h7: segments[2] =    7'b1111000;
            4'h8: segments[2] =    7'b0000000;
            4'h9: segments[2] =    7'b0010000;
            //4'ha: segments = 7'b0001000;
            //4'hb: segments = 7'b0000011;
            //4'hc: segments = 7'b1000110;
            //4'hd: segments = 7'b0100001;
            //4'he: segments = 7'b0000011;
            //4'hF: segments = 7'b0001110;
            default: segments[2] = 7'b1111111;
        endcase
    end

    always @(*) 
    begin
        case (mass_dec_temperature[choosing_device_for_seg][15:12])/* abcdefg */
            4'h0: segments[3] =    7'b1000000 ^ (sign & {7{~mass_en_show[choosing_device_for_seg]}});//отображение знака температуры
            4'h1: segments[3] =    7'b1111001;
            4'h2: segments[3] =    7'b0100100;
            4'h3: segments[3] =    7'b0110000;
            4'h4: segments[3] =    7'b0011001;
            4'h5: segments[3] =    7'b0010010;
            4'h6: segments[3] =    7'b0000010;
            4'h7: segments[3] =    7'b1111000;
            4'h8: segments[3] =    7'b0000000;
            4'h9: segments[3] =    7'b0010000;
            //4'ha: segments = 7'b0001000;
            //4'hb: segments = 7'b0000011;
            //4'hc: segments = 7'b1000110;
            //4'hd: segments = 7'b0100001;
            //4'he: segments = 7'b0000011;
            //4'hF: segments = 7'b0001110;
            default: segments[3] = 7'b1111111;
        endcase
    end

    always @(*) 
    begin
        case (mass_dec_temperature[choosing_device_for_seg][3:0])/* abcdefg */
            4'h0: segments[0] =    7'b1000000;
            4'h1: segments[0] =    7'b1111001;
            4'h2: segments[0] =    7'b0100100;
            4'h3: segments[0] =    7'b0110000;
            4'h4: segments[0] =    7'b0011001;
            4'h5: segments[0] =    7'b0010010;
            4'h6: segments[0] =    7'b0000010;
            4'h7: segments[0] =    7'b1111000;
            4'h8: segments[0] =    7'b0000000;
            4'h9: segments[0] =    7'b0010000;
            //4'ha: segments = 7'b0001000;
            //4'hb: segments = 7'b0000011;
            //4'hc: segments = 7'b1000110;
            //4'hd: segments = 7'b0100001;
            //4'he: segments = 7'b0000011;
            //4'hF: segments = 7'b0001110;
            default: segments[0] = 7'b1111111;
        endcase
    end

endmodule
    
