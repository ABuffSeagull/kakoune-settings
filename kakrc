### Plugins ###
source "~/.cache/kakoune_plugins/plug.kak/rc/plug.kak"
set-option global plug_install_dir "/home/abuffseagull/.cache/kakoune_plugins"
plug "andreyorst/plug.kak" noload

plug "ul/kak-lsp" "tag: v5.10.0" noload do %{cargo build --release} %{
	eval %sh{kak-lsp --kakoune -s $kak_session}
	set-option global lsp_hover_anchor true
}

plug "h-youhei/kakoune-surround" %{
	declare-user-mode surround
	map global surround s ': surround<ret>' -docstring 'surround…'
	map global surround c ': change-surround<ret>' -docstring 'change'
	map global surround d ': delete-surround<ret>' -docstring 'delete'
	map global surround t ': select-surrounding-tag<ret>' -docstring 'select tag'
	map global user 's' ': enter-user-mode surround<ret>' -docstring 'surround'
}

plug "delapouite/kakoune-buffers" %{
	hook global WinDisplay .* info-buffers
	map global user b ': enter-buffers-mode<ret>'              -docstring 'buffers…'
	map global user B ': enter-user-mode -lock buffers<ret>'   -docstring 'buffers (lock)…'
}

plug "JJK96/kakoune-snippets" %{
	map global insert <a-E> '<esc>;h: snippet-word<ret>'
	map global insert <a-e> '<esc>: replace-next-hole<ret>'
}

plug "andreyorst/fzf.kak" %{
	map global user f ': fzf-mode<ret>'	-docstring 'fzf…'
	set-option global fzf_file_command 'fd'
	set-option global fzf_highlighter 'bat'
}

plug "alexherbo2/volatile-highlighter.kak" %{
	hook global WinCreate .* volatile-highlighter-enable
	set-face global Volatile +b
}
plug "alexherbo2/search-highlighter.kak" %{
	hook global WinCreate .* search-highlighter-enable
	set-face global Search +b
}

# plug "eraserhd/parinfer-rust" do %{
#     cargo build --release
#     cargo install

plug "abuffseagull/kakoune-toggler" do %{make} %{
	map global user t ': toggle-word<ret>' -docstring 'toggle word'
	map global user T ': toggle-WORD<ret>' -docstring 'toggle WORD'
}

plug "andreyorst/smarttab.kak" %{
	set-option global softtabstop 2
}

plug "alexherbo2/auto-pairs.kak" %{ hook global WinCreate .* auto-pairs-enable }
plug "occivink/kakoune-sudo-write"
plug "abuffseagull/kakoune-vue"
plug "delapouite/kakoune-auto-percent"
plug "nkoehring/kakoune-todo.txt"
# plug "Delapouite/kakoune-livedown"

### Indenting ###
set-option global tabstop 2
set-option global indentwidth 2
set-option global aligntab true

### UX Stuff ###
# Mouse Support
set-option -add global ui_options ncurses_enable_mouse=true ncurses_set_title=yes
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
map global normal '#' ': comment-line<ret>' -docstring 'comment line'
map global normal '<a-#>' ': comment-block<ret>' -docstring 'comment line'

# Format
map global normal = ': format<ret>' -docstring 'format buffer'

# Add some stuff to write
hook global BufWritePost .* %{
	git update-diff
	eval %sh{
		if [[ "$kak_opt_lintcmd" ]]; then
			echo 'lint'
		fi
	}
}

define-command haste %{
	execute-keys Z\%<a-|>haste<space>|<space>xclip<space><minus>sel<space>clip<ret>z
}

set-option global autoreload yes

### UI Stuff ###
hook global WinCreate .* %{
# Highlight 81 column
  #add-highlighter global/ regex ^(\t|\V{2}){40}(\V) 2:Error
  # Number the lines
  add-highlighter window/ number-lines -relative -hlcursor
  # Show extra whitespace
  add-highlighter window/ regex '\h+$' 0:Error
  git show-diff
  smarttab
}

### Language Specific Stuff ###
# Javascript
hook global WinSetOption filetype=javascript %{
	set-option window formatcmd 'prettier --parser=flow'
	set-option window makecmd 'yarn --silent run'
	set-option window lintcmd 'yarn --silent run eslint --config .eslintrc.js --format=node_modules/eslint-formatter-kakoune'
	expandtab
	lint-enable
	lint
}

# Typescript
hook global WinSetOption filetype=typescript %{
  set-option window formatcmd 'prettier'
  set-option window makecmd 'npm run'
}

# JSON
hook global WinSetOption filetype=json %{
	set-option window formatcmd 'prettier --parser=json'
}

# ReasonML
hook global WinSetOption filetype=ocaml %{
	set-option window formatcmd 'bsrefmt'
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
	# set-option window makecmd 'ninja -C build'
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
  set-option window makecmd 'yarn'
	set-option window lintcmd 'yarn --silent run eslint --config .eslintrc.js --format=node_modules/eslint-formatter-kakoune'
	expandtab
	lint-enable
	lint
}

# Clojure
hook global WinSetOption filetype=clojure %{
  set-option window comment_line ';'
}

# Python
hook global WinSetOption filetype=python %{
	set-option window formatcmd 'yapf'
}
