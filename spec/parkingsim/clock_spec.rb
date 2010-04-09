require 'spec_helper'

describe Clock do
  before(:all) do
    EventQueue.instance.events.clear
  end
  
  it "should get the next events from the event queue" do
    EventQueue.should_receive(:next_events!).and_return([])
    Clock.tick
  end
  
  it "should send the message to the objects" do
    object = mock("object", :message => "hello!")
    EventQueue.add_event(object, :message)
    object.should_receive(:message).and_return("hello!")
    Clock.tick
  end
end