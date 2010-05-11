require 'roller'

class CarFactory
  include Singleton
  include Roller
  attr_accessor :building
  attr_accessor :tries_per_tick
  
  def initialize
    self.probability = 0.8
    self.tries_per_tick = 1
  end
  
  def self.attempt_creation
    Car.new(instance.building) if instance.win?
  end  
end
