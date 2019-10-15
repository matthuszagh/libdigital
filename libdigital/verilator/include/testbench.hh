#ifndef _TESTBENCH_HH_
#define _TESTBENCH_HH_

#include <algorithm>
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
	Clock(double freq, double phase = 0.0f) : freq_(freq), phase_(phase) {}
	// get period in ps
	unsigned long period() { return 1e6 / freq_; }
	unsigned long next_edge(unsigned long t_now)
	{
		unsigned long T = this->period();
		unsigned long T_2 = T / 2;
		unsigned long t_phase = T * this->phase_;
		unsigned long t_inc = T_2 - MOD(t_now - t_phase, T_2);
		return t_now + t_inc;
	}
	bool current_val(unsigned long t_now)
	{
		unsigned long T = this->period();
		unsigned long t_phase = T * this->phase_;
		unsigned long intoT = MOD(t_now - t_phase, T);
		if (intoT < T / 2)
			return 0;
		else
			return 1;
	}

private:
	double freq_;  // in MHz
	double phase_; // in units of T, where T is the period
};

template <typename Module>
class Testbench
{
public:
	explicit Testbench(std::vector<Clock> clocks, unsigned long max_t = 10000,
			   unsigned int trace_depth = 99)
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
		std::vector<unsigned long> edges(2 * this->clocks_.size(), 0ul);
		auto edge_it = edges.begin();
		for (auto it = this->clocks_.begin(); it < this->clocks_.end(); ++it) {
			auto val = it->next_edge(this->t_);
			*edge_it++ = val;
			*edge_it++ = 2 * val;
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
		this->mod_->eval();
		t_ = this->clock_inc();
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
	unsigned int trace_depth_;
	VerilatedVcdC *trace_;
};

#endif
