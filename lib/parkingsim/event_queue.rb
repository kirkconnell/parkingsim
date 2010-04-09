class EventQueue
  include Singleton
  
  attr_reader :events
  
  def initialize
    @events = []
    @@event = Struct.new("Event", :object, :message, :timer)
  end
  
  def self.add_event(object, message, timer = 1)
    @@event ||= Struct.new("Event", :object, :message, :timer)
    e = @@event.new(object, message, timer)
    instance.events << e
    e
  end
  
  def self.next_events!
    instance.decrease_timers!
    result = instance.events.find_all { |e| e.timer == 0 }
    result.each { |r| instance.events.delete_if { |e| e == r  }  }
    result
  end
  
  def decrease_timers!
    events.each { |e| e.timer -= 1 }
  end
end