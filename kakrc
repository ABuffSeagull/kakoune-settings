### Indenting ###
set global tabstop 2
set global indentwidth 2

### UX Stuff ###
# Mouse Support
set global ui_options ncurses_assistant=none:ncurses_enable_mouse=true
# Double h instead of escape
hook global InsertChar h %{ try %{
    exec -draft hH <a-k>hh<ret> d
    exec <esc>
}}
def ide %{
  rename-client main
  set global jumpclient main

  new rename-client tools
  set global toolsclient tools

  new rename-client docs
  set global docsclient docs
}


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
  set buffer indentwidth 4
  set buffer tabstop 4
  set window lintcmd 'eslint -j --format=node_modules/eslint-formatter-kakoune'
  lint-enable
  lint
}

# C & C++
hook global WinSetOption filetype=(c|cpp) %{
	clang-enable-autocomplete
	clang-enable-diagnostics
	clang-parse
	set window lintcmd 'cpplint'
	set window formatcmd 'astyle'
	lint-enable
	lint
}

hook global WinSetOption filetype=odin %{
  set window lintcmd 'odin build'
}
