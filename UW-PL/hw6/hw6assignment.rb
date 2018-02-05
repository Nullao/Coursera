# University of Washington, Programming Languages, Homework 6, hw6runner.rb

# This is the only file you turn in, so do not modify the other files as
# part of your solution.

class MyPiece < Piece
  # The constant All_My_Pieces should be declared here
  All_My_Pieces = [
  				rotations([[0, 0], [-1, 0], [0, 1], [1, 0], [-1, 1]]),

               	[[[0, 0], [-1, 0], [1, 0], [2, 0], [-2, 0]], 
               	[[0, 0], [0, -1], [0, 1], [0, 2], [0, -2]]],

               	rotations([[0, 0], [1, 0], [0, 1]]),

           		[[[0, 0], [1, 0], [0, 1], [1, 1]]],  # square (only needs one)
               	rotations([[0, 0], [-1, 0], [1, 0], [0, -1]]), # T

               	[[[0, 0], [-1, 0], [1, 0], [2, 0]], # long (only needs two)
               	[[0, 0], [0, -1], [0, 1], [0, 2]]],

               	rotations([[0, 0], [0, -1], [0, 1], [1, 1]]), # L

               	rotations([[0, 0], [0, -1], [0, 1], [-1, 1]]), # inverted L

               	rotations([[0, 0], [-1, 0], [0, -1], [1, -1]]), # S

               	rotations([[0, 0], [1, 0], [0, -1], [-1, -1]])
               ]
 Cheat_Piece = [[[0, 0]]]

  # your enhancements here
   def self.next_piece (board)
    Piece.new(All_My_Pieces.sample, board)
   end

    def self.cheat_piece(board)
    	MyPiece.new(Cheat_Piece, board)
	end

end

class MyBoard < Board
  # your enhancements here
  def initialize (game)
    super
    @current_block = MyPiece.next_piece(self)
    @cheat_cost = 100
    @cheat_queued = false


  end

  def rotate_180_degree
    if !game_over? and @game.is_running?
      @current_block.move(0, 0, 2)
    end
    draw
  end

  def next_piece
    @current_block = MyPiece.next_piece(self)
    @current_pos = nil
    if @cheat_queued
      @current_block = MyPiece.cheat_piece(self)
      @cheat_queued = false
    end
  end


	def store_current
	locations = @current_block.current_rotation
	displacement = @current_block.position
	(0..(locations.size-1)).each{
		|index| 
		current = locations[index];
		@grid[current[1]+displacement[1]][current[0]+displacement[0]] = 
		@current_pos[index]
	}
	remove_filled
	@delay = [@delay - 2, 80].max
  end



  def cheat
    return if @cheat_queued || @score < @cheat_cost
    @cheat_queued = true
    @score -= @cheat_cost
  end

end

class MyTetris < Tetris
  # your enhancements here

  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoard.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end

  def new_game
    super
    @cheat_queued = false
  end

  def key_bindings  
   super
   @root.bind('u', proc{@board.rotate_180_degree})
   @root.bind('c', proc{@board.cheat})
  end

end


