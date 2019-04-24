defmodule MasterTest do
  use ExUnit.Case
  alias Mastermind, as: M

  test "a new game has no score" do
    game = M.new_game()
    assert game.moves == []
  end

  describe "with basic target" do

    setup do
      [ game: M.new_game([1, 2, 3, 4]) ]
    end

    test "a bad guess returns no red and white pegs", given do
      given.game
      |> M.make_guess([6, 6, 6, 6])
      |> assert_score(0, 0)
    end

    test "correct guess in wrong position returns one white", given do
      given.game
      |> M.make_guess([6, 6, 6, 1])
      |> assert_score(0, 1)
    end

    test "correct guess in right position returns one red", given do
      given.game
      |> M.make_guess([6, 6, 6, 4])
      |> assert_score(1, 0)
    end

    test "correct guess right position and correct wrong position returns one of each", given do
      given.game
      |> M.make_guess([6, 1, 6, 4])
      |> assert_score(1, 1)
    end

    test "all in wrong position returns 4 whites" do
      M.new_game([1, 2, 3, 4])
      |> M.make_guess([4, 3, 2, 1])
      |> assert_score(0, 4)
    end

    test "all in correct position returns 4 reds", given do
      given.game
      |> M.make_guess([1, 2, 3, 4])
      |> assert_score(4, 0)
    end
  end


  describe "target containing duplicates," do
    setup do
      [ game:  M.new_game([1, 2, 1, 4]) ]
    end

    test "with all in correct position returns 4 reds", given do
      given.game
      |> M.make_guess([1, 2, 1, 4])
      |> assert_score(4, 0)
    end

    test "with target containing duplicates, one correct position returns 1 red", given do
      given.game
      |> M.make_guess([1, 6, 6, 6])
      |> assert_score(1, 0)
    end


  end

  describe "game flow" do
    setup do
      [ game:  M.new_game([1, 2, 3, 4]) ]
    end

    test "for a winning game", given do
      [
        #  guess            R  W  won?
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 2, 2, 2, 2 ], { 1, 0, false } ],
        [ [ 1, 4, 2, 3 ], { 1, 3, false } ],
        [ [ 1, 2, 3, 4 ], { 4, 0, true } ],
      ]
      |> run_script(given.game)
    end

    test "for a losing game", given do
      game = [
        #  guess            R  W  won?
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
        [ [ 1, 2, 4, 3 ], { 2, 2, false } ],
      ]
      |> run_script(given.game)

      assert game.turns_left == 0
    end

    def run_script(script, game) do
      script
      |> Enum.reduce(game, &assess_script_results(&1, &2))
    end

    def assess_script_results([ guess, { reds, whites, won? }], game) do
      game = M.make_guess(game, guess)
      assert_score(game, reds, whites)
      assert game.won == won?
      game
    end
  end


  def assert_score(status, expected_reds, expected_whites) do
    %{ reds: reds, whites: whites } = hd(status.moves).score
    assert reds == expected_reds
    assert whites == expected_whites
  end
end
