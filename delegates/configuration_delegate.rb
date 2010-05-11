# configuration_delegate.rb
# parkingsim
#
# Created by Kirkconnell on 5/11/10.
# Copyright 2010 High Notes. All rights reserved.

class ConfigurationDelegate
  attr_accessor :parent
  attr_accessor :car_probability, :max_cars_per_gate, :floors, :rows, :spots
  attr_accessor :gates_table, :add_gate_button, :remove_gate_button
    
  # window delegate
  def windowDidBecomeKey(notification)
    max_cars_per_gate.integerValue = 1
    car_probability.floatValue = CarFactory.instance.probability
    floors.integerValue = parent.building.floors
    rows.integerValue = parent.building.rows
    spots.integerValue = parent.building.spots
    gates_table.reloadData
  end
  
  def submit_configuration(sender)
    parent.configure  :cars_per_gate => max_cars_per_gate.integerValue,
                      :probability => car_probability.floatValue,
                      :dimensions => { :floors => floors.integerValue, :rows => rows.integerValue, :spots => spots.integerValue },
                      :gates => parent.building.gates
                      
    hide_configuration sender
  end
  
  def hide_configuration(sender)
	  NSLog "Configuration Saved"
    NSApp.endSheet(parent.configuration_window)
    parent.configuration_window.orderOut(sender)
  end
  
  def add_gate(sender)
    parent.building.gates << {:floor => 0, :row => 0}
    gates_table.reloadData
  end
  
  def remove_gate(sender)
    parent.building.gates.delete_at gates_table.selectedRow
    gates_table.reloadData
  end
  
  # table delegate
  def numberOfRowsInTableView(tableView)
	  parent.building.gates.length
  end
  
  def tableView(tableView, objectValueForTableColumn:column, row:row)
	  if row < parent.building.gates.length
	    parent.building.gates[row][column.identifier.to_sym].to_s
	  end
  end
  
  def tableView(tableView, setObjectValue:object, forTableColumn:column, row:row)
    if row < parent.building.gates.length
      parent.building.gates[row][column.identifier.to_sym] = object.to_s.to_i
    end
  end
  
  def tableViewSelectionDidChange(notification)
    remove_gate_button.enabled = can_remove?
  end
  
  def can_remove?
    gates_table.selectedRow != -1 && parent.building.gates.length > 1
  end
end
