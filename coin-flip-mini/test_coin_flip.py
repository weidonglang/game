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

    def test_whitespace_stripped(self):
        """normalize_choice(" heads ") should return "heads"."""
        self.assertEqual(normalize_choice(" heads "), "heads")

    def test_invalid_input(self):
        """normalize_choice("bad") should return "invalid"."""
        self.assertEqual(normalize_choice("bad"), "invalid")


class TestDecideResult(unittest.TestCase):
    """Test result decision logic."""

    pass


class TestFlipCoin(unittest.TestCase):
    """Test coin flip randomness."""

    pass


if __name__ == "__main__":
    unittest.main()