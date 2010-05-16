#!/usr/bin/env ruby

require '../lib/parkingsim'

def parked_cars
  Simulation.cars.inject(0) { |sum, c| sum + (c.off? ? 1 : 0) }
end

def avg_ticks
  total_ticks = Simulation.cars.inject(0) { |sum, c| sum + (c.off? ? c.ticks : 0) }
  total_ticks.to_f / parked_cars.to_f
end

def stop_condition(options)
  building = options[:building]
  if options[:stop] == :full_building
    parked_cars == (building.floors * building.rows * building.spots)
  else
    (Simulation.cars.select { |car| car.on? }).empty? && Simulation.cars.length >= options[:max_cars]
  end
end

def new_gate(time)
  case time
    when 0 then {:floor => 0, :row => 0}
    when 1 then {:floor => 2, :row => 2}
    when 2 then {:floor => 1, :row => 1}
    when 3 then {:floor => 0, :row => 2}
    when 4 then {:floor => 2, :row => 0}
    else nil
  end
end

def simulate(options={})
  CarFactory.instance.building = options[:building]
  begin
    yield if block_given?
    Simulation.tick
  end until stop_condition(options)
end


print "Avg Ticks by Number of Cars\n"
(1..27).each do |max_cars|
  CarFactory.instance.probability = 1
  building = Building.new :floors => 3, :rows => 3, :spots => 3
  
  simulate(:building => building, :max_cars => max_cars, :stop => :all_cars_parked) do
    CarFactory.instance.probability = 0 if Simulation.cars.length >= max_cars
  end
  print "Average Ticks: #{avg_ticks}\n"
  
  Simulation.reset
end

print "Avg Ticks by Number of Gates\n"
(1..5).each do |number_of_gates|
  CarFactory.instance.probability = 1.0 / number_of_gates
  CarFactory.instance.tries_per_tick = number_of_gates
  building = Building.new :floors => 3, :rows => 3, :spots => 3
  building.gates.clear
  number_of_gates.times { |time| building.gates << new_gate(time) }
  
  simulate(:building => building, :stop => :full_building)
  print "Average Ticks: #{avg_ticks}\n"
  
  Simulation.reset
end

print "Avg Ticks by Number of Floors\n"
(1..10).each do |floors|
  CarFactory.instance.probability = 1
  CarFactory.instance.tries_per_tick = 1
  building = Building.new :floors => floors, :rows => 3, :spots => 3
  
  simulate(:building => building, :stop => :full_building)
  print "Average Ticks: #{avg_ticks}\n"
  
  Simulation.reset
end

print "Avg Ticks by Number of Rows\n"
(1..10).each do |rows|
  CarFactory.instance.probability = 1
  CarFactory.instance.tries_per_tick = 1
  building = Building.new :floors => 3, :rows => rows, :spots => 3
  
  simulate(:building => building, :stop => :full_building)
  print "Average Ticks: #{avg_ticks}\n"
  
  Simulation.reset
end

print "Avg Ticks by Number of Spots\n"
(1..10).each do |spots|
  CarFactory.instance.probability = 1
  CarFactory.instance.tries_per_tick = 1
  building = Building.new :floors => 3, :rows => 3, :spots => spots
  
  simulate(:building => building, :stop => :full_building)
  print "Average Ticks: #{avg_ticks}\n"
  
  Simulation.reset
end


