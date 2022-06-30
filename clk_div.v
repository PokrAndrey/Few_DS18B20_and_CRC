module clk_div #(parameter X = 7)(
    input clk,
    
    output reg F1M
);

    reg [X-1:0]count=0;


    always @(posedge clk) 
    begin
        if ( count == 7'd48)
        begin
            F1M <= 1'b1;
            count <= count + 1'b1;
        end
        else
        begin
            if (count == 7'd49)
                begin
                    F1M <= 1'b0;
                    count <= 0;
                end
            else
            begin
                count <= count + 1'b1;
                F1M <= 1'b0;
            end
        end
    end
endmodule
