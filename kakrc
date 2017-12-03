### Indenting ###
set global tabstop 2
set global indentwidth 2

### UX Stuff ###
# Mouse Support
set global ui_options ncurses_enable_mouse=true
# Double h instead of escape
hook global InsertChar h %{ try %{
    exec -draft hH <a-k>hh<ret> d
    exec <esc>
}}
# IDE mode or whatever
def ide %{
  rename-client main
  set global jumpclient main

  new rename-client tools
  set global toolsclient tools

  tmux-new-vertical rename-client docs
  set global docsclient docs
}
# Different 'w' functionality
def -hidden select-prev-word-part %{
  exec <a-/>[A-Z][a-z]+|[A-Z]+|[a-z]+<ret>
}
def -hidden select-next-word-part %{
  exec /[A-Z][a-z]+|[A-Z]+|[a-z]+<ret>
}
def -hidden extend-prev-word-part %{
  exec <a-?>[A-Z][a-z]+|[A-Z]+|[a-z]+<ret>
}
def -hidden extend-next-word-part %{
  exec ?[A-Z][a-z]+|[A-Z]+|[a-z]+<ret>
}
map global normal w :select-next-word-part<ret>
map global normal W :extend-next-word-part<ret>
# Change grep command
set global grepcmd 'ag'

### UI Stuff ###
# Highlight 81 column
hook global WinCreate .* %{
  addhl regex ^(\t|\V{2}){40}(\V) 2:Error
}
# Number the lines
hook global WinCreate .* %{
  addhl number_lines
}
# Show extra whitespace and something else
hook global WinCreate .* %{
  addhl show_matching
  addhl regex '\h+$' 0:Error
}
# Volatile highlighting
face volatile +bi
hook global NormalKey [ydcpP] %{ try %{
  add-highlighter dynregex \Q%reg{"}\E 0:volatile
}}
hook global NormalKey [^ydcpP] %{ try %{
  remove-highlighter dynregex_\Q%reg{"}\E
}}
face search +bi
# Smart search highlighting
hook global NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{
  add-highlighter dynregex '%reg{/}' 0:search
}}
hook global NormalKey <esc> %{ try %{
  remove-highlighter dynregex_%reg{<slash>}
}}


### Language Specific Stuff ###
# Javascript
hook global WinSetOption filetype=javascript %{
  set window lintcmd './node_modules/.bin/eslint --format=node_modules/eslint-formatter-kakoune'
  lint-enable
  lint
}

# C & C++
hook global WinSetOption filetype=cpp %{
  set clang_options 'std=c++11'
}
hook global WinSetOption filetype=c %{
  set clang_options 'std=c11'
}
hook global WinSetOption filetype=(c|cpp) %{
	clang-enable-autocomplete
	clang-enable-diagnostics
	clang-parse
	set window lintcmd 'cpplint'
	set window formatcmd 'astyle'
	lint-enable
	lint
}
# Odin
hook global WinSetOption filetype=odin %{
  set buffer comment_line '//'
  set buffer comment_block '/*:*/'
}

#hook global WinSetOption filetype=odin %{
  #set window lintcmd 'odin build'
#}

