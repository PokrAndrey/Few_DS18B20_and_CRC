module CRC_mod (
    input [71:0]bytes_of_mem,
    input check_sum,
    input clk,
    input F1M,
    output reg go_check = 0,
    output reg en_show = 0,
    output reg we,
    output wire en_conv
    );

    reg [7:0]gen_CRC = 0;
    reg [71:0]local_bytes_of_mem = 0;
    wire inM = local_bytes_of_mem[0] ^ gen_CRC[0];
    reg [6:0]counter = 0;   


    always @(posedge clk)
    begin
        if (F1M)
        begin
            if (check_sum)
            begin
                local_bytes_of_mem <= bytes_of_mem;
                go_check <= 1;
            end
            else        
            begin
                if (go_check & (counter < 72))
                begin
                    counter <= counter + 1;
                    gen_CRC <= {inM, gen_CRC[7:5], inM ^ gen_CRC[4], inM ^ gen_CRC[3], gen_CRC[2:1]};  
                    local_bytes_of_mem <= {1'b0, local_bytes_of_mem[71:1]};
                end
                else
                begin
                    counter <= 0;
                    we <= go_check;
                    go_check <= 0;
                    gen_CRC <= 0;
                    en_show <= (go_check) ? ~(gen_CRC == 8'b0) : en_show;
                end
            end
        end
    end

    assign en_conv = (counter == 72) & (gen_CRC == 0) & go_check;

endmodule
