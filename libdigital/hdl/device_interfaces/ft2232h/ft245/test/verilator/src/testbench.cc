#include <Vft245_wrapper.h>
#include <cstdio>
#include <cstdlib>
#include <testbench.hh>
#include <verilated.h>

template <typename Module>
class Ft245 : public Testbench<Module>
{
public:
	Ft245(std::vector<Clock> clocks, long max_t) : Testbench<Module>(clocks, max_t)
	{
		this->initialize_ports();
		this->mod_->eval();
	}

	void initialize_ports()
	{
		this->mod_->tb_rst_n = 0;
		this->mod_->tb_ftclk = 0;
		this->mod_->tb_slow_ftclk = 0;
		this->mod_->clk_40mhz = 0;
		this->mod_->wren = 0;
		this->mod_->wrdata = 0;
		this->mod_->rden = 0;
		this->mod_->usb_data = 0;
		this->mod_->usb_wr = 0;
		this->mod_->usb_rd = 0;
	}

	void set_rst_port(bool new_val) { this->mod_->tb_rst_n = new_val; }

	void print_status(long t_now){};

	void update_ports(long t_now)
	{
		// clocks
		this->mod_->tb_ftclk = this->clocks_[0].current_val(t_now);
		this->mod_->tb_slow_ftclk = this->clocks_[1].current_val(t_now);
		this->mod_->clk_40mhz = this->clocks_[2].current_val(t_now);
		if (this->mod_->tb_rst_n) {
			// FPGA/ASIC
			if (!this->mod_->wrfifo_full) {
				this->mod_->wren = 1;
				++this->mod_->wrdata;
			}
			this->mod_->rden = 0;
			// host PC
			this->mod_->usb_wr = 0;
			this->mod_->usb_rd = 1;
		}
	}
};

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);
	std::vector<Clock> clocks = {Clock(60), Clock(7.5), Clock(40)};
	Ft245<Vft245_wrapper> *tb = new Ft245<Vft245_wrapper>(clocks, 1000000);
	tb->align_clocks();
	tb->opentrace("ft245.vcd");
	// power-on reset
	tb->reset();
	while (!tb->done()) {
		tb->tick();
	}
	std::exit(EXIT_SUCCESS);
}
