-----------------------------------------------
-- LUIS UI Demo - 精简版（布局 + 文件拖入 + 中文字体）
-----------------------------------------------

local initluis = require("luis.init")
local luis = initluis("luis/widgets")
luis.flux = require("luis.3rdparty.flux")
-- 文件拖入变量
local droppedFilePath = nil
local droppedFileContent = nil
local fileStatusText = "将文件拖拽到这里..."

-- 全局引用，方便更新
local fileStatusLabel = nil
local fileContentLabel = nil

function love.load()
    -- 设置窗口
    luis.baseWidth = 1280
    luis.baseHeight = 800
    love.window.setMode(luis.baseWidth, luis.baseHeight)
    
    -- ===== 中文字体设置 =====
    -- 方案1：使用系统自带的中文字体（推荐，无需额外文件）
    -- local chineseFont = love.graphics.newFont("SimHei.ttf", 16)  -- Windows 黑体
    -- 或者使用微软雅黑
    -- local chineseFont = love.graphics.newFont("msyh.ttc", 16)
    
    -- 方案2：如果系统字体不可用，使用你之前用的字体
    local chineseFont = love.graphics.newFont("FlexLove/themes/space/AlibabaPuHuiTi-3-105-Heavy.ttf", 16)
    
    -- 如果没有中文字体文件，使用默认字体（可能无法显示中文）
    if not chineseFont then
        chineseFont = love.graphics.newFont(16)
    end
    
    love.graphics.setFont(chineseFont)
    
    -- 设置 LUIS 主题字体
    luis.theme.text.font = chineseFont
    luis.theme.flexContainer.padding = 2
    -- 设置网格大小
    luis.gridSize = 10
    
    -- 创建图层
    luis.newLayer("main")
    
    -- 创建主容器
    local mainContainer = luis.createElement("main", "FlexContainer", 128, 80, 1, 1, nil, "Main")
    
    -- ===== 头部 =====
    local header = luis.newFlexContainer(128, 8, 1, 1, nil, "Header")
    local aside = luis.newFlexContainer( 12, 70, 1, 9, nil, "aside")
    mainContainer:addChild(header)
    mainContainer:addChild(aside)

    header:addChild(luis.createElement("main", "Label", "Excel转表工具", 40, 2, 1, 1))

    aside:addChild(luis.createElement("main", "Button", "转表", 10, 2, function() print('Menu Item 1 - click') end, function() print('Menu Item 1 - release') end, 1, 1))
    aside:addChild(luis.createElement("main", "Button", "转表", 10, 2, function() print('Menu Item 1 - click') end, function() print('Menu Item 1 - release') end, 1, 1))
    aside:addChild(luis.createElement("main", "Button", "转表", 10, 2, function() print('Menu Item 1 - click') end, function() print('Menu Item 1 - release') end, 1, 1))
    aside:addChild(luis.createElement("main", "Button", "转表", 10, 2, function() print('Menu Item 1 - click') end, function() print('Menu Item 1 - release') end, 1, 1))
    aside:addChild(luis.createElement("main", "Button", "转表", 10, 2, function() print('Menu Item 1 - click') end, function() print('Menu Item 1 - release') end, 1, 1))
    aside:addChild(luis.createElement("main", "Button", "转表", 10, 2, function() print('Menu Item 1 - click') end, function() print('Menu Item 1 - release') end, 1, 1))
    
    -- ===== 内容区域 =====
    local contentArea = luis.newFlexContainer(112, 70, 20, 9, nil, "Content Area")
    mainContainer:addChild(contentArea)
    
    -- 文件拖拽区域提示
    local dropHint = luis.createElement("main", "Label", "拖拽文件到此区域", 30, 2, 1, 1)
    contentArea:addChild(dropHint)
    
    -- 文件状态显示
    fileStatusLabel = luis.createElement("main", "Label", fileStatusText, 30, 2, 1, 1)
    contentArea:addChild(fileStatusLabel)
    
    -- 文件内容显示
    fileContentLabel = luis.createElement("main", "Label", "文件内容将显示在这里...", 100, 10, 1, 1)
    contentArea:addChild(fileContentLabel)

    -- Excel 列名显示
    local editItems = {"Revert", "Insert", "Copy", "Paste", "Comment", "Block", "Reset"}
	editFunc = function(self, item)
		print(item)
	end
	-- this DropDown is placed directly ont he "main" Layer. The last two prameter specify the grid position.
	local dropdownbox1 = luis.createElement("main", "DropDown", editItems, 1, 8, 2, editFunc, 1, 10, 4, nil, "Edit")
    contentArea:addChild(dropdownbox1)


    
    -- 启用图层
    luis.setCurrentLayer("main")
end

function love.update(dt)
    luis.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    luis.draw()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    luis.keypressed(key)
end

function love.keyreleased(key)
    luis.keyreleased(key)
end

function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end

function love.wheelmoved(x, y)
    luis.wheelmoved(x, y)
end

function love.textinput(text)
    luis.textinput(text)
end

-----------------------------------------------
-- 文件拖拽功能
-----------------------------------------------
function love.filedropped(file)
    droppedFilePath = file:getFilename()
    
    -- 读取文件内容
    local success, content = pcall(function()
        return file:read()
    end)
    
    if success then
        droppedFileContent = content
        fileStatusText = "文件加载成功: " .. (#droppedFileContent) .. " 字节"
        
        -- 更新UI显示
        if fileStatusLabel then
            fileStatusLabel:setText(fileStatusText)
            -- 显示文件内容的前200个字符
            local preview = string.sub(droppedFileContent, 1, 200)
            if #droppedFileContent > 200 then
                preview = preview .. "..."
            end
            fileContentLabel:setText(preview)
        end
        
        print("文件加载成功: " .. droppedFilePath)
        print("文件大小: " .. #droppedFileContent .. " 字节")
    else
        fileStatusText = "❌ 文件读取失败"
        if fileStatusLabel then
            fileStatusLabel:setText(fileStatusText)
        end
        print("文件读取失败: " .. droppedFilePath)
    end
    
    file:release()
end


-------------------------------
-- 文件转表功能
-------------------------------


-----------------------------------
-- csv 读取功能
local function readCSVFile(filename)
	local file = io.open(filename, "r")
	if not file then
		error("无法打开文件: " .. filename)
	end
	
	local lines = {}
	for line in file:lines() do
		if line ~= "" then  -- 跳过空行
			table.insert(lines, line)
		end
	end
	
	file:close()
	return lines
end