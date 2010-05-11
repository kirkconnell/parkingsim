class Simulation
  def self.cars
    @@cars ||= []
  end
  
  def self.tick
    send_messages_to_objects
    look_for_new_cars
    add_new_events_to_queue
  end
  
  def self.look_for_new_cars
    new_car = CarFactory.attempt_creation
    cars << new_car unless new_car.nil?
  end
  
  def self.add_new_events_to_queue
    cars.each do |car|
      if car.on?
        car.decide_next_action!
        EventQueue.add_event(car, car.next_action)
      end
    end
  end
  
  def self.send_messages_to_objects
    events = EventQueue.next_events!
    events.each{ |e| e.object.send(e.message) }
  end
end