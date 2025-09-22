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

// TestHighSuccess95Percent passes 95% of the time - occasional failures
func TestHighSuccess95Percent(t *testing.T) {
	success, err := probability.RandomSuccess(0.95)
	if err != nil {
		t.Fatalf("Error in RandomSuccess: %v", err)
	}
	if !success {
		t.Fatalf("Random failure at 95%% success rate")
	}
}

// TestModerateSuccess85Percent passes 85% of the time - moderate flakiness
func TestModerateSuccess85Percent(t *testing.T) {
	success, err := probability.RandomSuccess(0.85)
	if err != nil {
		t.Fatalf("Error in RandomSuccess: %v", err)
	}
	if !success {
		t.Fatalf("Random failure at 85%% success rate")
	}
}

// TestLowSuccess75Percent passes 75% of the time - noticeable flakiness
func TestLowSuccess75Percent(t *testing.T) {
	success, err := probability.RandomSuccess(0.75)
	if err != nil {
		t.Fatalf("Error in RandomSuccess: %v", err)
	}
	if !success {
		t.Fatalf("Random failure at 75%% success rate")
	}
}

// TestDiceRollSimulation simulates rolling a six-sided die - passes if we get 2-6
func TestDiceRollSimulation(t *testing.T) {
	roll := probability.DiceRoll()
	if roll < 2 {
		t.Fatalf("Dice roll failed: got %d, need 2-6 (~83%% chance)", roll)
	}
}
