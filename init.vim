" place your custom init.vim here!
colorscheme onedark

let lua_dir = stdpath('config') . '/lua'
let lua_path = lua_dir . '/?.lua'

call luaeval('package.path = package.path .. "' . lua_path . '"')
