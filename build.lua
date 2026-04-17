return {
  -- 基础设置
  name = 'Excel转表工具',
  developer = '你的名字',
  output = 'dist',
  version = '1.0',
  love = '11.5',
  
  -- 忽略的文件/文件夹（不打包进去）
  ignore = {
    'dist',
    'output',
    'FlexLove',
    'samples',
    'mainTest.lua',
    'ThemeExample.lua',
    'stateful_ui.lua',
    'README.md',
    'LICENSE',
    '.git',
  },
  font = 'sly/AlibabaPuHuiTi-3-105-Heavy.ttf',
  
  -- 打包哪些平台
  platforms = {'windows'},
  
  -- 使用64位
  use32bit = false,
  
  -- 可选：设置图标（如果你有图标文件）
  -- icon = 'assets/icon.png',
  
  -- 可选：需要额外复制到输出目录的文件
  libs = {
    all = {
      'luis',      -- LUIS 框架
      'luis/init.lua',
      'sly',       -- 你的 csv 模块
      'sly/AlibabaPuHuiTi-3-105-Heavy.ttf'
    }
  },
}