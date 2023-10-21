" place your custom init.vim here!
colorscheme onedark

" Get the path of the init.vim file
let s:script_path = expand('%:p:h')

" Set custom LUA_PATH relative to the init.vim file
let &l:lua_path = s:script_path . '/nvimlua/?.lua'
