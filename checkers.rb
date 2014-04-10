#a non-king Piece can move forward ony; kings can move backward and forward

class Piece
  attr_reader :board, :color
  attr_accessor :pos, :is_king
  
  def initialize(color, board, pos)
    @is_king = false
    
    raise "invalid color" unless [:red, :white].include?(color)
    raise "invalid pos" unless board.valid_pos?(pos)
    
    @color, @board, @pos = color, board, pos
    
    board.add_piece(self, pos)
  end
  
  #● black piece
  #○ white piece
  
  #◆ black diamond - king
  #◇ white diamond - king
  
  
  #trace for a move/move_sequence is
  #perform_moves
  # => valid_move_seq?
  # =>    if false 
  
  def perform_moves(move_sequence)
    if valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
    else
      #throw an InvalidMoveError
    end
    #first checks valid_move_seq?, THEN
    #either calls perform_moves! or raises an
    #InvalidMoveError
  end
  
  def perform_slide(to_pos)
    unless self.valid_moves.include?(to_pos)
      raise InvalidMoveError
    end
    board.move_piece!(self.pos, to_pos)
  end
  
  
  
  def perform_jump(to_pos)
    #should remove the jumped piece from the Board
    unless self.valid_moves.include?(to_pos)
      raise InvalidMoveError
    end
    board.move_piece!(self.pos, to_pos)
    board.remove_piece(self.pos, to_pos)#calculate square between squares
  end
  
  def valid_moves
    valid_moves = []
  
    move_diffs.each do |(dx, dy)|
      cur_x, cur_y = pos
      pos = [cur_x + dx, cur_y + dy]
    
      #ensure that position is within bounds of the board
      next unless board.valid_pos?(pos)
    
      #if the board is empty at that position then its slide
      # =>                    slide move diff must not contain
      # =>                    a value greater than 1, see move_diffs for clarity
      if board.empty?(pos) && dx.abs < 2
        valid_moves << pos
      #if position is occupied by a opponent piece then
      #its jump move diff must be greater than 1, see move_diffs for clarity
      elsif board[pos].color != self.color && dx.abs > 1
        valid_moves << pos
      end
    end
    valid_moves
  end
  
  #returns true or false
  def valid_move_seq?
    
    #calls perform_moves! on a duped Piece/Board
    #if no error is raised, return true
    #else, return false
    #Will most likely require begin/rescue/else
    #because it dups the objects, valid_move_seq? will
    #not modify the original Board
    true
  end
  
  #takes a sequence of moves. This can either be one slide,
  #or one or more jumps
  #perform_moves! should not bother to try to restore the origin Board
  #state if the move sequence fails
  def perform_moves!(move_sequence)
    #should perform the moves one-by-one
    #if a move int he sequence fails, and InvalidMoveError should
    #be raised
    
    #if the sequence is one move long, try sliding; if that
    #doesn't work, try jumping
    #if the sequence is multiple moves long, evey move must be a jump
    # => DO THIS RECURSIVELY 
  end
    
  def move_diffs
    #initially move_diffs only go towards opponents side
    #after kinging, allows movement diffs in both directions
    
    #sliding move_diffs NEED TO ADD jumping move_diffs!!!!!!!!!!!!!!!!!!!!!
    #must then filter out invalid moves after 
                  #sliding diffs , jumping diffs    
    move_diffs = [[1, 1], [1, -1], [2, 2], [2, -2]]
    if self.is_king
      move_diffs += [[-1, -1], [-1, 1], [-2, -2], [-2, 2]]
    end
    
    #red starts at bottom
    #black starts at top
    
    #switch move_diffs according to the players color
    if self.color == :red
      #I THINK THIS IS RIGHT DEBUG LATER
      move_diffs.each { |move_diff| move_diff.map! { |diff| diff * -1 } }
    end
    move_diffs  
  end
  
  #Called after each move to check if 
  #piece is at the end?
  def maybe_promote
    #if piece.color == a color && piece.pos == at opponents end of board
      #self.promote_to_king = true
    #end
  end
  
  #Promotes this piece to king status
  #allows moves forwards and backwards
  def promote_to_king
    self.is_king = true
  end
  
end



class Board
  attr_accessor :grid
  
  def initialize(fill_board = true)
    #@grid = Array.new(8) { Array.new(8, nil)}
    make_starting_grid(fill_board)
  end
  
  #■ black square
  #□ white square
  
  def [](pos)
    raise "pos out of board bounds" unless pos_within_bounds?(pos)
    
    i, j = pos
    @grid[i][j]
  end
  
  def add_piece(piece, pos)
    raise "position not empty" unless empty?(pos)
    
    self[pos] = piece
  end
  
  #removes a jumped piece
  def remove_piece(opps_from, opps_to)
    row = (opps_from[0] + opps_to[0]) / 2
    col = (opps_from[1] + opps_to[1]) / 2
    [row, col]
  end
  
  #move without performing checks,
  #checks have been made in perform_jump
  #and perform_slide
  def move_piece!(from_pos, to_pos)
    piece = self[from_pos]
    
    if !piece.valid_moves.include?(to_pos)
      raise "piece cannot move like that"
    end
    
    self[to_pos] = piece
    self[from_pos] = nil
    piece.pos = to_pos
    
    nil
  end
  
  #a duped board and duped pieces
  def dup
    #like chess
    new_board = Board.new(false)
    
    pieces.each do |piece|
      piece.class.new(piece.color, new_board, piece.pos)
    end
    
    new_board
  end
  
  def empty?(pos)
    self[pos]nil?
  end
  
  # def move_piece(turn_color, from_pos, to_pos)
  #   raise "from position is empty" if empty?(from_pos)
  #   
  #   piece = self[from_pos]
  #   if piece.color != turn_color
  #     raise "move your own piece"
  #   elsif !piece.moves.include?(to_pos)
  #     raise "piece doesn't move like that"
  #   elsif !piece.valid_moves.include?(to_pos)
  #     raise "can't make that move"
  #   end
  # end
  
  #was
  #valid_pos?
  def pos_within_bounds?(pos)
    pos.all? { |coord| coor.between?(0, 7) }
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
