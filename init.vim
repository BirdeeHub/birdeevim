" place your custom init.vim here!
colorscheme onedark
" Get the directory containing this init.vim
let new_path = expand('<sfile>:p:h')
call luaeval('package.path = "' . new_path . '"')

