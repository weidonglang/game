import unittest
from dice_duel import decide_round


class TestDecideRound(unittest.TestCase):

    def test_player_wins(self):
        self.assertEqual(decide_round(10, 4), "player")
        self.assertEqual(decide_round(7, 2), "player")

    def test_computer_wins(self):
        self.assertEqual(decide_round(3, 8), "computer")
        self.assertEqual(decide_round(5, 11), "computer")

    def test_draw(self):
        self.assertEqual(decide_round(6, 6), "draw")
        self.assertEqual(decide_round(12, 12), "draw")

    def test_boundary_values(self):
        self.assertEqual(decide_round(2, 2), "draw")
        self.assertEqual(decide_round(12, 12), "draw")
        self.assertEqual(decide_round(2, 12), "computer")
        self.assertEqual(decide_round(12, 2), "player")


if __name__ == "__main__":
    unittest.main()