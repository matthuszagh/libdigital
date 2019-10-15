#ifndef _TESTBENCH_HH_
#define _TESTBENCH_HH_

#include <algorithm>
#include <cmath>
#include <vector>
#include <verilated_vcd_c.h>

#define MOD(x, n) (((x) % (n) + (n)) % (n))

/**
 * phase=0 corresponds to a clock spending a half-period at logic 0,
 * followed by a half-period at logic 1 before repeating. Positive
 * phase means translating the clock signal backward in time.
 *
 * Example:
 * phase=0
 * __/--\__/--
 *
 * phase=+(1/4)T
 * _/--\__/--\
 */
class Clock
{
public:
	Clock(double freq, long phase = 0l) : freq_(freq), phase_(phase) {}
	// get period in ps
	long period() { return 1e6 / freq_; }
	long next_edge(long t_now)
	{
		long T = this->period();
		long T_2 = std::round((double)T / 2);
		long t_inc = T_2 - MOD(t_now + this->phase_, T_2);
		if (t_inc == 0)
			t_inc = T_2;
		return t_now + t_inc;
	}
	bool current_val(long t_now)
	{
		long T = this->period();
		long T_2 = std::round((double)T / 2);
		long intoT = MOD(t_now + this->phase_, T);
		if (intoT < T_2)
			return 0;
		else
			return 1;
	}

	/**
	 * Change the clock's phase so it's first positive edge occurs
	 * at time t (ps).
	 */
	void align_edge(long t)
	{
		long T_2 = std::round((double)this->period() / 2);
		this->phase_ = T_2 - t;
	}
	// void align_edge(long t) { this->phase_ = t; }

private:
	double freq_; // in MHz
	long phase_;  // in ps
};

template <typename Module>
class Testbench
{
public:
	explicit Testbench(std::vector<Clock> clocks, long max_t = 10000, int trace_depth = 99)
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
		long first_edge = this->clocks_.begin()->next_edge(0);
		for (auto &clock : this->clocks_) {
			clock.align_edge(first_edge);
		}
	}

	/**
	 * Retrieve time of next clock edge.
	 */
	virtual long clock_inc()
	{
		long t = this->max_t_;
		for (auto clk : clocks_) {
			long edge = clk.next_edge(this->t_);
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
			this->trace_->dump((unsigned long)t_);
		// ensure all clocks register the reset.
		std::vector<long> edges(2 * this->clocks_.size(), 0l);
		auto edge_it = edges.begin();
		for (auto it = this->clocks_.begin(); it < this->clocks_.end(); ++it) {
			auto val = it->next_edge(this->t_);
			*edge_it++ = val;
			*edge_it++ = 2 * val;
		}
		long max_edge = *std::max_element(edges.begin(), edges.end());
		while (this->t_ <= max_edge)
			this->tick();

		this->set_rst_port(1);
		this->mod_->eval();
		if (this->trace_)
			this->trace_->dump((unsigned long)t_);
	}

	virtual void tick()
	{
		this->t_ = this->clock_inc();
		this->mod_->eval();
		this->update_ports(this->t_);
		this->mod_->eval();
		if (this->trace_)
			this->trace_->dump((unsigned long)t_);
		this->print_status(this->t_);
	}

	virtual void update_ports(long t_now) = 0;

	virtual void print_status(long t_now) = 0;

	virtual bool done() { return this->t_ >= this->max_t_; }

protected:
	Module *mod_;
	std::vector<Clock> clocks_;
	// current simulation time (ps)
	long t_;
	// terminating simulation time (ps)
	long max_t_;
	int trace_depth_;
	VerilatedVcdC *trace_;
};

#endif
