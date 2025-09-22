"""
Probability utilities for flaky tests.
"""

import secrets


def random_success(success_rate: float) -> bool:
    """
    Return True with the given success rate (0.0 to 1.0).
    
    Args:
        success_rate: Probability of success (0.0 = never, 1.0 = always)
        
    Returns:
        True if random number is below success rate, False otherwise
    """
    if not 0.0 <= success_rate <= 1.0:
        raise ValueError("Success rate must be between 0.0 and 1.0")
    
    random_number = secrets.randbelow(100)
    return random_number < (success_rate * 100)


def dice_roll() -> int:
    """
    Simulate rolling a six-sided die.
    
    Returns:
        Random number between 1 and 6 (inclusive)
    """
    return secrets.randbelow(6) + 1


def is_baseline_test() -> bool:
    """
    Always returns True - for baseline reliability tests.
    
    Returns:
        Always True
    """
    return True
