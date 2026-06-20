import unittest
from rps import decide_winner


class TestDecideWinner(unittest.TestCase):

    def test_rock_beats_scissors(self):
        self.assertEqual(decide_winner("rock", "scissors"), "player")

    def test_paper_beats_rock(self):
        self.assertEqual(decide_winner("paper", "rock"), "player")

    def test_scissors_beats_paper(self):
        self.assertEqual(decide_winner("scissors", "paper"), "player")

    def test_draw_rock(self):
        self.assertEqual(decide_winner("rock", "rock"), "draw")

    def test_draw_paper(self):
        self.assertEqual(decide_winner("paper", "paper"), "draw")

    def test_draw_scissors(self):
        self.assertEqual(decide_winner("scissors", "scissors"), "draw")

    def test_player_loses(self):
        self.assertEqual(decide_winner("rock", "paper"), "computer")
        self.assertEqual(decide_winner("paper", "scissors"), "computer")
        self.assertEqual(decide_winner("scissors", "rock"), "computer")

    def test_invalid_player_choice(self):
        self.assertEqual(decide_winner("gun", "rock"), "invalid")

    def test_invalid_computer_choice(self):
        self.assertEqual(decide_winner("rock", "gun"), "invalid")

    def test_case_insensitive(self):
        self.assertEqual(decide_winner("Rock", "SCISSORS"), "player")
        self.assertEqual(decide_winner("PAPER", "rock"), "player")

    def test_whitespace_handling(self):
        self.assertEqual(decide_winner("  rock  ", "paper"), "computer")


if __name__ == "__main__":
    unittest.main()