class Simulation
  def self.cars
    @@cars ||= []
  end
  
  def self.available_cars
    cars.reject { |car| EventQueue.instance.events.find{ |e| e.object == car } }
  end
  
  def self.tick
    send_messages_to_objects
    look_for_new_cars
    add_new_events_to_queue
  end
  
  def self.look_for_new_cars
    CarFactory.instance.tries_per_tick.times do
      new_car = CarFactory.attempt_creation
      unless new_car.nil?
        new_car.randomize_direction
        cars << new_car
      end
    end
  end
  
  def self.add_new_events_to_queue
    available_cars.each do |car|
      if car.on?
        car.decide_next_action!
        EventQueue.add_event(car, car.next_action, car.action_time)
      end
    end
  end
  
  def self.send_messages_to_objects
    events = EventQueue.next_events!
    events.each{ |e| e.object.send(e.message) }
  end
end