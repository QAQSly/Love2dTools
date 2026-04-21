------------------------------------------
-- 多语言配置文件
------------------------------------------

local i18n = {
    currentLanguage = "en",  -- "zh" 中文, "en" 英文

    languages = {
        zh = {
            title = "Excel转表工具",
            dragHint = "拖拽文件到此区域",
            dragMessage = "将文件拖拽到这里...",
            convertBtn = "转表",
            btn2 = "按钮2",
            btn3 = "按钮3",
            btn4 = "按钮4",
            btn5 = "按钮5",
            btn6 = "按钮6",
            contentPlaceholder = "文件内容将显示在这里...",
            selectColumn = "请先拖拽文件",
            noFile = "❌ 请先拖拽 CSV 文件",
            noHeaders = "❌ 无法获取表头信息",
            fieldNotFound = "❌ 选中的字段不存在: ",
            converting = "开始转换...",
            source = "源文件: ",
            keyField = "Key字段: ",
            configName = "配置名: ",
            outputPath = "输出路径: ",
            success = "✅ 转换成功: ",
            error = "❌ 转换失败: ",
            fileLoaded = "✅ 文件已加载，点击「转表」按钮生成配置",
            emptyFile = "❌ 文件内容为空或格式错误",
            readError = "❌ 文件读取失败",
            fileSize = "文件大小: ",
            bytes = " 字节",
            langToggle = "EN/中文"
        },
        en = {
            title = "CSV to Config Tool",
            dragHint = "Drag files here",
            dragMessage = "Drag files to this area...",
            convertBtn = "Convert",
            btn2 = "Button 2",
            btn3 = "Button 3",
            btn4 = "Button 4",
            btn5 = "Button 5",
            btn6 = "Button 6",
            contentPlaceholder = "File content will be displayed here...",
            selectColumn = "Drag file first",
            noFile = "❌ Please drag a CSV file first",
            noHeaders = "❌ Cannot get header information",
            fieldNotFound = "❌ Selected field does not exist: ",
            converting = "Starting conversion...",
            source = "Source file: ",
            keyField = "Key field: ",
            configName = "Config name: ",
            outputPath = "Output path: ",
            success = "✅ Conversion successful: ",
            error = "❌ Conversion failed: ",
            fileLoaded = "✅ File loaded, click 'Convert' to generate config",
            emptyFile = "❌ File is empty or incorrect format",
            readError = "❌ File read failed",
            fileSize = "File size: ",
            bytes = " bytes",
            langToggle = "EN/中文"
        }
    }
}

function i18n:getText(key)
    return self.languages[self.currentLanguage][key] or key
end

function i18n:setLanguage(lang)
    if self.languages[lang] then
        self.currentLanguage = lang
    end
end

function i18n:getLanguage()
    return self.currentLanguage
end

function i18n:toggleLanguage()
    self:setLanguage(self.currentLanguage == "zh" and "en" or "zh")
end

return i18n
