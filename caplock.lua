local wibox = require("wibox")
local awful = require("awful")

caplock_widget = wibox.widget.textbox()
caplock_widget:set_align("right")

function update_caplock(widget)
   local fd = io.popen("xset q|grep -i cap|awk '{print $4}'")
   local status = fd:read("*all")
   fd:close()

   -- starting colour
   -- local sr, sg, sb = 0x3F, 0x3F, 0x3F
   -- ending colour
   -- local er, eg, eb = 0xDC, 0xDC, 0xCC

   -- local ir = math.floor(volume * (er - sr) + sr)
   -- local ig = math.floor(volume * (eg - sg) + sg)
   -- local ib = math.floor(volume * (eb - sb) + sb)
   -- interpol_colour = string.format("%.2x%.2x%.2x", ir, ig, ib)
   interpol_colour = "3F3F3F"
   if string.find(status, "on", 1, true) then
       caplock = " <span color='red' background='#" .. interpol_colour .. "'> A  </span>"
   else
       caplock = " <span background='#" .. interpol_colour .. "'> a </span>"
   end
   widget:set_markup(caplock)
end

update_caplock(caplock_widget)

mytimer = timer({ timeout = 1 })
mytimer:connect_signal("timeout", function () update_caplock(caplock_widget) end)
mytimer:start()
