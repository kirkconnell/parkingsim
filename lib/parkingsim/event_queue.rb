class EventQueue
  include Singleton
  attr_reader :events
  
  class Event
    attr_accessor :object, :message, :timer
    
    def initialize(object, message, timer)
      self.object = object
      self.message = message
      self.timer = timer
    end
  end
  
  def initialize
    @events = []
  end
  
  def self.add_event(object, message, timer = 1)
    e = Event.new(object, message, timer)
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