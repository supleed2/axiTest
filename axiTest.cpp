// C++ Verilator testbench for checking AXI4-Lite Driver module
// SPDX-FileCopyrightText: © 2022 Aadi Desai <21363892+supleed2@users.noreply.github.com>
// SPDX-License-Identifier: Apache-2.0

#include <VaxiTest.h>
#include <VaxiTest__Dpi.h>
#include <VerilatorTbFst.h>
#include <iostream>
#include <stdlib.h>
#include <string>
#include <svdpi.h>
#include <verilated.h>

#ifndef N_CYCLES
#define N_CYCLES 100
#endif

int main(int argc, char **argv, char **env) {
	Verilated::commandArgs(argc, argv);
	VerilatorTbFst<VaxiTest> *tb = new VerilatorTbFst<VaxiTest>();
	tb->setScope("axiTest");

	// Get SystemVerilog Parameters
	const uint64_t CLOCK_PERIOD_PS = 10;

	tb->setClockPeriodPS(2 * (CLOCK_PERIOD_PS / 3));
	tb->opentrace("output/VaxiTest.fst");

	tb->m_trace->dump(0); // Initialize waveform at beginning of time.
	printf("Starting!\n");

	tb->m_dut->i_rst = 1;
	tb->ticks(2);
	tb->m_dut->i_rst = 0;
	tb->ticks(2);

	while (tb->tickcount() < N_CYCLES * 2) {
		tb->ticks(2); // Run Tests
	}

	printf("Time: %ldns\n", tb->tickcount());
	printf("Stopped.\n");

	tb->closetrace();
	exit(EXIT_SUCCESS);
}