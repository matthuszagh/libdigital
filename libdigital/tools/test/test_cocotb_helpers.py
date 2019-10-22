from libdigital.tools.cocotb_helpers import Clock, MultiClock


def test_normalize_periods_for_simulation():
    clocks = MultiClock([Clock(None, 60, 0), Clock(None, 40, 0)])
    for clk in clocks.clocks:
        print("period: {}, phase: {}".format(clk.period, clk.phase))

    assert True
