local wibox = require("wibox")
local awful = require("awful")

volume_widget = wibox.widget.textbox()    
volume_widget:set_text(" | Volume | ")    
volume_widgettimer = timer({ timeout = 5 })    
volume_widgettimer:connect_signal("timeout",    
  function()    
    fh = assert(io.popen("amixer sget Master|grep '%'|sed 's/%].*$/%/g;s/^.*\\[//g'", "r"))    
    volume_widget:set_text(" | Vol " .. fh:read("*l") .. " | ")    
    fh:close()    
  end    
)    
volume_widgettimer:start()
