#!/usr/bin/env python
"""
Cocotb unit test for ft245.v
"""

import cocotb
from cocotb.clock import Clock, Timer


def periods_integral(periods):
    """Test whether supplied list of clock periods are integral."""
    for period in periods:
        if period != int(period):
            return False

    return True


def clock_valid_periods(freqs):
    """
    From a list of clock frequencies (MHz) return a list of periods
    with integral half-period ps timesteps.

    If the original clock frequencies don't require any modification,
    they will be returned as is. If any frequency corresponds to a
    non-integral half-period, the minimum integral half frequencies
    will be returned.

    Parameters

    freqs : list of clock frequencies in ns. ps resolution is
            supported, so any decimal past the 3rd is ignored

    Returns

    A list containing the period of each clock in ps.
    """
    freqs_ps = freqs/1e6
    periods = [1/freq for freq in freqs_ps]
    if not periods_integral(periods):
        min_per = min(periods)
        norm_periods = periods / min_per
        periods = norm_periods
        while True:
            if not periods_integral(norm_periods):
                periods += norm_periods
            else:
                break

    return periods

def gen_clocks(dut):
    """
    Generate testbench clock signals.
    """
    clocks = [(dut.clk, 40), (dut.ft_clk, 60), (dut.slow_ft_clk, 7.5)]
    freqs = [clock()[1] for clock in clocks]
    periods = clock_valid_periods(freqs)
    clock_objs = [clock()[0] for clock in clocks]
    for i, _ in enumerate(periods):
        clk = Clock(clock_objs[i], periods[i], 'ns')
        cocotb.fork(clk.start())


# @cocotb.test()
# def my_first_test(dut):
#     """
#     Try accessing the design.
#     """

#     dut._log.info("Running test!")
#     for cycle in range(10):
#         dut.clk = 0
#         yield Timer(1000)
#         dut.clk = 1
#         yield Timer(1000)
#     dut._log.info("Running test!")
