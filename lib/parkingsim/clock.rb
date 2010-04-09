class Clock
  def self.tick
    events = EventQueue.next_events!
    events.each{ |e| e.object.send(e.message)  }
  end
end