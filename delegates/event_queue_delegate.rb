# event_queue_delegate.rb
# parkingsim
#
# Created by Kirkconnell on 5/7/10.
# Copyright 2010 High Notes. All rights reserved.

class EventQueueDelegate
  attr_accessor :parent
  
  def numberOfRowsInTableView(tableView)
	  EventQueue.instance.events.length
  end
  
  def tableView(tableView, objectValueForTableColumn:column, row:row)
	  if row < EventQueue.instance.events.length
		  EventQueue.instance.events[row].send(column.identifier).to_s
	  end
  end
end

