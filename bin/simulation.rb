#!/usr/bin/env ruby

require '../lib/parkingsim'

Car.display_delegate { |message| puts message }

building = Building.new :floors => 3, :rows => 3, :spots => 3
car = Car.new(building)
Simulation.cars << car
CarFactory.instance.building = building

car.decide_next_action!
EventQueue.add_event(car, car.next_action)

begin 
  Simulation.tick
  p "Continue(y/n)? "
end until(STDIN.gets == "n")


