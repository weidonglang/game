#!/usr/bin/env python3
"""Unit tests for Coin Flip Mini."""

import unittest
from coin_flip import normalize_choice, flip_coin, decide_result


class TestNormalizeChoice(unittest.TestCase):
    """Test input normalization."""

    def test_heads_full(self):
        """normalize_choice("heads") should return "heads"."""
        self.assertEqual(normalize_choice("heads"), "heads")

    def test_heads_abbrev(self):
        """normalize_choice("h") should return "heads"."""
        self.assertEqual(normalize_choice("h"), "heads")

    def test_tails_full(self):
        """normalize_choice("tails") should return "tails"."""
        self.assertEqual(normalize_choice("tails"), "tails")

    def test_tails_abbrev(self):
        """normalize_choice("t") should return "tails"."""
        self.assertEqual(normalize_choice("t"), "tails")

    def test_case_insensitive(self):
        """normalize_choice("HEADS") should return "heads"."""
        self.assertEqual(normalize_choice("HEADS"), "heads")

    def test_mixed_case(self):
        """normalize_choice("TaiLs") should return "tails"."""
        self.assertEqual(normalize_choice("TaiLs"), "tails")

    def test_whitespace_stripped(self):
        """normalize_choice(" heads ") should return "heads"."""
        self.assertEqual(normalize_choice(" heads "), "heads")

    def test_whitespace_only(self):
        """normalize_choice("   ") should return "invalid"."""
        self.assertEqual(normalize_choice("   "), "invalid")

    def test_empty_string(self):
        """normalize_choice("") should return "invalid"."""
        self.assertEqual(normalize_choice(""), "invalid")

    def test_tabs_and_newlines(self):
        """normalize_choice("\tH\n") should return "heads" after stripping."""
        self.assertEqual(normalize_choice("\tH\n"), "heads")

    def test_invalid_input(self):
        """normalize_choice("bad") should return "invalid"."""
        self.assertEqual(normalize_choice("bad"), "invalid")

    def test_number_input(self):
        """normalize_choice("123") should return "invalid"."""
        self.assertEqual(normalize_choice("123"), "invalid")


class TestDecideResult(unittest.TestCase):
    """Test result decision logic."""

    def test_win(self):
        """decide_result("heads", "heads") should return "win"."""
        self.assertEqual(decide_result("heads", "heads"), "win")

    def test_lose(self):
        """decide_result("heads", "tails") should return "lose"."""
        self.assertEqual(decide_result("heads", "tails"), "lose")

    def test_invalid_choice(self):
        """decide_result("invalid", "heads") should return "invalid"."""
        self.assertEqual(decide_result("invalid", "heads"), "invalid")


class TestFlipCoin(unittest.TestCase):
    """Test coin flip randomness."""

    def test_returns_heads_or_tails(self):
        """flip_coin() should only return "heads" or "tails"."""
        for _ in range(100):
            result = flip_coin()
            self.assertIn(result, ("heads", "tails"))


if __name__ == "__main__":
    unittest.main()