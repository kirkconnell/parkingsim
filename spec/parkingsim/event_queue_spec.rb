require 'spec_helper'

describe EventQueue do
  let(:object){ mock("object", :message => "hello!") }
  
  before(:each) do
    EventQueue.instance.events.clear
  end
  
  it "should be a singleton" do
    EventQueue.should be_respond_to :instance
    expect {EventQueue.new}.to raise_error
  end
  
  it "should accept events" do
    EventQueue.add_event(object, :message)
  end
  
  it "should decrease the timers of all the current events" do
    EventQueue.add_event(object, :message, 1)
    EventQueue.add_event(object, :message, 2)
    EventQueue.add_event(object, :message, 3)
    
    EventQueue.instance.decrease_timers!
    
    EventQueue.instance.events[0].timer.should == 0
    EventQueue.instance.events[1].timer.should == 1
    EventQueue.instance.events[2].timer.should == 2
  end
  
  it "should give me the next events to call" do
    e1 = EventQueue.add_event(object, :message, 1)
    e2 = EventQueue.add_event(object, :message, 1)
    EventQueue.add_event(object, :message, 2)
    EventQueue.add_event(object, :message, 3)
    
    t1, t2 = EventQueue.next_events!
    
    e1.should == t1
    e2.should == t2
  end
  
  it "should remove events that are ran" do
    EventQueue.add_event(object, :message, 1)
    EventQueue.add_event(object, :message, 1)
    EventQueue.add_event(object, :message, 2)
    EventQueue.add_event(object, :message, 3)
    
    EventQueue.next_events!
    
    EventQueue.instance.events.length.should == 2
  end
  
  it "should return an empty array if no events are in the queue" do
    EventQueue.next_events!.should be_empty
  end
end