#ifndef _TESTBENCH_HH_
#define _TESTBENCH_HH_

#include <algorithm>
#include <cmath>
#include <vector>
#include <verilated_vcd_c.h>

double fmodp(double x, double n) { return std::fmod((std::fmod(x, n) + n), n); }

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
	Clock(double freq, double phase = 0l) : freq_(freq), phase_(phase) {}
	// get period in ps
	double period() { return 1e6 / freq_; }
	double next_edge(double t_now)
	{
		double T = this->period();
		double T_2 = T / 2;
		double t_inc = std::round(T_2 - fmodp(t_now + this->phase_, T_2));
		if (t_inc == 0)
			t_inc = std::round(T_2);
		return t_now + t_inc;
	}
	bool current_val(double t_now)
	{
		double T = this->period();
		double T_2 = std::round(T / 2);
		double intoT = std::round(fmodp(t_now + this->phase_, 2 * T_2));
		if (intoT < T_2)
			return 0;
		else
			return 1;
	}

	/**
	 * Change the clock's phase so it's first positive edge occurs
	 * at time t (ps).
	 */
	void align_edge(double t)
	{
		double T_2 = std::round(this->period() / 2);
		this->phase_ = T_2 - t;
	}

private:
	double freq_;  // in MHz
	double phase_; // in ps
};

template <typename Module>
class Testbench
{
public:
	explicit Testbench(std::vector<Clock> clocks, double max_t = 10000, int trace_depth = 99)
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
		double first_edge = this->clocks_.begin()->next_edge(0);
		for (auto &clock : this->clocks_) {
			clock.align_edge(first_edge);
		}
	}

	/**
	 * Retrieve time of next clock edge.
	 */
	virtual double clock_inc()
	{
		double t = this->max_t_;
		for (auto clk : clocks_) {
			double edge = clk.next_edge(this->t_);
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
		std::vector<double> edges(2 * this->clocks_.size(), 0);
		auto edge_it = edges.begin();
		for (auto it = this->clocks_.begin(); it < this->clocks_.end(); ++it) {
			auto val = it->next_edge(this->t_);
			*edge_it++ = val;
			*edge_it++ = it->next_edge(val);
		}
		double max_edge = *std::max_element(edges.begin(), edges.end());
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

	virtual void update_ports(double t_now) = 0;

	virtual void print_status(double t_now) = 0;

	virtual bool done() { return this->t_ >= this->max_t_; }

protected:
	Module *mod_;
	std::vector<Clock> clocks_;
	// current simulation time (ps)
	double t_;
	// terminating simulation time (ps)
	double max_t_;
	int trace_depth_;
	VerilatedVcdC *trace_;
};

#endif
