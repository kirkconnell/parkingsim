require 'drive_logic'

class Car
  include DriveLogic
  attr_reader :building, :current_location, :direction
  attr_reader :park_intention, :drive_intention, :next_action
  
  def initialize(building)
    @building   = building
    @current_location = building.gates[rand(building.gates.length)]
    @direction  = :forward
  end
  
  def reset!
    initialize(building)
  end
  
  def move!
    @current_location = drive_intention
    @drive_intention = nil
  end
  
  def park!
    # todo: if this ever goes multithread, then we need to synchronize this method
    if building.free_spot?(park_intention)
      building.park_at! park_intention
      true
    else
      decide_next_action!
      false
    end
  end
    
  def decide_next_action!
    suggested_spot = self.look_for_spot
    if suggested_spot.nil?
      decide_next_row!
      @park_intention = nil
      @next_action = :move!
    else
      @park_intention = suggested_spot
      @drive_intention = nil
      @next_action = :park!
    end
  end
end