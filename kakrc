### Plugins ###
# Plug
source "~/.cache/kakoune_plugins/plug.kak/rc/plug.kak"
set-option global plug_install_dir "$HOME/.cache/kakoune_plugins"
plug "andreyorst/plug.kak" noload

plug "h-youhei/kakoune-surround" %{
	declare-user-mode surround
	map global surround s ':surround<ret>' -docstring 'surround'
	map global surround c ':change-surround<ret>' -docstring 'change'
	map global surround d ':delete-surround<ret>' -docstring 'delete'
	map global surround t ':select-surrounding-tag<ret>' -docstring 'select tag'
	map global user 's' ':enter-user-mode surround<ret>' -docstring 'surround'
}

plug "delapouite/kakoune-buffers" %{
	hook global WinDisplay .* list-buffers
	map global user b ':enter-buffers-mode<ret>'              -docstring 'buffers…'
	map global user B ':enter-user-mode -lock buffers<ret>'   -docstring 'buffers (lock)…'
}

plug "alexherbo2/snippets.kak"  %{
  source ~/.config/kak/snippets.kak
  hook global WinCreate .* snippets-enable
}

# plug "lenormf/kakoune-extra"
plug "alexherbo2/auto-pairs.kak" %{ hook global WinCreate .* auto-pairs-enable }
plug "occivink/kakoune-sudo-write"
plug "alexherbo2/volatile-highlighter.kak" %{ hook global WinCreate .* volatile-highlighter-enable }
plug "alexherbo2/search-highlighter.kak" %{ hook global WinCreate .* search-highlighter-enable }
plug "abuffseagull/kakoune-ecmascript"
plug "abuffseagull/kakoune-vue"

### Indenting ###
set-option global tabstop 2
set-option global indentwidth 0
set-option global aligntab true

### UX Stuff ###
# Mouse Support
set-option global ui_options ncurses_enable_mouse=true
# Double h instead of escape
hook global InsertChar h %{ try %{
    exec -draft hH <a-k>hh<ret> d
    exec <esc>
}}
# IDE mode or whatever
define-command ide %{
  rename-client main
  set-option global jumpclient main

  new rename-client tools
  set-option global toolsclient tools

  tmux-new-vertical rename-client docs
  set-option global docsclient docs
}

# Change grep command
set-option global grepcmd 'ag'

# Copy to clipboard
map global user y <a-|>xclip<space><minus>sel<space>clip<ret> -docstring 'copy to clipboard'

# Comment line
map global normal '#' :comment-line<ret> -docstring 'comment line'
map global normal '<a-#>' :comment-block<ret> -docstring 'comment line'

# Format
map global normal = :format<ret> -docstring 'format buffer'

unalias global w write
define-command -docstring 'write and some extras :D' w %{
	write
	try %{ git update-diff }
}

map global user f :fzy<space>.<ret> -docstring 'fuzzy search'

define-command haste %{
	execute-keys Z\%<a-|>haste<space>|<space>xclip<space><minus>sel<space>clip<ret>z
}

### UI Stuff ###
hook global WinCreate .* %{
# Highlight 81 column
  #add-highlighter global/ regex ^(\t|\V{2}){40}(\V) 2:Error
  # Number the lines
  add-highlighter window/ number-lines -relative -hlcursor
  # Show extra whitespace
  add-highlighter window/ regex '\h+$' 0:Error
  git show-diff
}

# Volatile face
set-face global Volatile +bi
set-face global Search +bi

# Smart search highlighting
set-face global search +bi
hook global NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{
  add-highlighter global/ dynregex '%reg{/}' 0:search
}}
hook global NormalKey <esc> %{ try %{
  remove-highlighter global/dynregex_%reg{<slash>}
}}

# Connect to the lsp server
# %sh{kak-lsp --kakoune -s $kak_session}


### Language Specific Stuff ###
# Javascript
hook global WinSetOption filetype=ecmascript %{
  set-option buffer comment_line '// '
  set-option buffer comment_block_begin '/* '
  set-option buffer comment_block_end ' */'
  #set-option window lintcmd 'yarn --silent run eslint --config .eslintrc.json --format=node_modules/eslint-formatter-kakoune'
  set-option window formatcmd 'prettier --parser flow'
  set-option window makecmd 'npm run'
  #lint-enable
}

# Typescript
hook global WinSetOption filetype=typescript %{
  set-option window formatcmd 'prettier'
  set-option window makecmd 'npm run'
}

# C & C++
hook global WinSetOption filetype=cpp %{
  set-option clang_options 'std=c++11'
}
hook global WinSetOption filetype=c %{
  set-option clang_options 'std=c11'
}
hook global WinSetOption filetype=(c|cpp) %{
	clang-enable-autocomplete
	clang-enable-diagnostics
	clang-parse
	set-option window lintcmd 'cpplint'
	set-option window formatcmd 'astyle'
	lint-enable
	lint
}

# Rust
hook global WinSetOption filetype=rust %{
  set-option window formatcmd 'rustfmt'
  set-option global tabstop 4
  set-option global indentwidth 4
}

# Elixir
define-command -hidden elixir-deindent-on-end %[
	try %[ execute-keys -itersel -draft x<a-k>^\h+(end|else)$<ret><lt> ]
]
hook global WinSetOption filetype=elixir %{
  set-option window formatcmd 'mix format -'
  set-option window makecmd 'mix'
  hook window InsertChar d -group elixir-indent elixir-deindent-on-end
}

# Vue
hook global WinSetOption filetype=vue %{
  set-option window formatcmd 'prettier --parser vue'
}

# Clojure
hook global WinSetOption filetype=clojure %{
  set-option window comment_line ';'
}
