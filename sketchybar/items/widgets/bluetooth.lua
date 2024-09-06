local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 200

local bluetooth = sbar.add("item", "widgets.bluetooth", {
    position = "right",
    icon = {
        width = 18,
        string = icons.bluetooth.off,
        color = colors.red,
        align = 'center',
        padding_left = 7.5,
    },
    popup = { align = "center" }
})

sbar.add("item", { position = "right", width = settings.group_paddings })

sbar.add("bracket", "widgets.bluetooth.bracket", {
    bluetooth.name,
}, {
    background = { color = colors.bg1 },
    popup = { align = "center" }
})

local device_nearby = sbar.add("item", {
    position = "popup." .. bluetooth.name,
    label = {
        string = "??",
        width = popup_width,
        align = "right"
    }
})

bluetooth:subscribe("mouse.clicked", function(env)
    local drawing = bluetooth:query().popup.drawing
    bluetooth:set({ popup = { drawing = "toggle" } })

    local is_bluetooth_on = false
    sbar:exec("blueutil --power", function(result)
        is_bluetooth_on = result:find("1") ~= nil

        device_nearby:set({
            label = is_bluetooth_on and "Turn Bluetooth Off" or "Turn Bluetooth On",
        })
    end)
end)
