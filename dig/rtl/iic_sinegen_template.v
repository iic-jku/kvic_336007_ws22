/*
 * IIC_SINEGEN -- Simple Sine Generator based on a harcoded 16b LUT
 *
 * (c) 2021-2022 Harald Pretl and Jakob Ratschenberger (harald.pretl@jku.at)
 * Johannes Kepler University Linz, Institute for Integrated Circuits
 *
 * Ports:
 *		data_o				... output data of sine generator (BW)
 *		data_rd_i			... advances the generator to the next output value,
 *								controlled by the step size
 *
 *		rst_n_i				... reset (low active)
 *		clk_i				... clock of sine generator (pos. edge)
 *
 *		tst_sinegen_en_i	... enables the sine generator; when disabled then 0 is
 *								output, and the generator is turned off
 *		tst_sinegen_step_i	... controls the step size per read (1 = use every ROM
 *								value, 2 = use every 2nd ROM entry, etc); the higher the
 *								step value, the faster the output sine
 */

`default_nettype none
`ifndef __IIC_SINEGEN__
`define __IIC_SINEGEN__

module iic_sinegen (
	output wire	signed [15:0]	data_o,
	input						data_rd_i,
	input						rst_n_i,
	input						clk_i,

	input						tst_sinegen_en_i,
	input [3:0]					tst_sinegen_step_i
);
	
	// Your code goes here!

endmodule // iic_sinegen

`endif
`default_nettype wire
