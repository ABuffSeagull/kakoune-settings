### Plugins ###
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

# kak-lsp
plug "kak-lsp/kak-lsp" do %{
	cargo install --force --path .
} config %{
	hook global WinSetOption filetype=(elm|zig|sh|rust) %{
		set-option window lsp_auto_highlight_references true
		set-option window lsp_hover_anchor false
		lsp-auto-hover-enable
		echo -debug "Enabling LSP for filtetype %opt{filetype}"
		lsp-enable-window
	}

	hook global WinSetOption filetype=(rust) %{
		set window lsp_server_configuration rust.clippy_preference="on"
	}

	hook global KakEnd .* lsp-exit
}

plug "h-youhei/kakoune-surround" %{
	declare-user-mode surround
	map global surround s ': surround<ret>' -docstring 'surround…'
	map global surround c ': change-surround<ret>' -docstring 'change'
	map global surround d ': delete-surround<ret>' -docstring 'delete'
	map global surround t ': select-surrounding-tag<ret>' -docstring 'select tag'
	map global user 's' ': enter-user-mode surround<ret>' -docstring 'surround'
}

plug "eraserhd/parinfer-rust" do %{ cargo install --path . } config %{
	hook global WinSetOption filetype=(clojure) 'parinfer-enable-window -indent'
}

# plug "eraserhd/rep" do %sh{
#  cd "${kak_config}/plugins/rep"
#  latest_tag=$(git describe --abbrev=0)
#  latest_tag_without_v=$(echo $latest_tag | tail -c +2)
#  wget \
#   -O binary.tar.gz \
#   "https://github.com/eraserhd/rep/releases/download/${latest_tag}/rep-${latest_tag_without_v}-linux-amd64.tar.gz"
# }

plug "delapouite/kakoune-buffers" %{
	hook global WinDisplay .* info-buffers
	map global user b ': enter-buffers-mode<ret>'        -docstring 'buffers…'
	map global user B ': enter-user-mode -lock buffers<ret>'  -docstring 'buffers (lock)…'
}

plug "occivink/kakoune-snippets" %{
	set-option global snippets_auto_expand true
	map global insert <a-n> '<a-;>: snippets-select-next-placeholders<ret>'
	# map global insert <a-e> '<esc>B: snippet'
	# map global insert <a-e> '<a-;>hG: sni'
}

plug "andreyorst/fzf.kak" config %{
	map global user f ': fzf-mode<ret>' -docstring 'fzf…'
} defer fzf-file %{
	set-option global fzf_file_command 'fd'
	set-option global fzf_highlight_command 'bat'
}

plug "alexherbo2/volatile-highlighter.kak" demand volatile-highlighter %{
  volatile-highlighter-enable
}
plug "alexherbo2/search-highlighter.kak" demand search-highlighter %{
  search-highlighter-enable
}

plug "abuffseagull/kakoune-toggler" do %{ cargo install --path . } %{
	map global user t ': toggle-word<ret>' -docstring 'toggle word'
	map global user T ': toggle-WORD<ret>' -docstring 'toggle WORD'
}

plug "andreyorst/smarttab.kak" defer smarttab %{
	set-option global softtabstop 2
} config %{
	hook global BufSetOption filetype=(clojure|dart|elixir|elm|javascript|liquid|python|rust|typescript|vue|yaml|zig) expandtab
	hook global BufSetOption filetype=(c|cpp|kak|lua|pug|plain|toml) smarttab
}

plug "abuffseagull/kakoune-discord" do %{ cargo install --force --path . } %{
	# discord-presence-enable
}

# plug "lenormf/kakoune-extra" subset %{
# 	tldr.kak
# 	grepmenu.kak
# 	intfiletype/git.kak
# 	autosplit.kak
# 	hatch_terminal.kak
# 	idsession.kak
# } %{
# 	set-option global grepmenucmd 'rg --vimgrep'
# 	hook global KakBegin .* idsession
# 	alias global hatch hatch-terminal-tmux
# }
hook global KakBegin .* idsession

plug "alexherbo2/prelude.kak" demand prelude %{}
# plug "alexherbo2/auto-pairs.kak" demand auto-pairs %{  }
plug "occivink/kakoune-sudo-write"
plug "abuffseagull/kakoune-vue"
plug "delapouite/kakoune-auto-percent"
plug "eraserhd/kak-ansi"

plug "abuffseagull/nord.kak" theme %{ colorscheme nord }

plug "vurich/zig-kak"
plug "abuffseagull/liquid.kak"

### Indenting ###
set-option global tabstop     2
set-option global indentwidth 2
set-option global aligntab      true

### UX Stuff ###
# Mouse Support
set-option -add global ui_options ncurses_enable_mouse=true ncurses_set_title=true
# Double h instead of escape
hook global InsertChar h %{ try %{
exec -draft hH <a-k>hh<ret> d
		exec <esc>
}}

hook global InsertChar , %{ try %{
	exec -draft hH <a-k>,,<ret> d
	exec <esc>Gi_|<space>emmet<ret>
}}

define-command new-vertical 'tmux-terminal-vertical kak -c %val{session}'


alias global nv new-vertical
alias global W write

# Change grep command
set-option global grepcmd 'rg --vimgrep'

# Copy to clipboard
map global user y <a-|>xsel<space><minus>ib<ret> -docstring 'copy to clipboard'

# Comment line
map global normal '#' ': comment-line<ret>' -docstring 'comment line'
map global normal '<a-#>' ': comment-block<ret>' -docstring 'comment line'

# Format
map global normal = ': format<ret>' -docstring 'format buffer'

# Add some stuff to write
hook global BufWritePost .* %{
	eval %sh{
		out=""
		if [ "$kak_opt_lintcmd" ]; then
			out="lint"
		fi
		if [ -d ".git" ]; then
			out="$out;git update-diff"
		fi
		echo $out
	}
}


define-command haste %{
	execute-keys Z\%<a-|>haste<space>|<space>xsel<space><minus>ib<ret>z
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
		if [ -d ".git" ]; then
			echo "git show-diff"
		fi
	}
}

### Language Specific Stuff ###
# Javascript
hook global BufSetOption filetype=javascript %{
	set-option buffer formatcmd 'npx prettier --parser babel'
	# set-option buffer lintcmd 'run() { cat "$1" | npm --silent run eslint -f ~/.config/yarn/global/node_modules/eslint-formatter-kakoune/index.js --stdin --stdin-filename "$kak_buffile";} && run '
	set-option buffer softtabstop 2
}

# Typescript
hook global BufSetOption filetype=typescript %{
	set-option buffer formatcmd 'npx prettier --parser typescript'
	# set-option buffer lintcmd 'npm --silent run tslint --formatters-dir node_modules/tslint-formatter-kakoune -t kakoune --config tslint.json'
}

# Vue
hook global WinSetOption filetype=vue %{
	set-option window formatcmd 'npx prettier --parser vue'
	# set-option window lintcmd "yarn --silent run eslint --config .eslintrc.js --format kakoune --rule 'import/no-unresolved: off' --rule 'import/no-extraneous-dependencies: off'"
}

hook global BufSetOption filetype=(javascript|typescript|vue|html) %{
	set-option buffer makecmd 'npm'
	lint-enable
	lint
}

hook global BufSetOption filetype=html %{
	set-option buffer formatcmd 'prettier --parser html'
}

# JSON
hook global BufSetOption filetype=json %{
	set-option buffer formatcmd 'prettier --parser=json'
}

# C & C++
hook global BufSetOption filetype=cpp %{
	set-option buffer clang_options 'std=c++11'
}
hook global BufSetOption filetype=c %{
	set-option buffer clang_options 'std=c11'
}
hook global BufSetOption filetype=(c|cpp) %{
	# clang-enable-autocomplete
	# clang-enable-diagnostics
	# clang-parse
	# set-option window lintcmd 'cpplint'
	set-option window formatcmd 'astyle'
	# set-option window makecmd 'ninja -C build'
	# lint-enable
	# lint
}

# Rust
hook global BufSetOption filetype=rust %{
	set-option buffer formatcmd 'rustfmt'
	set-option buffer makecmd 'cargo'
	set-option buffer tabstop 4
	set-option buffer indentwidth 4
	hook buffer BufWritePre .* format
	# lsp-enable
}

# Elixir
hook global BufSetOption filetype=elixir %{
	set-option buffer formatcmd 'mix format -'
	set-option buffer makecmd 'mix'
	# lsp-enable
}

# Clojure
hook global BufSetOption filetype=clojure %{
	set-option buffer comment_line ';'
	set-option buffer tabstop 1
	set-option buffer indentwidth 1
}

# Python
hook global BufSetOption filetype=python %{
	set-option buffer formatcmd 'black -'
	set-option buffer tabstop 4
	set-option buffer indentwidth 4
}

hook global BufSetOption filetype=scss %{
	set-option buffer formatcmd 'prettier --parser scss'
}

hook global BufSetOption filetype=java %{
	set-option buffer formatcmd 'astyle'
}

hook global BufSetOption filetype=zig %{
	set-option buffer formatcmd 'zig fmt --stdin'
	set-option buffer makecmd  'zig'
	set-option buffer comment_line '//'
	set-option buffer tabstop 4
	set-option buffer indentwidth 4
	hook buffer BufWritePre .* format
}

hook global BufSetOption filetype=dart %{
	set-option buffer formatcmd 'dartfmt'
}

hook global BufSetOption filetype=elm %{
	set-option buffer formatcmd 'elm-format --stdin'
	set-option buffer tabstop 4
	set-option buffer indentwidth 4
}

hook global BufSetOption filetype=toml %{
	set-option buffer tabstop     4
	set-option buffer indentwidth 4
	set-option buffer softtabstop 4
}

hook global BufSetOption filetype=liquid %{
	set-option buffer comment_block_begin '<!--'
	set-option buffer comment_block_end '-->'
	set-option buffer formatcmd 'prettier --parser html'
}

hook global BufSetOption filetype=lua %{
	set-option buffer tabstop     4
	set-option buffer indentwidth 4
	set-option buffer softtabstop 4
}
