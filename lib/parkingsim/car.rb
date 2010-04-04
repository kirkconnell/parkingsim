class Car
  attr_reader :driving_by, :building
  attr_reader :spot_intention, :next_move
  
  def initialize(building)
    @driving    = true
    @building   = building
    @driving_by = building.gates[rand(building.gates.length)]
  end
  
  def reset!
    initialize(self.building)
  end
  
  def driving?
    @driving
  end
  
  def suggest_a_spot
    suggested_spot = self.building.free_spots_on(driving_by).first
    if suggested_spot.nil?
      nil
    else
      self.driving_by.merge(:spot => suggested_spot)
    end
  end
  
  def decide_next_move
    suggested_spot = self.suggest_a_spot
    if suggested_spot.nil?
      @next_move = "move!"
    else
      @spot_intention = suggested_spot
      @next_move = "park!"
    end
  end
  
end