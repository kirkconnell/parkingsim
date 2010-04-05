class Building
  attr_reader :floors, :rows, :spots
  attr_reader :gates
  
  def initialize(dimensions=nil)
    @gates = [{:floor => 0, :row => 0}]
    self.dimensions(dimensions) unless dimensions.nil?
  end
  
  def dimensions(options={})
    @array  = []
    @floors = options[:floors]
    @rows   = options[:rows]
    @spots  = options[:spots]
    
    self.floors.times do |floor|
      @array << []
      self.rows.times do |row|
        @array[floor] << []
        self.spots.times { @array[floor][row] << false }
      end
    end
    @array
  end
  
  def to_ar
    @array
  end
  
  def free_spots_on(location)
    free_spots = []
    row = @array[location[:floor]][location[:row]]
    self.spots.times { |spot| free_spots << spot unless row[spot] }
    free_spots
  end
  
  def free_spot?(location)
    !@array[location[:floor]][location[:row]][location[:spot]]
  end
  
  def take_spot!(location)
    if free_spot?(location)
      @array[location[:floor]][location[:row]][location[:spot]] = true
    else
      raise "You crashed! There was a car already on that spot."  # this should never happen.
    end
  end
  
  def release_spot!(location)
    unless free_spot?(location)
      @array[location[:floor]][location[:row]][location[:spot]] = false
    else
      raise "A car came from another dimension and moved out of the parking lot!" # this should never happen.
    end
  end
  
end