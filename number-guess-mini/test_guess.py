import unittest
from guess import check_guess


class TestCheckGuess(unittest.TestCase):

    def test_guess_too_low(self):
        secret = 50
        guess = 30
        self.assertEqual(check_guess(secret, guess), "low")

    def test_guess_too_high(self):
        secret = 50
        guess = 70
        self.assertEqual(check_guess(secret, guess), "high")

    def test_guess_correct(self):
        secret = 50
        guess = 50
        self.assertEqual(check_guess(secret, guess), "correct")


if __name__ == "__main__":
    unittest.main()