/*
 * AUDIODAC TESTBENCH -- 16b Delta-Sigma Modulator with Single-Bit Output
 *
 * (c) 2021-2022 Harald Pretl (harald.pretl@jku.at)
 * Johannes Kepler University Linz, Institute for Integrated Circuits
 *
 * This is the testbench for audiodac.v
 */

`timescale 10ns / 1ns

`include "../rtl/audiodac.v"

`ifndef SIM_LONG
	`ifndef SIM_SHORT
		`define SIM_SHORT
	`endif
`endif

module audiodac_tb;

	localparam SIM_MODE = 2;
	localparam SIM_OSR = 2;
	localparam SIM_VOLUME = 15;

	// housekeeping for getting data in
	`ifdef SIM_LONG
		localparam DATA_SAMPLES = 44100*10;
	`endif
	`ifdef SIM_SHORT
		localparam DATA_SAMPLES = 44100*1;
	`endif

	reg 	[15:0]	DATA_IN[0:DATA_SAMPLES-1]; // large memory to hold the audio
	reg 			DATA_OUT[0:(DATA_SAMPLES*(32*2^SIM_OSR)-1)]; // output results written to file
	integer 		DATA_IN_CTR = 0;
	integer 		DATA_OUT_CTR = 0;

	// configuration bits
	reg 			MODE = SIM_MODE;
	reg 	[1:0] 	OSR = SIM_OSR;
	reg 	[3:0] 	VOLUME = SIM_VOLUME;

	// inputs
	reg 			RESET_N = 1'b0;
	reg 			CLK = 1'b0;
	reg				TST_FIFO_LOOP = 1'b0;
	reg				TST_SINEGEN_EN = 1'b0;
	reg		[4:0]	TST_SINEGEN_STEP = 5'd2;

    // outputs
	wire 				FIFO_FULL, FIFO_EMPTY, FIFO_ACK, DS_OUT, DS_OUT_N;

	// instantiate DUT
	audiodac dac (
		.fifo_i(DATA),
		.fifo_rdy_i(DATA_RDY),
		.fifo_ack_o(FIFO_ACK),
		.fifo_full_o(FIFO_FULL),
		.fifo_empty_o(FIFO_EMPTY),
    	.rst_n_i(RESET_N),
		.clk_i(CLK),
		.mode_i(MODE),
		.volume_i(VOLUME),
    	.osr_i(OSR),
    	.ds_o(DS_OUT),
    	.ds_n_o(DS_OUT_N),
		.tst_fifo_loop_i(TST_FIFO_LOOP),
		.tst_sinegen_en_i(TST_SINEGEN_EN),
		.tst_sinegen_step_i(TST_SINEGEN_STEP)
        );

	
	// make a clock
	always #1 CLK = ~CLK;

	// handle FIFO input data
	reg [15:0] DATA = 16'b0;
	reg DATA_RDY = 1'b0;
	reg WAIT_FOR_EMPTY = 1'b0; // flag to signal a wait for the next write burst

	always @(negedge CLK) begin
		
		// provide input data
		if (!DATA_RDY && !FIFO_FULL && !FIFO_ACK && !WAIT_FOR_EMPTY && RESET_N) begin
			// option 1: just use a simple counter as data
			//#1 DATA <= DATA + 1;
			
			// option 2: use data from file
			DATA <= DATA_IN[DATA_IN_CTR];
			DATA_IN_CTR = DATA_IN_CTR + 1;

			// signal to FIFO that data is ready
			DATA_RDY <= 1'b1;

			// no more input data left? write result and exit
			if (DATA_IN_CTR == DATA_SAMPLES) begin
				$writememh("verilog_bin_out.txt", DATA_OUT);
				$finish;
			end
		end

		// de-assert data_rdy when data transfer ack'd by FIFO
		if (FIFO_ACK) DATA_RDY <= 1'b0;

		// The FIFO data write-in is done in a bursty nature, like a
		// host system would likely do. When the FIFO is empty we write
		// until the FIFO is full, then we wait for the FIFO to get
		// empty again--then we do another bursty data transfer. This
		// is meant to put less burden on the host system, so just an
		// interrupt service routine is required, no constant polling
		// of the data_rdy line, instead fifo_empty can trigger the ISR.

		// stall data write-in when FIFO is already full
		if (FIFO_FULL) WAIT_FOR_EMPTY <= 1'b1;

		// if FIFO is empty re-engage with data write-in
		if (FIFO_EMPTY) WAIT_FOR_EMPTY <= 1'b0;

		// store simulation result into memory for later dump
		if (RESET_N) begin
			DATA_OUT[DATA_OUT_CTR] <= DS_OUT;
			DATA_OUT_CTR = DATA_OUT_CTR + 1;
		end
	end

	// here is all the initiliaztion work for the simulation
	initial begin
		// print out simulation state
		$display("------------------------------");
		`ifdef SIM_SHORT
			$display("Running short (1s) simulation.");
		`elsif SIM_LONG
			$display("Running long (10s) simulation.");
		`endif
		$display("------------------------------");
		$display("SIM MODE   = ", SIM_MODE);
		$display("SIM_OSR    = ", SIM_OSR);
		$display("SIM_VOLUME = ", SIM_VOLUME);
		$display("------------------------------");

		// read in the testdata into the memory
		`ifdef SIM_LONG
			$readmemh("../../ver/verilog_testaudio_10s.txt", DATA_IN);
		`elsif SIM_SHORT
			$readmemh("../../ver/verilog_testaudio_1s.txt", DATA_IN);
		`endif

		// dump signals into VCD for debug
		`ifdef SIM_SHORT
			$dumpfile("audiodac_tb.vcd");
			$dumpvars;
		`endif

		// de-assert reset
		#5 RESET_N = 1'b1;

		// provide an online output for tracking sim progress
     	//$monitor("At time %t, ds_out = %h", $time, DS_OUT);
	end

endmodule // audiodac_tb
