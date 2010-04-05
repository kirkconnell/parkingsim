module DriveLogic
  def look_for_spot
    suggested_spot = building.free_spots_on(current_location).first
    if suggested_spot.nil?
      nil
    else
      current_location.merge(:spot => suggested_spot)
    end
  end
  
  def decide_next_row!
    row = next_direction(current_location[:row])
    if valid_bounds(row, :type => :rows)
      @drive_intention = current_location.merge(:row => row)
    else
      floor = next_direction(current_location[:floor])
      if valid_bounds(floor, :type => :floors)
        @drive_intention = {:floor => floor, :row => first_row}
      else
        invert_direction!
        decide_next_row!
      end
    end
  end
  
  def invert_direction!
    @direction = direction == :forward ? :backward : :forward
  end
  
  def next_direction(number)
    if direction == :forward
      number + 1
    else
      number - 1
    end
  end
  
  def valid_bounds(number, options={})
    options[:type] ||= :rows
    if direction == :forward
      number < building.send(options[:type])
    else
      number >= 0
    end
  end
  
  def first_row
    direction == :forward ? 0 : building.rows - 1
  end
end