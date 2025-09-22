"""
Probability-based flaky tests for Python.

These tests demonstrate different failure rates using random number generation.
The flakiness is built into the test logic itself.
"""

import pytest
from it_works_on_my_machine import random_success, dice_roll, is_baseline_test


class TestProbabilityFlaky:
    """Tests that fail based on random probability."""

    def test_always_pass_baseline(self):
        """Always passes - reliable baseline test."""
        assert is_baseline_test()

    def test_high_success_95_percent(self):
        """Passes 95% of the time - occasional failures."""
        assert random_success(0.95)

    def test_moderate_success_85_percent(self):
        """Passes 85% of the time - moderate flakiness."""
        assert random_success(0.85)

    def test_low_success_75_percent(self):
        """Passes 75% of the time - noticeable flakiness."""
        assert random_success(0.75)

