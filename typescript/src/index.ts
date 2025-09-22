/**
 * Flaky Tests TypeScript Library
 * 
 * A collection of intentionally flaky test utilities that demonstrate
 * probability-based test instability.
 */

export { randomSuccess, diceRoll, isBaselineTest, calculateOverallSuccessRate } from './probability';

// Version information
export const VERSION = '0.1.0';
export const DESCRIPTION = 'TypeScript probability-based flaky tests for testing tools and methodologies';