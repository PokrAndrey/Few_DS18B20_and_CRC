module top_level (
    input local_clk,
    input local_signal,
    input [2/*log(Num_of_Dev)*/:0]SW,
    output wire OE_to_tri,
    output wire [6:0]first_segment, 
    output wire [6:0]second_segment,
    output wire [6:0]third_segment,
    output wire [6:0]fourth_segment,
	output wire local_presense

    );


    wire local_F1M;
    wire [9:0]local_state;
    wire [7:0]local_byte;
    wire [7:0]local_in_byte;
    wire local_EoB;
    wire local_pon; 
    wire [7:0]local_one_byte_of_address;
    wire local_change_state;
    wire [2/*log(Num_of_Dev)*/:0]local_device;


    TB  TB (.clk(local_clk),  .EoB(local_EoB), .F1M(local_F1M), .byte(local_byte), .in_byte(local_in_byte), .state(local_state), .pon(local_pon), .signal(local_signal), .OE_to_tri(OE_to_tri), .presense(local_presense), .change_state(local_change_state));

    data data (.clk(local_clk), .EoB(local_EoB), .F1M(local_F1M), .byte(local_byte), .state(local_state), .first_segment(first_segment), .second_segment(second_segment), .third_segment(third_segment), .fourth_segment(fourth_segment), .choosing_device_for_seg(SW), .device(local_device));

    PON PON (.clk(local_clk), .F1M(local_F1M), .pon(local_pon));

    clk_div clk_div (.clk(local_clk), .F1M(local_F1M));

    SM SM (.command(local_in_byte), .state(local_state), .one_byte_of_address(local_one_byte_of_address));

    address_of_device address_of_device (.state(local_state), .one_byte_of_address(local_one_byte_of_address), .change_state(local_change_state), .EoB(local_EoB), .F1M(local_F1M), .clk(local_clk), .device(local_device));

    


endmodule
