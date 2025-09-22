// Package probability provides utilities for probability-based flaky tests.
package probability

import (
	"errors"
	"math/rand"
	"time"
)

// RandomSuccess returns true with the given success rate (0.0 to 1.0).
func RandomSuccess(successRate float64) (bool, error) {
	if successRate < 0.0 || successRate > 1.0 {
		return false, errors.New("success rate must be between 0.0 and 1.0")
	}

	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	randomNumber := r.Intn(100)
	return randomNumber < int(successRate*100), nil
}

// DiceRoll simulates rolling a six-sided die.
func DiceRoll() int {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	return r.Intn(6) + 1 // 1-6
}

// IsBaselineTest always returns true - for baseline reliability tests.
func IsBaselineTest() bool {
	return true
}

// CalculateOverallSuccessRate calculates the probability of all tests passing
// given individual success rates.
func CalculateOverallSuccessRate(successRates []float64) float64 {
	overall := 1.0
	for _, rate := range successRates {
		overall *= rate
	}
	return overall
}
