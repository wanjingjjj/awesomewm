local wibox = require("wibox")
local awful = require("awful")

batterywidget = wibox.widget.textbox()    
batterywidget:set_text(" | Battery | ")    
batterywidgettimer = timer({ timeout = 5 })    
batterywidgettimer:connect_signal("timeout",    
  function()    
    -- fh = assert(io.popen("acpi | cut -d, -f 2,3 -|tr '\n' ' '", "r"))
    fh = assert(io.popen("acpi | awk -F ',' '{temp=temp+$2} END {print temp/2\"%\"}'", "r"))    
    batterywidget:set_text(" | Bat " .. fh:read("*l") .. " | ")    
    fh:close()    
  end    
)    
batterywidgettimer:start()
