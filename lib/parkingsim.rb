lib_dir = File.join(File.dirname(__FILE__), "parkingsim")

$:.unshift(lib_dir)
$:.uniq!

require 'building'
