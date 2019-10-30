#!/usr/bin/env python
"""
Unit tests for fir_poly.
"""

import numpy as np
from scipy import signal

from libdigital.tools.cocotb_helpers import Clock, ClockEnable
from libdigital.tools.fir import FIR

import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly
from cocotb.result import TestFailure


class FIRTB:
    """
    FIR testbench class.
    """

    def __init__(self, dut):
        self.clk = Clock(dut.clk, 40)
        self.clk_en = ClockEnable(dut.clk, dut.clk_2mhz_pos_en, dut.rst_n, 20)
        self.dut = dut

    @cocotb.coroutine
    async def setup(self):
        """
        Initialize FIR filter in a defined state.
        """
        cocotb.fork(self.clk.start())
        cocotb.fork(self.clk_en.start())
        await self.reset()

    @cocotb.coroutine
    async def reset(self):
        """
        Assert a reset and ensure it's registered by the clock.
        """
        await RisingEdge(self.dut.clk)
        self.dut.rst_n <= 0
        await RisingEdge(self.dut.clk)
        self.dut.rst_n <= 1

    @cocotb.coroutine
    async def write_continuous(self, inputs):
        """
        Continously write inputs. When inputs have been exhausted, write
        zeros.
        """
        sample_ctr = 0
        num_samples = len(inputs)
        while True:
            if sample_ctr < num_samples:
                self.dut.din <= inputs[sample_ctr].item()
            else:
                self.dut.din <= 0
            sample_ctr += 1
            await RisingEdge(self.dut.clk)


@cocotb.test()
async def check_sequence(dut):
    """
    Compare the output from a randomly-generated sequence with scipy.
    """
    fir = FIR(
        numtaps=120,
        bands=[0, 0.95e6, 1e6, 20e6],
        band_gain=[1, 0],
        fs=40e6,
        pass_db=0.5,
        stop_db=-40,
    )
    tb = FIRTB(dut)
    await tb.setup()
    num_samples = 10000
    downsample_factor = 20
    num_outputs = int(num_samples / downsample_factor)
    input_width = 12
    input_seq = np.zeros(num_samples)
    for i, _ in enumerate(input_seq):
        input_seq[i] = np.random.randint(
            -2 ** (input_width - 1), 2 ** (input_width - 1)
        )
    input_seq = input_seq.astype(int)
    cocotb.fork(tb.write_continuous(input_seq))

    out_pre_dec = np.convolve(input_seq, fir.taps)
    outputs = [out_pre_dec[i] for i in range(len(out_pre_dec)) if i % 20 == 0]
    # outputs = signal.resample_poly(
    #     input_seq, 1, downsample_factor, 0, fir.taps
    # )

    tol = 2 ** 14 / 1e1
    i = num_outputs
    clk_en_ctr = 0
    while i > 0:
        await FallingEdge(tb.dut.clk_2mhz_pos_en)
        await ReadOnly()
        if tb.dut.dvalid.value.integer:
            out_val = tb.dut.dout.value.signed_integer
            print(
                "expected: {:5}, actual: {:5}".format(
                    int(outputs[num_outputs - i].item()), out_val
                )
            )
            if abs(out_val - outputs[num_outputs - i].item()) > tol:
                raise TestFailure(
                    (
                        "Actual output differs from expected."
                        " Actual: %d, expected: %d. Tolerance set at %d."
                    )
                    % (out_val, outputs[num_outputs - i].item(), tol)
                )

            i -= 1
