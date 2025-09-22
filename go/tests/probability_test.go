package tests

import (
	"math/rand"
	"testing"
	"time"
)

// TestReliableProbabilityBaseline always passes - reliable baseline
func TestReliableProbabilityBaseline(t *testing.T) {
	// Always passes
	if !true {
		t.Fatal("This should always pass")
	}
}

// TestHighSuccess95Percent passes 95% of the time - occasional failures
func TestHighSuccess95Percent(t *testing.T) {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	randomNumber := r.Intn(100)
	if randomNumber >= 95 {
		t.Fatalf("Random failure: %d >= 95", randomNumber)
	}
}

// TestModerateSuccess85Percent passes 85% of the time - moderate flakiness
func TestModerateSuccess85Percent(t *testing.T) {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	randomNumber := r.Intn(100)
	if randomNumber >= 85 {
		t.Fatalf("Random failure: %d >= 85", randomNumber)
	}
}

// TestLowSuccess75Percent passes 75% of the time - noticeable flakiness
func TestLowSuccess75Percent(t *testing.T) {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	randomNumber := r.Intn(100)
	if randomNumber >= 75 {
		t.Fatalf("Random failure: %d >= 75", randomNumber)
	}
}

// TestDiceRollSimulation simulates rolling a six-sided die - passes if we get 2-6
func TestDiceRollSimulation(t *testing.T) {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	roll := r.Intn(6) + 1 // 1-6
	if roll < 2 {
		t.Fatalf("Dice roll failed: got %d, need 2-6 (~83%% chance)", roll)
	}
}
