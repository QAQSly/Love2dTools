-----------------------------------------------
-- LUIS UI Demo - 精简版（布局 + 文件拖入 + 多语言支持）
-----------------------------------------------

local initluis = require("luis/init")
local luis = initluis("luis/widgets")
luis.flux = require("luis.3rdparty.flux")
local csv = require("sly.csv")
local i18n = require("i18n")

local function getText(key)
    return i18n:getText(key)
end

------------------------------------------
-- 文件拖入变量
local droppedFilePath = nil
local droppedFileContent = nil
local fileStatusText = getText("dragMessage")
local currentHeaders = nil  -- 保存当前文件的表头

-- 全局引用，方便更新
local fileStatusLabel = nil
local fileContentLabel = nil
local columnDropdown = nil
local langToggleBtn = nil

function love.load()
    -- 设置窗口
    luis.baseWidth = 1280
    luis.baseHeight = 800
    love.window.setMode(luis.baseWidth, luis.baseHeight)

    -- ===== 字体设置 =====
    -- 尝试加载中文字体，失败则使用默认字体（默认字体支持英文）
    --local customFont = love.graphics.newFont("sly/AlibabaPuHuiTi-3-105-Heavy.ttf", 16)
    local customFont = nil
    local font = customFont or love.graphics.newFont(16)

    love.graphics.setFont(font)

    -- 设置 LUIS 主题字体
    luis.theme.text.font = font
    luis.theme.flexContainer.padding = 2
    luis.gridSize = 10

    -- 创建图层
    luis.newLayer("main")

    -- 创建主容器
    local mainContainer = luis.createElement("main", "FlexContainer", 128, 80, 1, 1, nil, "Main")

    -- ===== 头部 =====
    local header = luis.newFlexContainer(128, 8, 1, 1, nil, "Header")
    local aside = luis.newFlexContainer(12, 70, 1, 9, nil, "aside")
    mainContainer:addChild(header)
    mainContainer:addChild(aside)

    -- 标题 + 语言切换按钮
    header:addChild(luis.createElement("main", "Label", getText("title"), 40, 2, 1, 1))

    langToggleBtn = luis.createElement("main", "Button", getText("langToggle"), 10, 2,
        function()
            i18n:toggleLanguage()
            updateUILanguage()
        end,
        function() end,
        100, 1
    )
    header:addChild(langToggleBtn)

    -- 转表按钮（第一个按钮）
    local convertButton = aside:addChild(luis.createElement("main", "Button", getText("convertBtn"), 10, 2,
        function()
            print("转表按钮 - 点击")
            convertCSVToConfig()  -- 调用转换函数
        end,
        function()
            print("转表按钮 - 释放")
        end,
        1, 1
    ))

    -- 其他按钮（可以保留或删除）
    aside:addChild(luis.createElement("main", "Button", getText("btn2"), 10, 2, function() print('按钮2点击') end, function() end, 1, 1))
    aside:addChild(luis.createElement("main", "Button", getText("btn3"), 10, 2, function() print('按钮3点击') end, function() end, 1, 1))
    aside:addChild(luis.createElement("main", "Button", getText("btn4"), 10, 2, function() print('按钮4点击') end, function() end, 1, 1))
    aside:addChild(luis.createElement("main", "Button", getText("btn5"), 10, 2, function() print('按钮5点击') end, function() end, 1, 1))
    aside:addChild(luis.createElement("main", "Button", getText("btn6"), 10, 2, function() print('按钮6点击') end, function() end, 1, 1))

    -- ===== 内容区域 =====
    local contentArea = luis.newFlexContainer(112, 70, 20, 9, nil, "Content Area")
    mainContainer:addChild(contentArea)

    -- 文件拖拽区域提示
    local dropHint = luis.createElement("main", "Label", getText("dragHint"), 30, 2, 1, 1)
    contentArea:addChild(dropHint)

    -- 文件状态显示
    fileStatusLabel = luis.createElement("main", "Label", fileStatusText, 30, 2, 1, 1)
    contentArea:addChild(fileStatusLabel)

    -- 文件内容显示
    fileContentLabel = luis.createElement("main", "Label", getText("contentPlaceholder"), 100, 10, 1, 1)
    contentArea:addChild(fileContentLabel)

    -- 列名下拉列表
    local editItems = {getText("selectColumn")}
    editFunc = function(self, item)
        print("选中了列: " .. item)
        currentSelectedKey = item  -- 保存选中的 key
    end
    local dropdownbox1 = luis.createElement("main", "DropDown", editItems, 1, 8, 2, editFunc, 1, 10, 4, nil, nil)
    contentArea:addChild(dropdownbox1)
    columnDropdown = dropdownbox1

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

------------------------
-- 获取选中的 key（从下拉列表）
------------------------
local currentSelectedKey = "id"  -- 默认值

function getSelectedKey()
    if columnDropdown and columnDropdown.items and columnDropdown.value then
        return columnDropdown.items[columnDropdown.value]
    end
    return currentSelectedKey
end

------------------------
-- CSV 转 Config 函数
------------------------
function convertCSVToConfig()
    if not droppedFilePath then
        print(getText("noFile"))
        if fileStatusLabel then
            fileStatusLabel:setText(getText("noFile"))
        end
        return
    end

    if not currentHeaders or #currentHeaders == 0 then
        print(getText("noHeaders"))
        if fileStatusLabel then
            fileStatusLabel:setText(getText("noHeaders"))
        end
        return
    end

    -- 获取选中的 key 字段
    local selectedKey = getSelectedKey()
    print(getText("keyField") .. selectedKey)

    -- 检查选中的 key 是否在表头中
    local keyExists = false
    for _, header in ipairs(currentHeaders) do
        if header == selectedKey then
            keyExists = true
            break
        end
    end

    if not keyExists then
        print(getText("fieldNotFound") .. selectedKey)
        if fileStatusLabel then
            fileStatusLabel:setText(getText("fieldNotFound") .. selectedKey)
        end
        return
    end

    -- 生成输出路径
    local fileDir = droppedFilePath:match("(.*[/\\])") or ""
    local fileName = droppedFilePath:match("([^/\\]+)%.[^%.]+$") or "Config"
    local configName = fileName:gsub("^%l", string.upper) .. "Config"
    local outputPath = fileDir .. fileName .. "Config.lua"

    print(getText("converting"))
    print(getText("source") .. droppedFilePath)
    print(getText("keyField") .. selectedKey)
    print(getText("configName") .. configName)
    print(getText("outputPath") .. outputPath)

    -- 执行转换
    local success, msg = csv.convertToLua(
        droppedFilePath,   -- CSV 文件路径
        selectedKey,       -- 作为 key 的字段名
        configName,        -- 配置表名称
        outputPath,        -- 输出路径
        1                  -- 表头行号（默认 1）
    )

    if success then
        print(getText("success") .. outputPath)
        if fileStatusLabel then
            fileStatusLabel:setText(getText("success") .. outputPath)
        end
    else
        print(getText("error") .. msg)
        if fileStatusLabel then
            fileStatusLabel:setText(getText("error") .. msg)
        end
    end
end

-----------------------------------------------
-- 文件拖拽功能（只加载，不转换）
-----------------------------------------------
function love.filedropped(file)
    droppedFilePath = file:getFilename()

    -- 读取文件内容
    local success, content = pcall(function()
        return file:read()
    end)

    if success then
        droppedFileContent = content
        fileStatusText = getText("fileSize") .. (#droppedFileContent) .. getText("bytes")

        -- 更新UI显示
        if fileStatusLabel then
            fileStatusLabel:setText(fileStatusText)
            local preview = string.sub(droppedFileContent, 1, 200)
            if #droppedFileContent > 200 then
                preview = preview .. "..."
            end
            fileContentLabel:setText(preview)
        end

        print("文件加载成功: " .. droppedFilePath)

        -- 读取 CSV 获取表头
        local lines = csv.readCSVFile(droppedFilePath)
        if lines and #lines > 0 then
            -- 解析表头（去除 BOM）
            local headers = csv.parseLine(lines[1], true)
            currentHeaders = headers

            print("表头: " .. table.concat(headers, ", "))

            -- 更新下拉列表
            columnDropdown:setItems(headers)

            -- 更新状态
            if fileStatusLabel then
                fileStatusLabel:setText(getText("fileLoaded"))
            end
        else
            if fileStatusLabel then
                fileStatusLabel:setText(getText("emptyFile"))
            end
        end

        print(getText("fileSize") .. #droppedFileContent .. getText("bytes"))
    else
        fileStatusText = getText("readError")
        if fileStatusLabel then
            fileStatusLabel:setText(fileStatusText)
        end
        print(getText("readError") .. droppedFilePath)
    end

    file:release()
end

------------------------
-- 更新UI语言
------------------------
function updateUILanguage()
    if langToggleBtn then
        langToggleBtn.text = getText("langToggle")
    end
    if fileStatusLabel then
        fileStatusLabel:setText(getText("dragMessage"))
    end
    if fileContentLabel then
        fileContentLabel:setText(getText("contentPlaceholder"))
    end
end