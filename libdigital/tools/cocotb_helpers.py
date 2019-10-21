"""
A collection of useful functions for extending cocotb.
"""


def periods_integral(periods):
    """Test whether supplied list of clock periods are integral."""
    delta = 0.1
    for period in periods:
        if abs(period - round(period)) > delta:
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
    freqs_ps = [freq / 1e6 for freq in freqs]
    periods = [1 / freq for freq in freqs_ps]
    if not periods_integral(periods):
        min_per = min(periods)
        norm_periods = [period / min_per for period in periods]
        periods = norm_periods
        while True:
            if not periods_integral(periods):
                periods = [sum(x) for x in zip(periods, norm_periods)]
            else:
                break

    return [int(round(period)) for period in periods]
