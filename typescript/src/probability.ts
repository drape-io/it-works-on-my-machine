/**
 * Probability utilities for flaky tests.
 */

/**
 * Return true with the given success rate (0.0 to 1.0).
 * 
 * @param successRate - Probability of success (0.0 = never, 1.0 = always)
 * @returns True if random number is below success rate, false otherwise
 */
export function randomSuccess(successRate: number): boolean {
  if (successRate < 0.0 || successRate > 1.0) {
    throw new Error('Success rate must be between 0.0 and 1.0');
  }
  
  const randomNumber = Math.floor(Math.random() * 100);
  return randomNumber < (successRate * 100);
}

/**
 * Simulate rolling a six-sided die.
 * 
 * @returns Random number between 1 and 6 (inclusive)
 */
export function diceRoll(): number {
  return Math.floor(Math.random() * 6) + 1;
}

/**
 * Always returns true - for baseline reliability tests.
 * 
 * @returns Always true
 */
export function isBaselineTest(): boolean {
  return true;
}

/**
 * Calculate the probability of all tests passing given individual success rates.
 * 
 * @param successRates - Array of individual test success rates
 * @returns Overall probability of all tests passing
 */
export function calculateOverallSuccessRate(successRates: number[]): number {
  return successRates.reduce((overall, rate) => overall * rate, 1.0);
}
