#ifndef _TESTBENCH_HH_
#define _TESTBENCH_HH_

#include <algorithm>
#include <cmath>
#include <vector>
#include <verilated_vcd_c.h>

class Clock
{
public:
	/**
	 * Specify the clock's period and phase offset in ns. These
	 * are stored with ps precision. So anything past 3 decimal
	 * places are discarded.
	 */
	Clock(double period, double phase = 0)
		: per_((unsigned long)(1e3 * period)), phi_((unsigned long)(1e3 * phase))
	{
	}

	unsigned long next_edge(unsigned long t_now)
	{
		unsigned long per_2 = (double)this->per_ / 2.0f;
		unsigned long t_inc = per_2 - ((t_now + this->phi_) % per_2);
		if (t_inc == 0)
			t_inc = per_2;
		return t_now + t_inc;
	}

	bool current_val(unsigned long t_now)
	{
		unsigned long per_2 = (double)this->per_ / 2.0f;
		double intoT = (t_now + this->phi_) % this->per_;
		if (intoT < per_2)
			return 0;
		else
			return 1;
	}

	bool posedge(unsigned long t_now)
	{
		unsigned long per_2 = (double)this->per_ / 2.0f;
		double intoT = (t_now + this->phi_) % this->per_;
		return intoT == per_2;
	}

	bool negedge(unsigned long t_now)
	{
		double intoT = (t_now + this->phi_) % this->per_;
		return intoT == 0;
	}

	/**
	 * Change the clock's phase so it's first positive edge occurs
	 * at time t (ps).
	 */
	void align_edge(unsigned long t)
	{
		unsigned long per_2 = (double)this->per_ / 2.0f;
		this->phi_ = per_2 - t;
	}

private:
	// both in ps
	unsigned long per_;
	unsigned long phi_;
};

template <typename Module>
class Testbench
{
public:
	explicit Testbench(std::vector<Clock> clocks, unsigned long max_t = 10000,
			   int trace_depth = 99)
		: clocks_(clocks), mod_(new Module), max_t_(1000 * max_t),
		  trace_depth_(trace_depth), t_(0l)
	{
		// enable waveform tracing
		Verilated::traceEverOn(true);
	}

	virtual ~Testbench()
	{
		this->closetrace();
		delete this->mod_;
		this->mod_ = nullptr;
	}

	virtual void opentrace(const char *vcdfname)
	{
		if (!this->trace_) {
			this->trace_ = new VerilatedVcdC;
			this->trace_->spTrace()->set_time_unit("1ps");
			this->trace_->spTrace()->set_time_resolution("1ps");
			this->mod_->trace(trace_, 99);
			this->trace_->open(vcdfname);
		}
	}

	virtual void closetrace()
	{
		if (this->trace_) {
			this->trace_->close();
			this->trace_ = nullptr;
		}
	}

	/**
	 * Align the first positive edge of all clocks. This uses the
	 * first clock passed in the initializer as the reference
	 * point.
	 */
	void align_clocks()
	{
		unsigned long first_edge = this->clocks_.begin()->next_edge(0);
		for (auto &clock : this->clocks_) {
			clock.align_edge(first_edge);
		}
	}

	/**
	 * Retrieve time of next clock edge.
	 */
	virtual unsigned long clock_inc()
	{
		unsigned long t = this->max_t_;
		for (auto clk : clocks_) {
			unsigned long edge = clk.next_edge(this->t_);
			if (edge < t)
				t = edge;
		}
		return t;
	}

	virtual void initialize_ports() = 0;

	virtual void set_rst_port(bool new_val) = 0;

	virtual void reset()
	{
		this->set_rst_port(0);
		this->mod_->eval();
		if (this->trace_)
			this->trace_->dump(t_);
		// ensure all clocks register the reset.
		std::vector<unsigned long> edges(2 * this->clocks_.size(), 0);
		auto edge_it = edges.begin();
		for (auto it = this->clocks_.begin(); it < this->clocks_.end(); ++it) {
			auto val = it->next_edge(this->t_);
			*edge_it++ = val;
			*edge_it++ = it->next_edge(val);
		}
		unsigned long max_edge = *std::max_element(edges.begin(), edges.end());
		while (this->t_ <= max_edge)
			this->tick();

		this->set_rst_port(1);
		this->mod_->eval();
		if (this->trace_)
			this->trace_->dump(t_);
	}

	virtual void tick()
	{
		this->t_ = this->clock_inc();
		this->mod_->eval();
		this->update_ports(this->t_);
		this->mod_->eval();
		if (this->trace_)
			this->trace_->dump(t_);
		this->print_status(this->t_);
	}

	virtual void update_ports(unsigned long t_now) = 0;

	virtual void print_status(unsigned long t_now) = 0;

	virtual bool done() { return this->t_ >= this->max_t_; }

protected:
	Module *mod_;
	std::vector<Clock> clocks_;
	// current simulation time (ps)
	unsigned long t_;
	// terminating simulation time (ps)
	unsigned long max_t_;
	int trace_depth_;
	VerilatedVcdC *trace_;
};

#endif
