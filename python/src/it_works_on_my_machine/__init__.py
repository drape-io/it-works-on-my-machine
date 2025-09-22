"""
It Works On My Machine - A collection of intentionally flaky test utilities.

This library provides utilities and patterns for creating probability-based
flaky tests that demonstrate test instability through random failures.
"""

__version__ = "0.1.0"
__author__ = "John"
__email__ = "john@drape.io"

from .probability import random_success, dice_roll, is_baseline_test

__all__ = [
    "random_success",
    "dice_roll", 
    "is_baseline_test",
]