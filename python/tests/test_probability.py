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

    def test_high_success_75_percent(self):
        """Passes 75% of the time - frequent failures."""
        assert random_success(0.75)

    def test_moderate_success_60_percent(self):
        """Passes 60% of the time - high flakiness."""
        assert random_success(0.60)

    def test_low_success_50_percent(self):
        """Passes 50% of the time - very high flakiness."""
        assert random_success(0.50)

    def test_dice_roll_simulation(self):
        """Simulates rolling a six-sided die - passes if we get 3-6 (~67% chance)."""
        roll = dice_roll()  # 1-6
        assert roll >= 3, f"Dice roll failed: got {roll}, need 3-6 (~67% chance)"

