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

// TestHighSuccess90Percent passes 90% of the time - occasional failures
func TestHighSuccess90Percent(t *testing.T) {
	success, err := probability.RandomSuccess(0.90)
	if err != nil {
		t.Fatalf("Error in RandomSuccess: %v", err)
	}
	if !success {
		t.Fatalf("Random failure at 90%% success rate")
	}
}

// TestModerateSuccess80Percent passes 80% of the time - moderate flakiness
func TestModerateSuccess80Percent(t *testing.T) {
	success, err := probability.RandomSuccess(0.80)
	if err != nil {
		t.Fatalf("Error in RandomSuccess: %v", err)
	}
	if !success {
		t.Fatalf("Random failure at 80%% success rate")
	}
}

// TestLowSuccess70Percent passes 70% of the time - noticeable flakiness
func TestLowSuccess70Percent(t *testing.T) {
	success, err := probability.RandomSuccess(0.70)
	if err != nil {
		t.Fatalf("Error in RandomSuccess: %v", err)
	}
	if !success {
		t.Fatalf("Random failure at 70%% success rate")
	}
}

// TestDiceRollSimulation simulates rolling a six-sided die - passes if we get 2-6
func TestDiceRollSimulation(t *testing.T) {
	roll := probability.DiceRoll()
	if roll < 2 {
		t.Fatalf("Dice roll failed: got %d, need 2-6 (~83%% chance)", roll)
	}
}
