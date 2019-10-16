#include "Vasync_fifo.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <cstdio>
#include <cstdlib>

vluint64_t main_time = 0;

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	VerilatedVcdC *tfp = new VerilatedVcdC;
	Vasync_fifo *async_fifo = new Vasync_fifo;
	async_fifo->trace(tfp, 99);
	tfp->open("obj_dir/async_fifo.vcd");
	while (main_time < 20000) {
		// std::printf("%5d: %d\n", main_time, async_fifo->rst_n);

		async_fifo->rst_n = (main_time < 10) ? 0 : 1;
		if (main_time % 3 == 0)
			async_fifo->wrclk = !async_fifo->wrclk;
		if (main_time % 5 == 0)
			async_fifo->rdclk = !async_fifo->rdclk;
		if (main_time % 500 == 0)
			async_fifo->rden = !async_fifo->rden;
		if (main_time == 0)
			async_fifo->wren = 1;
		if (main_time == 10000)
			async_fifo->wren = 0;
		if (async_fifo->wren && async_fifo->rst_n)
			++async_fifo->wrdata;

		tfp->dump(main_time);
		async_fifo->eval();
		++main_time;
	}
	delete async_fifo;
	tfp->close();
	delete tfp;
	std::exit(0);
}
