local function initLuis(widgetPath)
    local luis = require("luis.core")

    -- Explicitly load all widgets instead of using getDirectoryItems()
    -- This ensures compatibility with packaged Love2d applications
    luis.widgets = {}

    local widgets = {
        "button", "checkBox", "colorPicker", "custom", "dialogueBox",
        "dialogueWheel", "dropDown", "flexContainer", "icon", "label",
        "node", "progressBar", "radioButton", "slider", "switch",
        "textInput", "textInputMultiLine"
    }

    for _, widget_name in ipairs(widgets) do
        local success, widget = pcall(require, "luis.widgets." .. widget_name)
        if success then
            widget.setluis(luis)
            luis.widgets[widget_name] = widget
            luis["new" .. widget_name:gsub("^%l", string.upper)] = widget.new
            print("[LUIS] Loaded widget: " .. widget_name)
        else
            print("[LUIS] Failed to load widget: " .. widget_name .. " - " .. tostring(widget))
        end
    end

    return luis
end

return initLuis