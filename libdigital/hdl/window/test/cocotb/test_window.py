#!/usr/bin/env python
"""
Unit tests for window.
"""

import numpy as np

from libdigital.tools.cocotb_helpers import Clock, random_samples

import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly
from cocotb.result import TestFailure


class WindowTB:
    """
    Window testbench class.
    """

    def __init__(self, dut, num_samples, input_width):
        self.clk = Clock(dut.clk, 40)
        self.dut = dut
        self.inputs = random_samples(input_width, num_samples)
        self.coeffs = np.kaiser(num_samples, 6)
        self.outputs = np.multiply(self.inputs, self.coeffs)

    @cocotb.coroutine
    async def setup(self):
        """
        Initialize window.
        """
        cocotb.fork(self.clk.start())
        await self.reset()

    @cocotb.coroutine
    async def reset(self):
        """
        Start window in a known state.
        """
        await RisingEdge(self.dut.clk)
        self.dut.rst_n <= 0
        await RisingEdge(self.dut.clk)
        self.dut.rst_n <= 1

    @cocotb.coroutine
    async def write_continuous(self):
        """
        Continously write inputs. When inputs have been exhausted, write
        zeros.
        """
        sample_ctr = 0
        num_samples = len(self.inputs)
        self.dut.en <= 1
        while True:
            if sample_ctr < num_samples:
                self.dut.di <= self.inputs[sample_ctr].item()
            else:
                self.dut.di <= 0
            sample_ctr += 1
            await RisingEdge(self.dut.clk)


@cocotb.test()
async def check_results(dut):
    """
    Compare outputs with expected values.
    """
    num_samples = 1024
    input_width = 14
    tb = WindowTB(dut, num_samples, input_width)
    await tb.setup()

    cocotb.fork(tb.write_continuous())

    # Latency of 2 clock cycles
    await RisingEdge(tb.dut.clk)

    tol = 1
    i = 0
    while i < len(tb.outputs):
        await RisingEdge(tb.dut.clk)
        await ReadOnly()
        out_val = tb.dut.dout.value.signed_integer
        out_exp = int(round(tb.outputs[i]))
        if abs(out_val - out_exp) > tol:
            raise TestFailure(
                (
                    "Actual output differs from expected."
                    " Actual: %d, expected: %d"
                )
                % (out_val, out_exp)
            )

        i += 1
