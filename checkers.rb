#a non-king Piece can move forward ony; kings can move backward and forward

class Piece
  attr_accessor :is_king
  
  def initialize
    @is_king = false
  end
  
  #illegal slide/jump should return false; else true
  def perform_slide
    #
  end
  
  
  def perform_jump
    #should remove the jumped piece from the Board
  end
  
  #takes a sequence of moves. This can either be one slide,
  #or one or more jumps
  #perform_moves! should not bother to try to restore the origin Board
  #state if the move sequence fails
  def perform_moves!(move_sequence)
    #should perform the moves one-by-one
    #if a move int he sequence fails, and InvalidMoveError should
    #be raised
    
    #if the sequence is one move long, ry sliding; if that
    #doesn't work, try jumping
    #if the sequence is multiple moves long, evey move must be a jump
  end
  
  def valid_move_seq?
    #calls perform_moves! on a duped Piece/Board
    #if no error is raised, return true
    #else, return false
    #Will most likely require begin/rescue/else
    #because it dups the objects, valid_move_seq? will
    #not modify the original Board
  end
  
  def perform_moves
    #first checks valid_move_seq?, THEN
    #either calls perform_moves! or raises an
    #InvalidMoveError
  end
    
  def move_diffs
    #initially move_diffs only go towards opponents side
    #after kinging, allows movement diffs in both directions
    move_diffs = [[1, 1], [1, -1]]
    if self.is_king
      move_diffs += [[-1, -1], [-1, 1]]
    end
    move_diffs
  end
  
  #Called after each move to check if 
  #piece is at the end?
  def maybe_promote
    
  end
  
  #Promotes this piece to king status
  #allows moves forwards and backwards
  def promote_to_king
    self.is_king = true
  end
  
end

class Board
  attr_accessor :grid
  
  def initialize
    @grid = Array.new(8) { Array.new(8, nil)}
  end
end

class Game
  attr_reader :board, :current_player, :players
  
  def intitialize
    @board = Board.new
    @players = {
      :red => HumanPlayer.new(:red),
      :black => HumanPlayer.new(:black)
    }
    @current_player = :white
  end
  
  
end
