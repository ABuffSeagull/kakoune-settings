### Plugins ###
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

# kak-lsp
eval %sh{kak-lsp --kakoune -s $kak_session}
set-option global lsp_hover_anchor true

plug "h-youhei/kakoune-surround" %{
	declare-user-mode surround
	map global surround s ': surround<ret>' -docstring 'surround…'
	map global surround c ': change-surround<ret>' -docstring 'change'
	map global surround d ': delete-surround<ret>' -docstring 'delete'
	map global surround t ': select-surrounding-tag<ret>' -docstring 'select tag'
	map global user 's' ': enter-user-mode surround<ret>' -docstring 'surround'
}

plug "eraserhd/parinfer-rust" do %{ cargo install --path . --force } config %{
  hook global WinSetOption filetype=(clojure) %{
		parinfer-enable-window -indent
  }
}

plug "eraserhd/rep" do %{
	version=$(git describe --tags --abbrev=0)
	version=${version:1}
	curl ""
}

plug "delapouite/kakoune-buffers" %{
	hook global WinDisplay .* info-buffers
	map global user b ': enter-buffers-mode<ret>'              -docstring 'buffers…'
	map global user B ': enter-user-mode -lock buffers<ret>'   -docstring 'buffers (lock)…'
}

plug "occivink/kakoune-snippets" %{
	set-option global snippets_auto_expand true
	map global insert <a-E> '<a-;>: snippets-select-next-placeholders<ret>'
}

plug "andreyorst/fzf.kak" config %{
	map global user f ': fzf-mode<ret>'	-docstring 'fzf…'
} defer "fzf" %{
	set-option global fzf_file_command 'fd'
	set-option global fzf_highlight_command 'bat'
}

plug "alexherbo2/volatile-highlighter.kak" %{
	hook global WinCreate .* volatile-highlighter-enable
	set-face global Volatile +b
}

plug "alexherbo2/search-highlighter.kak" %{
	hook global WinCreate .* search-highlighter-enable
	set-face global Search +b
}

plug "abuffseagull/kakoune-toggler" do %{make} %{
	map global user t ': toggle-word<ret>' -docstring 'toggle word'
	map global user T ': toggle-WORD<ret>' -docstring 'toggle WORD'
}

plug "andreyorst/smarttab.kak" defer smarttab %{
	set-option global softtabstop 2
} config %{
	hook global WinSetOption filetype=(javascript|typescript|vue|rust|elixir|clojure|python|yaml|dart) "expandtab"
	hook global WinSetOption filetype=(c|cpp|zig) "smarttab"
}

plug "abuffseagull/kakoune-discord" do %{ cargo install --path . --force } %{
	discord-presence-enable
}

plug "lenormf/kakoune-extra" load %{
	tldr.kak
	grepmenu.kak
	intfiletype/git.kak
	autosplit.kak
	hatch_terminal.kak
	idsession.kak
}

plug "alexherbo2/auto-pairs.kak" %{ hook global WinCreate .* auto-pairs-enable }
plug "occivink/kakoune-sudo-write"
plug "abuffseagull/kakoune-vue"
plug "delapouite/kakoune-auto-percent"
plug "eraserhd/kak-ansi"

plug "abuffseagull/nord.kak" theme %{ colorscheme nord }

plug "vurich/zig-kak"

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
# define-command ide %{
#   rename-client main
#   set-option global jumpclient main

#   new rename-client tools
#   set-option global toolsclient tools

#   tmux-new-vertical rename-client docs
#   set-option global docsclient docs
# }
define-command new-vertical %{
	tmux-terminal-vertical kak -c %val{session}
}
alias global nv new-vertical

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
	eval %sh{
		out=""
		if [[ "$kak_opt_lintcmd" ]]; then
			out="lint"
		fi
		if [[ -d ".git" ]]; then
			out="$out;git update-diff"
		fi
		echo $out
	}
}

define-command haste %{
	execute-keys Z\%<a-|>haste<space>|<space>xclip<space><minus>sel<space>clip<ret>z
}

set-option global autoreload yes

### UI Stuff ###
# colorscheme lucius
hook global WinCreate .* %{
# Highlight 81 column
  #add-highlighter global/ regex ^(\t|\V{2}){40}(\V) 2:Error
  # Number the lines
  add-highlighter window/ number-lines -hlcursor -relative
  # Show extra whitespace
  add-highlighter window/ regex '\h+$' 0:Error
  eval %sh{
		if [[ -d ".git" ]]; then
			echo "git show-diff"
		fi
  }
}

### Language Specific Stuff ###
# Javascript
hook global WinSetOption filetype=javascript %{
	set-option window formatcmd 'prettier --parser=flow'
	set-option window makecmd 'yarn --silent run'
	set-option window lintcmd "yarn --silent run eslint --config .eslintrc.js --format kakoune --rule 'import/no-unresolved: off' --rule 'import/no-extraneous-dependencies: off'"
	define-command -override lang-repl %{tmux-terminal-vertical node}
	set-option global softtabstop 2
	lint-enable
	lint
}

# Typescript
hook global WinSetOption filetype=typescript %{
  set-option window formatcmd 'prettier --parser typescript'
  set-option window makecmd 'npm run'
	set-option window lintcmd 'yarn --silent run tslint --formatters-dir node_modules/tslint-formatter-kakoune -t kakoune --config tslint.json'
  define-command -override lang-repl %{tmux-terminal-vertical node}
	lint-enable
	lint
}

# Vue
hook global WinSetOption filetype=vue %{
  set-option window formatcmd 'prettier --parser vue'
  set-option window makecmd 'yarn'
	set-option window lintcmd "yarn --silent run eslint --config .eslintrc.js --format kakoune --rule 'import/no-unresolved: off' --rule 'import/no-extraneous-dependencies: off'"
  define-command -override lang-repl %{tmux-terminal-vertical node}
	lint-enable
	lint
}

hook global WinSetOption filetype=html %{
	set-option window formatcmd 'prettier --parser html'
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
 #  clang-enable-autocomplete
	# clang-enable-diagnostics
	# clang-parse
	# set-option window lintcmd 'cpplint'
	set-option window formatcmd 'astyle'
	# set-option window makecmd 'ninja -C build'
	# lint-enable
	# lint
}

# Rust
hook global WinSetOption filetype=rust %{
  set-option window formatcmd 'rustfmt'
  set-option window makecmd 'cargo'
  set-option global tabstop 4
  set-option global indentwidth 4
  set-option global softtabstop 4
  # lsp-enable
}

# Elixir
define-command -hidden elixir-deindent-on-end %[
	try %[ execute-keys -itersel -draft x<a-k>^\h+(end|else)$<ret><lt> ]
]
hook global WinSetOption filetype=elixir %{
  set-option window formatcmd 'mix format -'
  set-option window makecmd 'mix'
  hook window InsertChar d -group elixir-indent elixir-deindent-on-end
  # lsp-enable
}

# Clojure
hook global BufSetOption filetype=clojure %{
  set-option buffer comment_line ';'
  # define-command -override lang-repl %{tmux-terminal-vertical lein repl}
  set-option buffer tabstop 1
  set-option buffer indentwidth 1
  set-option buffer softtabstop 1
  parinfer-enable-window -indent
}

# Python
hook global BufSetOption filetype=python %{
  set-option buffer formatcmd 'yapf'
  set-option buffer tabstop 4
  set-option buffer indentwidth 4
}

hook global WinSetOption filetype=yaml %{
}

hook global BufSetOption filetype=scss %{
	set-option buffer formatcmd 'prettier --parser scss'
}

hook global BufSetOption filetype=java %{
	set-option buffer formatcmd 'astyle'
}

hook global BufSetOption filetype=zig %{
}

hook global BufSetOption filetype=dart %{
	set-option buff formatcmd 'dartfmt'
}
