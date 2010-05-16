require 'drive_logic'
require 'logger'

class Car
  include DriveLogic
  extend Logger
  
  attr_accessor :ticks
  attr_reader :building, :current_location, :direction
  attr_reader :park_intention, :drive_intention, :next_action
  
  def initialize(building)
    @building   = building
    @current_location = building.gates[rand(building.gates.length)]
    @direction  = :forward
    @state = :on
    @ticks = 0
    
    Car.log "Car created."
  end
  
  def randomize_direction
    if rand(2) == 0
      @direction = :forward
    else
      @direction = :backward
    end
  end
  
  def to_s
    "Car: #{object_id}"
  end
  
  def on?
    @state == :on
  end
  
  def off?
    @state == :off
  end
  
  def reset!
    # for testing purposes
    initialize(building)
  end
  
  def move!
    Car.log "Car moved to Floor: #{drive_intention[:floor]} - Row: #{drive_intention[:row]}"
    @current_location = drive_intention
    @drive_intention = nil    
  end
  
  def park!
    if building.free_spot?(park_intention)
      Car.log "Car parked at Floor: #{park_intention[:floor]} - Row: #{park_intention[:row]} - Spot: #{park_intention[:spot]}"
      building.take_spot! park_intention
      @state = :off
      true
    else
      Car.log "Car attempted to park at Floor: #{park_intention[:floor]} - Row: #{park_intention[:row]} - Spot: #{park_intention[:spot]}. Looking for a new spot."
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
  
  def action_time
    if self.next_action == :move!
      if drive_intention[:floor] == current_location[:floor]
        1
      else
        3
      end
    elsif next_action == :park!
      park_intention[:spot] + 1
    end
  end
end