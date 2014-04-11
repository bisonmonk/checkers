#a non-king Piece can move forward ony; kings can move backward and forward

class Piece
  attr_reader :board, :color
  attr_accessor :pos, :is_king
  
  def initialize(color, board, pos)
    @is_king = false
    
    raise "invalid color" unless [:red, :black].include?(color)
    raise "invalid pos" unless board.valid_pos?(pos)
    
    @color, @board, @pos = color, board, pos
    
    board.add_piece(self, pos)
  end
  
  #trace for a move/move_sequence is
  #perform_moves
  # => valid_move_seq?
  # =>    if false 
  #board.perform_moves(color, from_pos, move_sequence)
  def perform_moves(move_sequence)
    if valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
    else
      raise "cannot perform that move(s)"
      #throw an InvalidMoveError
    end
    #first checks valid_move_seq?, THEN
    #either calls perform_moves! or raises an
    #InvalidMoveError
  end
  
  def perform_slide(to_pos)
    unless self.valid_moves.include?(to_pos)
      raise "cannot perform that slide move"
    end
    board.move_piece!(self.pos, to_pos)
  end
  
  
  
  def perform_jump(to_pos)
    #should remove the jumped piece from the Board
    unless self.valid_moves.include?(to_pos)
      raise "cannot perform that jump move"
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
  #does perform moves need to be passed a board??????
  def valid_move_seq?(move_sequence)
    duped_board = Board.dup
    
    begin
      perform_moves!(move_sequence, duped_board)
    rescue InvalidMoveError => e
      puts "error: #{e.message}"
      return false
    end
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
  def perform_moves!(move_sequence, a_board = self.board)
    #should perform the moves one-by-one
    #if a move in the sequence fails, and InvalidMoveError should
    #be raised
    
    if move_sequence.count == 1
      begin
        perform_slide(move_sequence.first)
      rescue
        perform_jump(move_sequence.first)
      end
    elsif move_sequence.count > 1
      perform_jump(move_sequence.first)
      perform_moves!(move_sequence[1..-1], a_board)
    end  
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
    
    #red starts at top
    #black starts at bottom
    
    #switch move_diffs according to the players color
    if self.color == :black
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
  
  #● black piece
  #○ red piece
  
  #◆ black diamond - king
  #◇ red diamond - king
  
  def render
    if self.color == :red 
      return "◇" if self.is_king
      return "○"
    else
      return "◆" if self.is_king
      return "●"
    end
  end
  
end



class Board
  attr_accessor #:grid
  
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
    board[[row, col]] = nil
  end
  
  def make_moves(turn_color, from_pos, move_sequence)
    raise "from position is empty" if empty?(from_pos)
    
    piece = self[from_pos]
    
    if piece.color != turn_color
      raise "move your own piece"
      #elsif !piece.valid_moves.include?(to_pos)
      #elsif !piece.valid_move_sequence?(move_sequence)
      #raise "piece cannot move like that"
    elsif !pos_within_bounds?(from_pos)
      raise "piece cannot move out of board boundaries"
    end
    
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    piece.perform_moves(move_sequence)
  end
  
  #move without performing checks,
  #checks have been made in perform_jump
  #and perform_slide
  #called from within Pieces
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
    self[pos].nil?
  end
  
  #was
  #valid_pos?
  def pos_within_bounds?(pos)
    pos.all? { |coord| coor.between?(0, 7) }
  end
  
  def pieces
    grid.flatten.compact
  end
  
  def no_pieces?(color)
    pieces = pieces.select { |piece| piece.color == color }
    pieces.empty?
  end
  
  #assignment method
  protected
  def []=(pos, piece)
    raise "invalid pos" unless valid_pos?(pos)

    i, j = pos
    @grid[i][j] = piece
  end
  
  def make_starting_grid(fill_board)
    @grid = Array.new(8) { Array.new(8) }
    color = :red
    cols = [1, 3, 5, 7]
    rows = [0, 1, 2, 5, 6, 7]
    rows.each do |row|
      if row > 3
        color = :black
      end
      if row.even?
        cols.map! { |col| col - 1}
      else
        cols.map! { |col| col + 1}
      end
      cols.each do |col|
        self[[row, col]] = Piece.new(color, self, [row, col])
      end
    end
  end
  
  def opposing_color(color)
    if color == :red
      :black
    else
      :red
    end
  end
  
  def render
    square_color = :red

    (0...grid.length).each do |row|
      square_color = opposing_color(square_color)
      print "#{8 - row} "
      (0...grid[row].length).each do |col|
        square = self.board.at([row, col])
        if square.is_a?(Piece)
          print square.render + ' '
        else
          ################################
          print square.render + ' '
          #######################
        end
        square_color = opposing_color(square_color)
      end
      print "\n"
    end
    puts " a b c d e f g h"
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
    @current_player = :red
    @move_hash = build_move_hash
  end
  
  def play
    until board.no_pieces?(current_player)
      players[current_player].play_turn(board)
      @current_player = (current_player == :red) ? :black : :red
    end
    #need to implement Board#render
    puts board.render
    puts "#{current_player} has LOST!!!"
  end

  
  def build_move_hash
    move_hash = {}
    col = 0
    ('a'..'h').to_a.each do |letter|
      8.downto(1).to_a.each do |row|
        move = letter + row.to_s
        move_hash[move] = [8-row, col]
      end
      col += 1
    end
    move_hash
  end
end

class HumanPlayer
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def play_turn(board)
    begin
      puts board.render
      puts "Current player: #{color}"

      from_pos = get_pos("From pos:", board)
      
      #Need to allow a move_sequence
      move_sequence = get_sequence("Sequence of moves: ", board)
      
      #to_pos = get_pos("To pos:")
      board.make_moves(color, from_pos, move_sequence)
    rescue InvalidMoveError => e
      puts "Error: #{e.message}"
      retry
    end
  end

  private
  def get_pos(prompt, board)
    puts prompt
    board.move_hash[gets.chomp]
  end
  
  def get_sequence(prompt, board)
    puts prompt
    gets.chomp.split(" ").map { |move| board.move_hash[move]}
  end
end

class InvalidMoveError < StandardError
end
