class Simulation
  def self.cars
    @@cars ||= []
  end
  
  def self.tick
    send_messages_to_objects
    car = CarFactory.attempt_creation
    cars << car unless car.nil?
    
  end
  
  def self.send_messages_to_objects
    events = EventQueue.next_events!
    events.each{ |e| e.object.send(e.message) }
  end
end