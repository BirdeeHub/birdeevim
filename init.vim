" place your custom init.vim here!
colorscheme onedark
" Get the directory containing this init.vim
let s:vim_dir = expand('<sfile>:p:h')

" Convert to string for use in Lua
let s:vim_dir_str = string(s:vim_dir)

" Set the Lua path
call luaeval('package.path = "' . new_path . '"')

