module address_of_device #(parameter Num_of_Dev = 4)(
    input [9:0]state,
    input EoB,
    input clk,
    input F1M,
    output reg change_state = 0,
    output reg [2/*log(Num_of_Dev)*/:0]device = 0,
    output wire [7:0]one_byte_of_address

);


    wire [63:0]address[Num_of_Dev-1:0];

    /*assign address[0] = 64'haa00000023d19228;//34
    assign address[1] = 64'h220000002410c828;//-
    assign address[2] = 64'had00000023955028;//25
    assign address[3] = 64'h5100000023777e28;//30*/

    assign address[0] = 64'h2892d123000000aa;//34
    assign address[1] = 64'h28c8102400000022;//-
    assign address[2] = 64'h28509523000000ad;//25
    assign address[3] = 64'h287e772300000051;//30


    assign one_byte_of_address = (state == 10) ? address[device][7:0]   :
                                 (state == 9)  ? address[device][15:8]  :
                                 (state == 8)  ? address[device][23:16] :
                                 (state == 7)  ? address[device][31:24] :
                                 (state == 6)  ? address[device][39:32] :
                                 (state == 5)  ? address[device][47:40] :
                                 (state == 4)  ? address[device][55:48] :
                                 (state == 3)  ? address[device][63:56] : 0;//байты адреса датчика, к которому обращаются
    always @(posedge clk)
    begin
        if ((state == 23) & EoB & F1M)
        begin
            device <= (device == Num_of_Dev - 1) ? 0 : device + 1;
        end
    end

 
endmodule
