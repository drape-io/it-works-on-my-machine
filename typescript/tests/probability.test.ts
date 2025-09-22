/**
 * Probability-based flaky tests for TypeScript.
 * 
 * These tests demonstrate different failure rates using random number generation.
 * The flakiness is built into the test logic itself.
 */

describe('Probability Flaky Tests', () => {
  test('reliable probability baseline - always passes', () => {
    // Always passes - reliable baseline
    expect(true).toBe(true);
  });

  test('high success 95% - passes 95% of the time', () => {
    const randomNumber = Math.floor(Math.random() * 100);
    expect(randomNumber).toBeLessThan(95);
  });

  test('moderate success 85% - moderate flakiness', () => {
    const randomNumber = Math.floor(Math.random() * 100);
    expect(randomNumber).toBeLessThan(85);
  });

  test('low success 75% - noticeable flakiness', () => {
    const randomNumber = Math.floor(Math.random() * 100);
    expect(randomNumber).toBeLessThan(75);
  });

  test('dice roll simulation - passes if we get 2-6', () => {
    const roll = Math.floor(Math.random() * 6) + 1; // 1-6
    expect(roll).toBeGreaterThanOrEqual(2); // ~83% chance
  });


});
