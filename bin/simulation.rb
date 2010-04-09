#!/usr/bin/env ruby

require '../lib/parkingsim'

Car.display_delegate { |message| puts message }

building = Building.new :floors => 3, :rows => 3, :spots => 3
car = Car.new(building)
CarFactory.instance.building = building

car.decide_next_action!
EventQueue.add_event(car, car.next_action)

Clock.tick
