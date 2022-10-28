/*
 * IIC_DSMOD -- Delta-Sigma Modulator (1st/2nd Order) with Single-Bit Output
 *
 * (c) 2021-2022 Harald Pretl (harald.pretl@jku.at)
 * Johannes Kepler University Linz, Institute for Integrated Circuits
 *
 * Ports:
 *		data_i			... input data (must be UINT, default 16b)
 *		data_rd_o		... fetch next input data word (data feed-in driven 
 *							by DS-modulator)
 *		ds_o, ds_n_o	... output bitstream (complimentary outputs)
 *
 *		rst_n_i			... reset (low active)
 *		clk_i			... clock of ds-modulator (must be OSR * input_data_rate),
 *							output bitstream rate = OSR * input_data_rate
 *
 *		mode_i			... select order of modulator (0 = 1st, 1 = 2nd)
 *		scale_i			... scaling (attenuation) of input data in -6dB steps
 *							(0 = 0dB, 1 = -6dB, 2 = -12dB, ..., 15 = off)
 *		osr_i			... oversampling ratio (OSR), 0=32/1=64/2=128/3=256 is supported
 */

`default_nettype none
`ifndef __IIC_DSMOD__
`define __IIC_DSMOD__

module iic_dsmod (
	input 		[15:0]		data_i,
	output wire				data_rd_o,
	output reg				ds_o,
	output wire				ds_n_o,
	
	input					rst_n_i,
	input					clk_i,
	
	input					mode_i,
	input 		[3:0]		scale_i,
	input		[1:0]		osr_i
);

	// Your code goes here!

endmodule // iic_dsmod

`endif
`default_nettype wire
