" place your custom init.vim here!
colorscheme onedark

let sfile = expand('<sfile>:p')
echom sfile

" Resolve symlinks
let real_path = realpath(sfile)
echom real_path

let vim_dir = fnamemodify(real_path, ':h')
let lua_path = vim_dir . '/lua/?.lua'
echom lua_path
call luaeval('package.path = "' . lua_path . '"')
