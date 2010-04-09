lib_dir = File.join(File.dirname(__FILE__), "parkingsim")

$:.unshift(lib_dir)
$:.uniq!

require 'singleton'
require 'building'
require 'car'
require 'car_factory'
require 'event_queue'
require 'simulation'
