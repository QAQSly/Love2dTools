local FlexLove = require("FlexLove")
local Color = FlexLove.Color
function love.load()
  -- (Optional) Initialize with a theme and immediate mode
  FlexLove.init({
    theme = "space",
    immediateMode = true
  })
end

function love.update(dt)
  FlexLove.update(dt)
end

function love.draw()
    FlexLove.draw(function()
        -- Game content (will be blurred by backdrop blur)
        local button = FlexLove.new({
        width = "20vw",
        height = "10vh",
        backgroundColor = Color.new(0.2, 0.2, 0.8, 1),
        text = "点击",
        textSize = "md",
        themeComponent = "button",
        onEvent = function(element, event)
            print("this!")
    end
    })
    end, function()
        -- This is drawn AFTER all GUI elements - no backdrop blur
        -- SomeMetaComponent:draw()
    end)
end

function love.load()
    FlexLove.init({
        theme = "space",
        immediateMode = true,
        debugDraw = true,  -- Enable debug view
        debugDrawKey = "F3"  -- Toggle debug view with F3 key
    })
end