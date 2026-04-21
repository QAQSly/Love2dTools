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

  -- 打包哪些平台
  platforms = {'windows'},

  -- 使用64位
  use32bit = false,

  -- 可选：设置图标（如果你有图标文件）
  -- icon = 'assets/icon.png',

  -- 可选：需要额外复制到输出目录的文件
  libs = {
    all = {
      'luis',                                    -- LUIS 框架
      'sly',                                     -- CSV 模块 + 字体文件
      'sly/AlibabaPuHuiTi-3-105-Heavy.ttf'      -- 显式包含字体文件
    }
  },
}