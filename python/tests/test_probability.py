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

    def test_high_success_90_percent(self):
        """Passes 90% of the time - occasional failures."""
        assert random_success(0.90)

    def test_moderate_success_80_percent(self):
        """Passes 80% of the time - moderate flakiness."""
        assert random_success(0.80)

    def test_low_success_70_percent(self):
        """Passes 70% of the time - noticeable flakiness."""
        assert random_success(0.70)

