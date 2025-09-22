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

  test('high success 90% - passes 90% of the time', () => {
    expect(randomSuccess(0.90)).toBe(true);
  });

  test('moderate success 80% - moderate flakiness', () => {
    expect(randomSuccess(0.80)).toBe(true);
  });

  test('low success 70% - noticeable flakiness', () => {
    expect(randomSuccess(0.70)).toBe(true);
  });

  test('dice roll simulation - passes if we get 2-6', () => {
    const roll = diceRoll(); // 1-6
    expect(roll).toBeGreaterThanOrEqual(2); // ~83% chance
  });
});
