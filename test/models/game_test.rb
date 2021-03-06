require 'test_helper'

class GameTest < ActiveSupport::TestCase

	test "check obstruction logic"  do
		game = FactoryGirl.create(:game)
		piece_to_move = FactoryGirl.create(:pawn, :game_id => game.id, :x_coord => 3, :y_coord => 4, :color => "white")
		piece_to_move2 = FactoryGirl.create(:rook, :game_id => game.id, :x_coord => 2, :y_coord => 6, :color => "black")
		different_piece = FactoryGirl.create(:pawn, :game_id => game.id, :x_coord => 3, :y_coord => 5, :color => "white")
		another_piece = FactoryGirl.create(:pawn, :game_id => game.id, :x_coord => 3, :y_coord => 7, :color => "white")
		additional_piece = FactoryGirl.create(:rook, :game_id => game.id, :x_coord => 3, :y_coord => 6, :color => "black")

		actual = game.is_move_obstructed?(piece_to_move.id,3, 5)
		assert actual, "There should be an obstruction detected on target tile"

		actual = game.is_move_obstructed?(piece_to_move.id,3, 6)
		assert actual, "There should be an obstruction detected in between target and piece tile"
		
		actual = game.is_move_obstructed?(piece_to_move.id,2, 4)
		assert_not actual, "There should be no obstruction detected in between target and piece tile"

		actual = game.is_move_obstructed?(piece_to_move.id,6, 7)
		assert_not actual, "There should be no obstruction detected on diagonal in between target and piece tile"

		actual = game.is_move_obstructed?(piece_to_move.id,6, 6)
		assert_nil actual, "Should return nil if destination tile is not on horiz/vert/diagonal line from piece tile"
	
		actual = game.is_move_obstructed?(piece_to_move2.id, 5, 6)
		assert actual, "Rook simulation should fail due to obstruction" 

		actual = game.is_move_obstructed?(piece_to_move2, 4, 8)
		assert actual, "Bishop simulation should fail due to obstruction"

		actual = game.is_move_obstructed?(piece_to_move2, 2, 6)
		assert actual, "Piece can not move to the tile it already occupies"

	end

	test "check obstruction and move validity logic combined" do
		game = FactoryGirl.create(:game)
		piece_to_move = FactoryGirl.create(:pawn, :game_id => game.id, :x_coord => 3, :y_coord => 4, :color => "white")
		different_piece = FactoryGirl.create(:pawn, :game_id => game.id, :x_coord => 3, :y_coord => 5, :color => "white")

		actual = piece_to_move.is_move_allowed?(3,5)
		assert_not actual, "Move is valid but there is an obstruction detected on target tile"

		actual = piece_to_move.is_move_allowed?(2,5)
		assert_not actual, "The move isn't valid"

		piece_to_move = FactoryGirl.create(:pawn, :game_id => game.id, :x_coord => 2, :y_coord => 4, :color => "white")
		actual = piece_to_move.is_move_allowed?(2,5)
		assert actual, "Move is valid and there is no obstruction detected on target tile"
	end

	test "check obstruction logic shows obstruction only up/down or only across - not both" do
		game = FactoryGirl.create(:game)
		piece_to_move = FactoryGirl.create(:rook, :game_id => game.id, :x_coord => 3, :y_coord => 3, :color => "white")
		different_piece = FactoryGirl.create(:pawn, :game_id => game.id, :x_coord => 4, :y_coord => 3, :color => "white")
		piece_to_move2 = FactoryGirl.create(:queen, :game_id => game.id, :x_coord => 5, :y_coord => 5, :color => "white")
		another_piece = FactoryGirl.create(:pawn, :game_id => game.id, :x_coord => 5, :y_coord => 6, :color => "white")

		actual = game.is_move_obstructed?(piece_to_move.id, 3, 4)
		assert_not actual, "Piece moving up is showing obstruction to the right"

		actual = game.is_move_obstructed?(piece_to_move.id, 6, 5)
		assert_not actual, "Piece moving to the right is showing obstruction up"
	end

	test "check turn logic" do
		game = FactoryGirl.create(:game)
		actual = game.player_turn
		assert_equal "white", actual, "Player at start of game should be white" 

    	game.next_player
	    actual = game.player_turn
	    assert_equal "black", actual, "Player after first turn should be black" 

	    assert_equal "white", game.get_player_color(game.user.id), "First player (user) should be white"
	    assert_equal "black", game.get_player_color(game.opponent.id), "Second player (opponent) should be black"

	end
end
