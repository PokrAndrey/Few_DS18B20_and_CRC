module PON (
    input clk,
    input F1M,
    output wire pon
    );

    reg reg_first = 0;
    reg reg_second = 0;
    always @(posedge clk)
    begin
        if (F1M)
        begin
        reg_first <= 1'b1;
        reg_second <= ~reg_first;
        end
    end
    assign pon = reg_second;

endmodule
    
