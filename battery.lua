local wibox = require("wibox")
local awful = require("awful")

-- batterywidget = wibox.widget.textbox()    
-- batterywidget:set_text(" | Battery | ")    
-- batterywidgettimer = timer({ timeout = 5 })    
-- batterywidgettimer:connect_signal("timeout",    
--   function()    
--     fh = assert(io.popen("acpi | cut -d, -f 2 -|tr -d '\n'", "r"))
--     -- fh = assert(io.popen("acpi | awk -F ',' '{temp=temp+$2} END {print temp/2\"%\"}'", "r"))
--     warning_number = assert(io.popen("acpi |cut -d, -f 2 -
--     batterywidget:set_text(" | Bat " .. fh:read("*l") .. " | ")    
--     fh:close()    
--   end    
-- )    
-- batterywidgettimer:start()

local io = io
local math = math
local naughty = naughty
local beautiful = beautiful
local tonumber = tonumber
local tostring = tostring
local print = print
local pairs = pairs

local limits = {{25, 5},
          {12, 3},
          { 7, 1},
            {0}}

function get_bat_state (adapter)
    local fcur = io.open("/sys/class/power_supply/"..adapter.."/energy_now")
    local fcap = io.open("/sys/class/power_supply/"..adapter.."/energy_full")
    local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
    local cur = fcur:read()
    local cap = fcap:read()
    local sta = fsta:read()
    fcur:close()
    fcap:close()
    fsta:close()
    local battery = math.floor(cur * 100 / cap)
    if sta:match("Charging") then
        dir = 1
    elseif sta:match("Discharging") then
        dir = -1
    else
        dir = 0
    end
    return battery, dir
end

function getnextlim (num)
    for ind, pair in pairs(limits) do
        lim = pair[1]; step = pair[2]; nextlim = limits[ind+1][1] or 0
        if num > nextlim then
            repeat
                lim = lim - step
            until num > lim
            if lim < nextlim then
                lim = nextlim
            end
            return lim
        end
    end
end


function batclosure (adapter)
    local nextlim = limits[1][1]
    return function ()
        local prefix = "⚡"
        local battery, dir = get_bat_state(adapter)
        if dir == -1 then
            dirsign = "↓"
            prefix = "Bat:"
            if battery <= nextlim then
                naughty.notify({title = "⚡ Beware! ⚡",
                            text = "Battery charge is low ( ⚡ "..battery.."%)!",
                            timeout = 7,
                            position = "bottom_right",
                            fg = beautiful.fg_focus,
                            bg = beautiful.bg_focus
                            })
                nextlim = getnextlim(battery)
            end
        elseif dir == 1 then
            dirsign = "↑"
            nextlim = limits[1][1]
        else
            dirsign = ""
        end
        battery = battery.."%"
        return " "..prefix.." "..dirsign..battery..dirsign.." "
    end
end


batterywidget = wibox.widget.textbox()
bat_clo = batclosure("BAT0")
bat_clo2 = batclosure("BAT1")
batterywidget:set_text(" | Battery | ")
battimer = timer({ timeout = 5 })
battimer:connect_signal("timeout", function() batterywidget:set_text(bat_clo()..bat_clo2()) end)
battimer:start()
