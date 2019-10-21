#!/usr/bin/env python
"""
Unit tests for async_fifo.v
"""

import random

from libdigital.tools.cocotb_helpers import *

import cocotb
from cocotb.result import TestFailure
from cocotb.triggers import *
from cocotb.clock import *
from cocotb.binary import *


def retrieve_clocks(dut):
    """Access clocks."""
    clocks = [(dut.rdclk, 60), (dut.wrclk, 40)]
    return clocks


def gen_clocks(dut):
    """
    Generate testbench clock signals.
    """
    clocks = retrieve_clocks(dut)
    freqs = [clock[1] for clock in clocks]
    periods = clock_valid_periods(freqs)
    clock_objs = [clock[0] for clock in clocks]
    for i, _ in enumerate(periods):
        clk = Clock(clock_objs[i], periods[i], "ns")
        cocotb.fork(clk.start())


@cocotb.coroutine
async def reset(dut):
    """
    Trigger a synchronous reset and ensure all clocks register it.
    """
    trigs = []
    for clk in retrieve_clocks(dut):
        trigs.append(RisingEdge(clk[0]))

    await Combine(*trigs)
    dut.rst_n <= 0
    dut.wren <= 0
    dut.rden <= 0
    await Combine(*trigs)
    dut.rst_n <= 1


@cocotb.coroutine
async def setup_dut(dut):
    """Instantiate test module."""
    gen_clocks(dut)
    await reset(dut)


@cocotb.coroutine
async def write_val(dut, val):
    """Write a value to the FIFO."""
    dut.wren <= 1
    dut.wrdata <= val
    await RisingEdge(dut.wrclk)


@cocotb.coroutine
async def read_val(dut):
    """Read a value from the FIFO."""
    dut.rden <= 1
    await RisingEdge(dut.rdclk)
    await ReadOnly()
    return dut.rddata.value


@cocotb.test()
async def write_and_check_addr(dut):
    """
    Write a single value to the FIFO and ensure the internal address
    increments.
    """
    await setup_dut(dut)
    await ReadOnly()
    old_addr = dut.wraddr.value.integer
    await RisingEdge(dut.wrclk)
    dut.wren <= 1
    await RisingEdge(dut.wrclk)
    await ReadOnly()
    if dut.wraddr.value.integer != old_addr + 1:
        raise TestFailure(
            (
                "Write failed to increment internal FIFO address (wraddr)."
                " Actual: %d, expected: %d."
            )
            % (dut.wraddr.value.integer, old_addr.value.integer + 1)
        )
    await Timer(10000)


@cocotb.test()
async def write_single_val_immediate_read(dut):
    """
    Write a single value to the FIFO, immediately read and check the
    values match.
    """
    await setup_dut(dut)
    wrval = random.randint(0, 2 ** 64 - 1)
    await write_val(dut, wrval)
    rdval = await read_val(dut)
    if wrval != rdval.integer:
        raise TestFailure(
            ("Write value differs from read value." " Write: %d, read: %d.")
            % (wrval, rdval.integer)
        )
    await Timer(10000)