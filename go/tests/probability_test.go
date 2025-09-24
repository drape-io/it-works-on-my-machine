package tests

import (
	"testing"

	"github.com/flaky-tests/it-works-on-my-machine/pkg/probability"
)

// TestReliableProbabilityBaseline always passes - reliable baseline
func TestReliableProbabilityBaseline(t *testing.T) {
	if !probability.IsBaselineTest() {
		t.Fatal("Baseline test should always pass")
	}
}

// TestHighSuccess75Percent passes 75% of the time - frequent failures
func TestHighSuccess75Percent(t *testing.T) {
	success, err := probability.RandomSuccess(0.75)
	if err != nil {
		t.Fatalf("Error in RandomSuccess: %v", err)
	}
	if !success {
		t.Fatalf("Random failure at 75%% success rate")
	}
}

// TestModerateSuccess60Percent passes 60% of the time - high flakiness
func TestModerateSuccess60Percent(t *testing.T) {
	success, err := probability.RandomSuccess(0.60)
	if err != nil {
		t.Fatalf("Error in RandomSuccess: %v", err)
	}
	if !success {
		t.Fatalf("Random failure at 60%% success rate")
	}
}

// TestLowSuccess50Percent passes 50% of the time - very high flakiness
func TestLowSuccess50Percent(t *testing.T) {
	success, err := probability.RandomSuccess(0.50)
	if err != nil {
		t.Fatalf("Error in RandomSuccess: %v", err)
	}
	if !success {
		t.Fatalf("Random failure at 50%% success rate")
	}
}

// TestDiceRollSimulation simulates rolling a six-sided die - passes if we get 3-6
func TestDiceRollSimulation(t *testing.T) {
	roll := probability.DiceRoll()
	if roll < 3 {
		t.Fatalf("Dice roll failed: got %d, need 3-6 (~67%% chance)", roll)
	}
}
