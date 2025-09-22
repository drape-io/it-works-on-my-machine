"""
Probability-based flaky tests for Python.

These tests demonstrate different failure rates using random number generation.
The flakiness is built into the test logic itself.
"""

import secrets
import pytest


class TestProbabilityFlaky:
    """Tests that fail based on random probability."""

    def test_always_pass_baseline(self):
        """Always passes - reliable baseline test."""
        assert True

    def test_high_success_95_percent(self):
        """Passes 95% of the time - occasional failures."""
        random_number = secrets.randbelow(100)
        assert random_number < 95

    def test_moderate_success_85_percent(self):
        """Passes 85% of the time - moderate flakiness."""
        random_number = secrets.randbelow(100)
        assert random_number < 85

    def test_low_success_75_percent(self):
        """Passes 75% of the time - noticeable flakiness."""
        random_number = secrets.randbelow(100)
        assert random_number < 75

