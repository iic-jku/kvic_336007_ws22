/*
 * IIC_FIFO -- Configurable FIFO based on ring-buffer
 *
 * (c) 2021-2022 Harald Pretl (harald.pretl@jku.at)
 * Johannes Kepler University Linz, Institute for Integrated Circuits
 *
 * Ports:
 *		fifo_indata_i		... input data
 *		fifo_indata_rdy_i	... indicates that data is ready from source
 *		fifo_indata_ack_o	... signales to source that datum has been taken into FIFO
 *
 *		fifo_full_o			... indicates a full FIFO, no further datum will be
 *								acknowledged into FIFO
 *		fifo_empty_o		... indicates an empty FIFO, if datum is read from an empty
 *								FIFO then the last datum will be output
 *
 *		fifo_outdata_o		... output data
 *		fifo_outdata_rd_i	... the next output datum is selected (if FIFO is not empty)
 *
 *		rst_n_i				... reset (low active)
 *		clk_i				... clock of FIFO
 *
 *		tst_fifo_loop_i		... enables a test mode where the data in the FIFO is looped
 *								at the output
 */

`default_nettype none
`ifndef __IIC_FIFO__
`define __IIC_FIFO__

module iic_fifo (
	input		[15:0]	fifo_indata_i,
	input				fifo_indata_rdy_i,
	// note that fifo_indata_i and fifo_indata_rdy_i could originate from 
	// an asynchronous clk domain, so potentially needs to be synchronized
	// use FIFO_ASYNC=1 to select the proper behaviour
	output reg			fifo_indata_ack_o,
	output wire			fifo_full_o,
	output wire			fifo_empty_o,
	output wire	[15:0]	fifo_outdata_o,
	input				fifo_outdata_rd_i,
	input				rst_n_i,
	input				clk_i,
	input				tst_fifo_loop_i
);

   // Your code goes here!

endmodule // iic_fifo

`endif
`default_nettype wire
