csv = {}

-----------------------------------
-- csv 读取功能
function csv.readCSVFile(filename)
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
------------------------------------

--- 自动转换字符串为合适的类型（数字、布尔值等）
---@param value string 原始字符串
---@return any 转换后的值
function csv.autoConvert(value)
    -- 空字符串保持为空
    if value == "" then
        return ""
    end
    
    -- 尝试转换为数字
    local num = tonumber(value)
    if num then
        return num
    end
    
    -- 尝试转换为布尔值
    if value == "true" then
        return true
    elseif value == "false" then
        return false
    end
    
    -- 保持原字符串
    return value
end

--- 解析 CSV 行为字段数组
---@param line string CSV 行
---@return table 字段数组
function csv.parseLine(line)
    local fields = {}
    for field in line:gmatch("([^,]+)") do
        -- 去除首尾空格和引号
        field = field:match("^%s*(.-)%s*$")
        if field:sub(1, 1) == '"' and field:sub(-1) == '"' then
            field = field:sub(2, -2)
        end
        field = csv.autoConvert(field)
        table.insert(fields, field)
    end
    return fields
end

--- 获取表头
---@param lines table CSV 行数组
---@param headerRow number 表头所在行号（默认为1）
---@return table|nil 表头数组
function csv.getHeader(lines, headerRow)
    headerRow = headerRow or 1
    
    if not lines or #lines < headerRow then
        return nil
    end
    
    return csv.parseLine(lines[headerRow])
end

--- 根据表头行号读取数据
function csv.readWithHeader(filename, headerRow)
    headerRow = headerRow or 1
    
    local lines = csv.readCSVFile(filename)  -- 这里直接返回 lines，没有 err
    if not lines then
        return nil, "无法读取文件"
    end
    
    if #lines < headerRow then
        return nil, string.format("文件行数不足，无法获取第%d行作为表头", headerRow)
    end
    
    local headers = csv.getHeader(lines, headerRow)
    if not headers then
        return nil, "解析表头失败"
    end
    
    local config = {}
    for i = headerRow + 1, #lines do
        local values = csv.parseLine(lines[i])
        local row = {}
        for j, header in ipairs(headers) do
            row[header] = values[j] or ""
        end
        table.insert(config, row)
    end
    
    return {
        headers = headers,
        data = config,
        rowCount = #config,
        colCount = #headers
    }, nil
end

--- 将带下划线的扁平 key 转换为嵌套 table
--- 例如 "Animations_Idle" -> row["Animations"]["Idle"]
---@param row table 原始行数据
---@return table 转换后的嵌套表
function csv.nestifyRow(row)
    local result = {}
    
    for key, value in pairs(row) do
        -- 查找下划线位置
        local underscorePos = key:find("_")
        
        if underscorePos then
            local parentKey = key:sub(1, underscorePos - 1)
            local childKey = key:sub(underscorePos + 1)
            
            -- 确保父表存在
            if not result[parentKey] then
                result[parentKey] = {}
            end
            
            -- 如果父表位置已被非表值占用，先保留原值
            if type(result[parentKey]) ~= "table" then
                local oldValue = result[parentKey]
                result[parentKey] = { _value = oldValue }
            end
            
            result[parentKey][childKey] = value
        else
            -- 没有下划线，直接赋值
            result[key] = value
        end
    end
    
    return result
end

--- 将 CSV 数据转换为配置表（保持顺序）
function csv.toConfigTable(result, keyField)
    if not result or not result.data then
        return {}
    end
    
    local config = {}
    local order = {}  -- 记录 key 的顺序
    
    for _, row in ipairs(result.data) do
        local key = row[keyField]
        if key and key ~= "" then
            config[key] = csv.nestifyRow(row)
            table.insert(order, key)  -- 按出现顺序记录
        end
    end
    
    -- 保存顺序信息
    config._order = order
    
    return config
end
--- 序列化值
function csv.serializeValue(value, indent)
    local valueType = type(value)
    
    if valueType == "table" then
        return csv.serializeTable(value, indent)
    elseif valueType == "string" then
        return string.format("%q", value)
    elseif valueType == "number" then
        return tostring(value)
    elseif valueType == "boolean" then
        return value and "true" or "false"
    else
        return "nil"
    end
end

--- 序列化嵌套表（无中括号版本）
function csv.serializeTable(t, indent)
    indent = indent or ""
    local nextIndent = indent .. "  "
    
    local items = {}
    for k, v in pairs(t) do
        -- 判断 key 是否是合法的 Lua 变量名
        if type(k) == "string" and k:match("^[%a_][%w_]*$") then
            table.insert(items, nextIndent .. k .. " = " .. csv.serializeValue(v, nextIndent))
        elseif type(k) == "number" then
            table.insert(items, nextIndent .. "[" .. k .. "] = " .. csv.serializeValue(v, nextIndent))
        else
            table.insert(items, nextIndent .. string.format("[%q] = ", k) .. csv.serializeValue(v, nextIndent))
        end
    end
    
    if #items == 0 then
        return "{}"
    end
    
    return "{\n" .. table.concat(items, ",\n") .. "\n" .. indent .. "}"
end

--- 序列化配置表（无中括号版本）
--- 序列化配置表（按 CSV 原始顺序）
function csv.serializeConfig(config, configName, indent)
    indent = indent or ""
    local nextIndent = indent .. "  "
    
    local lines = {}
    table.insert(lines, configName .. " = {")
    
    -- 使用保存的顺序
    local order = config._order or {}
    local hasOrder = #order > 0
    
    if hasOrder then
        -- 按 CSV 原始顺序输出
        for _, key in ipairs(order) do
            local value = config[key]
            if type(key) == "string" and key:match("^[%a_][%w_]*$") then
                table.insert(lines, nextIndent .. key .. " = " .. csv.serializeValue(value, nextIndent) .. ",")
            else
                table.insert(lines, nextIndent .. string.format("[%q] = ", key) .. csv.serializeValue(value, nextIndent) .. ",")
            end
        end
    else
        -- 没有顺序信息时按字母排序
        local keys = {}
        for k, _ in pairs(config) do
            if k ~= "_order" then
                table.insert(keys, k)
            end
        end
        table.sort(keys)
        
        for _, key in ipairs(keys) do
            local value = config[key]
            if type(key) == "string" and key:match("^[%a_][%w_]*$") then
                table.insert(lines, nextIndent .. key .. " = " .. csv.serializeValue(value, nextIndent) .. ",")
            else
                table.insert(lines, nextIndent .. string.format("[%q] = ", key) .. csv.serializeValue(value, nextIndent) .. ",")
            end
        end
    end
    
    table.insert(lines, indent .. "}")
    table.insert(lines, "")
    table.insert(lines, "return " .. configName)
    
    return table.concat(lines, "\n")
end

--- 将配置表保存为 Lua 文件
---@param config table 配置表
---@param configName string 配置表名称
---@param outputPath string 输出路径
---@return boolean, string 成功标志和消息
function csv.saveAsLua(config, configName, outputPath)
    local content = csv.serializeConfig(config, configName)
    
    local file, err = io.open(outputPath, "w")
    if not file then
        return false, err
    end
    
    file:write(content)
    file:close()
    
    return true, "保存成功: " .. outputPath
end

--- 一行调用：CSV 直接转 Lua 配置文件
---@param csvPath string CSV 文件路径
---@param keyField string 作为 key 的字段名
---@param configName string 配置表名称
---@param outputPath string 输出 Lua 文件路径
---@param headerRow number 表头所在行（默认 1）
---@return boolean, string 成功标志和消息
function csv.convertToLua(csvPath, keyField, configName, outputPath, headerRow)
    headerRow = headerRow or 1
    
    -- 读取 CSV
    local result, err = csv.readWithHeader(csvPath, headerRow)
    if not result then
        return false, err
    end
    
    -- 检查 keyField 是否存在
    local hasKey = false
    for _, header in ipairs(result.headers) do
        if header == keyField then
            hasKey = true
            break
        end
    end
    
    if not hasKey then
        return false, string.format("字段 '%s' 不存在于表头中", keyField)
    end
    
    -- 转换为配置表
    local config = csv.toConfigTable(result, keyField)
    
    -- 保存为 Lua 文件
    return csv.saveAsLua(config, configName, outputPath)
end

return csv