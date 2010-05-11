# application_delegate.rb
# parkingsim
#
# Created by Kirkconnell on 4/19/10.
# Copyright 2010 High Notes. All rights reserved.
require 'message_log_delegate'
require 'event_queue_delegate'
require 'configuration_delegate'

class ApplicationDelegate

  attr_accessor :play_button, :configure_button
  attr_accessor :event_log_table, :event_queue_table
  attr_accessor :total_label, :running_label, :parked_label
  attr_accessor :main_window, :configuration_window
  attr_reader   :logged_messages, :building
  
  def initialize
  	@logged_messages = []
  	@running = false
  end

  def applicationDidFinishLaunching(notification)
  	NSLog "Loading Simulation..."
  	configure
  	Car.display_delegate { |msg| @logged_messages << [Time.now, msg] }
  	NSLog "Simulation Ready."
  end
  
  def start_simulation(sender)
  	unless @running
  	  @running = true
  	  NSLog "Starting Simulation..."
  	  @timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, 
  				selector: "tick", userInfo:nil, repeats:true)
  	  play_button.title = "Stop"
  	  configure_button.enabled = false
  	else
  	  @running = false
  	  @timer.invalidate
  	  NSLog "Stopping Simulation."
  	  play_button.title = "Run"
  	  configure_button.enabled = true
  	end
  end
  
  def show_config_sheet(sender)
    NSApp.beginSheet(configuration_window,
                         modalForWindow:main_window,
                         modalDelegate:nil,
                         didEndSelector:nil,
                         contextInfo:nil)
  end
  
  def tick
  	Simulation.tick
  	refresh_ui
  end
  
  def refresh_ui
    event_log_table.reloadData
  	event_log_table.scrollRowToVisible(logged_messages.length - 1)
  	event_queue_table.reloadData
  	
  	total_label.stringValue = Simulation.cars.length.to_s
  	running_label.stringValue = (Simulation.cars.inject(0) { |sum, c| sum + (c.on? ? 1 : 0) }).to_s
  	parked_label.stringValue = (Simulation.cars.inject(0) { |sum, c| sum + (c.off? ? 1 : 0) }).to_s
  end
  
  def configure(config={})
    config[:dimensions] ||= {:floors => 3, :rows => 3, :spots => 3}
    config[:probability] ||= 0.5
    config[:cars_per_gate] ||= 1
    config[:gates] ||= [{:floor => 0, :row => 0}]

    @building = Building.new(config[:dimensions])
    @building.gates = config[:gates]
  	CarFactory.instance.probability = config[:probability]
  	CarFactory.instance.building = @building
  	
  	logged_messages.clear
  	Simulation.cars.clear
  	EventQueue.instance.events.clear
  end
end
