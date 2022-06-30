	// <data_out> may feed an inout pin
module top (
	inout out_tri,
	input OE_to_tri
	);
	OPNDRN OD_tri (.in(OE_to_tri), .out(out_tri));
endmodule 