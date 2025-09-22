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

  test('high success 95% - passes 95% of the time', () => {
    expect(randomSuccess(0.95)).toBe(true);
  });

  test('moderate success 85% - moderate flakiness', () => {
    expect(randomSuccess(0.85)).toBe(true);
  });

  test('low success 75% - noticeable flakiness', () => {
    expect(randomSuccess(0.75)).toBe(true);
  });

  test('dice roll simulation - passes if we get 2-6', () => {
    const roll = diceRoll(); // 1-6
    expect(roll).toBeGreaterThanOrEqual(2); // ~83% chance
  });
});
