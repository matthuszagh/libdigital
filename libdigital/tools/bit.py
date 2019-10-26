"""
A collection of useful functions for converting between decimal
and binary numbers.
"""

def sub_integral_to_sint(f, prec):
    """
    Map a floating point number between the values of -1 and 1 to a
    signed integral value in the range [-2^(@prec-1)-1, 2^(@prec-1)-1].
    """
    return int(round(f * (2**(prec-1)-1)))

def int_to_hex(i, prec):
    """
    Return the two's complement hexadecimal representation of an
    integer.
    """
    if i > 2**(prec-1)-1 or i < -2**(prec-1):
        raise ValueError(
            """Value must be in the range given by @prec."""
        )
    if i < 0:
        i = 2**prec + i

    hex_str = format(i, "x")
    return hex_str

def hex_to_sint(s, prec):
    """
    Return the signed integer value of a hexadecimal string with bit
    precision @prec.
    """
    int_val = int(s, 16)
    min_val = -2**(prec-1)
    max_val = 2**(prec-1)-1
    if int_val > max_val:
        int_val = -2**(prec) + int_val
        if int_val > 0:
            raise ValueError(
                """Value is outside the range supported by"""
                """ specified precision."""
            )

    return int_val
