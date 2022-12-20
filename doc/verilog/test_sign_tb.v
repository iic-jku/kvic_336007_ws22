/*
	Simple testbench for sign operations.
*/

`timescale 1ns / 1ns


module test_sign_tb;

	// inputs
	reg signed [3:0] reg1 = 0;
	reg signed [3:0] reg2 = -7;
	reg signed [3:0] reg3 = 7;
	reg [3:0] reg2_1;
	reg [3:0] reg3_1;

	initial begin
		$display("reg1 = %b", reg1);
		$display("reg2 = %b", reg2);
		$display("reg3 = %b", reg3);		
	
		reg2_1 = $unsigned(reg2);
		$display("reg2_1 = %b", reg2_1);

		reg3_1 = $unsigned(reg3);
		$display("reg3_1 = %b", reg3_1);	
	end

endmodule // test_sign_tb
