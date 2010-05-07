# message_log_delegate.rb
# parkingsim
#
# Created by Kirkconnell on 4/21/10.
# Copyright 2010 High Notes. All rights reserved.

class MessageLogDelegate
  attr_accessor :parent
  
  def numberOfRowsInTableView(tableView)
	  parent.logged_messages.length
  end
  
  def tableView(tableView, objectValueForTableColumn:column, row:row)
  	if row < parent.logged_messages.length
  	  if column.identifier == "time"
  		  parent.logged_messages[row].first.strftime("%I:%M:%S %p")
  	  else
  		  parent.logged_messages[row].last
  	  end
  	end
  end
end

