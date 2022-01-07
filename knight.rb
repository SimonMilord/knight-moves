class Graph
  attr_accessor :board, :from

  def initialize(data)
    @from = Vertex.new(data: data)
    @board = Board.new
  end
  # calls on add_neighbors to traverse the graph
  def traverse(to, allowed_moves)
    from.check_queue(board, from, to, allowed_moves)
  end
end

class Vertex
  attr_accessor :data, :parent, :neighbors

  def initialize(data: nil, parent: nil)
    @data = data
    @parent = parent
    @neighbors = {}
  end

  def check_queue(board, from, to, allowed_moves)
    queue = [self]
    # remove first element of the queue until empty and return if current node = target node
    until queue.empty?
      current = queue.shift
      return current.trace_path(from) if current.data == to
      # defines possible destinations given a location on board
      destinations = board.possible_destinations(current.data, allowed_moves)
      # adds new neighbors to each node visited, push them in queue and add visited nodes to visited array
      destinations.each(&add_vertex(board, current, queue))
    end
  end

  # keep track of the path taken
  def trace_path(from)
    path = []
    current = self

    loop do
      path << current.data
      return print_result(path) if current == from
      current = current.parent
    end
  end

  # prints the the path taken once node == target
  def print_result(path)
    puts "You made it in #{path.length - 1} moves! Your path: "
    puts "#{path.reverse}"
  end

  def add_vertex(board, current, queue)
    proc do |destination|
      # add each destination to visited array
      board.visited << destination
      # creates a new node (vertex)
      vertex = Vertex.new(data: destination, parent: current)
      # set the current node's destinations as vertices and add them to the queue
      current.neighbors[destination] = vertex
      queue << vertex
    end
  end
end

class Board
  attr_accessor :visited
  # initialize the visited nodes array and creates a 8x8 board
  def initialize()
    @visited = []
    @board = Array.new { 8.times { |x| 8.times { |y| [x,y] }}}
  end

  # defines possible destinations given possible moves (within bounds)
  def possible_destinations(position, allowed_moves)
    possible_moves = possible_moves(position, allowed_moves)
    destination = proc { |move| [move[0] + position[0], move[1] + position[1]] }
    # goes over the possible move array and transforms coordinates with the move to obtain new node coordinates
    # also removes duplicates and the ones we previously visited
    possible_moves.map(&destination).uniq - visited
  end

  # iterates through all allowed moves given a position and selects the ones not outside of the board
  def possible_moves(position, allowed_moves)
    allowed_moves.select do |move|
      x = position[0] + move[0]
      y = position[1] + move[1]
      board_size = 0..7
      board_size.cover?(x) && board_size.cover?(y)
    end
  end
end

class Knight
  attr_accessor :allowed_moves
  # this array represents allowed moves by the knight (L shaped)
  def initialize
    @allowed_moves = [[-2,  1], [-1,  2], [1,  2], [2,  1],
                      [-2, -1], [-1, -2], [1, -2], [2, -1]].freeze
  end
 # allows to move from to by traversing the graph with allowed moves
  def move(from, to)
    Graph.new(from).traverse(to, allowed_moves)
  end
end

# creates instance of Knight and make him move from "from" to "to"
def knight_moves(*args)
  Knight.new.move(args[0], args[1])
end

knight_moves([1,1],[7,7])