/**
 * Probability-based flaky tests for TypeScript.
 * 
 * These tests demonstrate different failure rates using random number generation.
 * The flakiness is built into the test logic itself.
 */

import { randomSuccess, diceRoll, isBaselineTest } from '../src/probability';

describe('Probability Flaky Tests', () => {
  test('reliable probability baseline - always passes', () => {
    // Always passes - reliable baseline
    expect(isBaselineTest()).toBe(true);
  });

  test('high success 75% - passes 75% of the time', () => {
    expect(randomSuccess(0.75)).toBe(true);
  });

  test('moderate success 60% - high flakiness', () => {
    expect(randomSuccess(0.60)).toBe(true);
  });

  test('low success 50% - very high flakiness', () => {
    expect(randomSuccess(0.50)).toBe(true);
  });

  test('dice roll simulation - passes if we get 3-6', () => {
    const roll = diceRoll(); // 1-6
    expect(roll).toBeGreaterThanOrEqual(3); // ~67% chance
  });
});
