#!/usr/bin/env python
"""
Unit tests for R2^2 SDF FFT.
"""

import numpy as np

import libdigital.tools.bit as bit
from libdigital.tools.cocotb_helpers import Clock, MultiClock

import cocotb
from cocotb.result import TestFailure
from cocotb.triggers import RisingEdge, ReadOnly, Combine
from cocotb.binary import *


class FFTTB:
    """
    R22 SDF FFT testbench class.
    """

    def __init__(self, dut):
        clk = Clock(dut.clk_i, 40)
        clk_3x = Clock(dut.clk_3x_i, 120)
        self.multiclock = MultiClock([clk, clk_3x])
        self.dut = dut

    @cocotb.coroutine
    async def setup(self):
        self.multiclock.start_all_clocks()
        await self.reset()

    @cocotb.coroutine
    async def reset(self):
        await self.await_all_clocks()
        self.dut.rst_n <= 0
        await self.await_all_clocks()
        self.dut.rst_n <= 1

    @cocotb.coroutine
    async def await_all_clocks(self):
        """
        Wait for positive edge on both clocks before proceeding.
        """
        trigs = []
        for clk in self.multiclock.clocks:
            trigs.append(RisingEdge(clk.clk))

        await Combine(*trigs)


@cocotb.test()
async def check_sequence(dut):
    """
    Compare the hdl FFT output with numpy, to within some specified tolerance.
    """
    fft = FFTTB(dut)
    await fft.setup()
    num_samples = 1024
    input_width = 14

    # low bound is inclusive and upper bound is exclusive
    input_seq = np.zeros(num_samples)
    for i, _ in enumerate(input_seq):
        input_seq[i] = np.random.randint(
            -2 ** (input_width - 1), 2 ** (input_width - 1)
        )

    input_seq = input_seq.astype(int)
    outputs = np.fft.fft(input_seq)
    reals = outputs.real
    imags = outputs.imag

    # TODO this tolerance is way too high. This is just an initial
    # sanity check.
    tol = 3000
    rdiffs = []
    idiffs = []

    glbl_ctr = 0
    i = num_samples
    while i > 0:
        if glbl_ctr < num_samples:
            fft.dut.data_re_i <= input_seq[glbl_ctr].item()
        else:
            fft.dut.data_re_i <= 0
        glbl_ctr += 1
        fft.dut.data_im_i <= 0
        await ReadOnly()
        if fft.dut.sync_o.value.integer:
            bit_rev_ctr = fft.dut.data_ctr_o.value.integer
            rval = fft.dut.data_re_o.value.signed_integer
            rexp = reals[bit_rev_ctr].item()
            rdiffs.append(rval - rexp)
            ival = fft.dut.data_im_o.value.signed_integer
            iexp = imags[bit_rev_ctr].item()
            idiffs.append(ival - iexp)
            if abs(rval - rexp) > tol:
                raise TestFailure(
                    (
                        "Actual real output differs from expected."
                        " Actual: %d, expected: %d, difference: %d."
                        " Tolerance set at %d."
                    )
                    % (rval, rexp, rval - rexp, tol)
                )

            if abs(ival - iexp) > tol:
                raise TestFailure(
                    (
                        "Actual imaginary output differs from expected."
                        " Actual: %d, expected: %d, difference: %d."
                        " Tolerance set at %d."
                    )
                    % (ival, iexp, ival - iexp, tol)
                )

            i -= 1
        await RisingEdge(fft.dut.clk_i)

    avg_tol = 70
    if abs(np.average(rdiffs)) > avg_tol:
        raise TestFailure(
            (
                "Average real outputs differ from expected more than"
                " tolerated. There might be a bias. Difference %f."
                " Tolerated: %f"
            )
            % (np.average(rdiffs), avg_tol)
        )
    if abs(np.average(idiffs)) > avg_tol:
        raise TestFailure(
            (
                "Average imaginary outputs differ from expected more than"
                " tolerated. There might be a bias. Difference %f."
                " Tolerated: %f"
            )
            % (np.average(idiffs), avg_tol)
        )
