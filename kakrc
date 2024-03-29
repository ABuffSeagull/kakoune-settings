### Plugins ###
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

# plug "kak-lsp/kak-lsp" tag "v12.0.1" do %{ cargo install --locked --path . } config %{
#     hook global WinSetOption filetype=(typescript|elixir|python|liquid) %{
#         lsp-enable-window
#     }
#     map global user l %{: enter-user-mode lsp<ret>} -docstring "LSP mode"

#     face global InfoDefault               Information
#     face global InfoBlock                 Information
#     face global InfoBlockQuote            Information
#     face global InfoBullet                Information
#     face global InfoHeader                Information
#     face global InfoLink                  Information
#     face global InfoLinkMono              Information
#     face global InfoMono                  Information
#     face global InfoRule                  Information
#     face global InfoDiagnosticError       Information
#     face global InfoDiagnosticHint        Information
#     face global InfoDiagnosticInformation Information
#     face global InfoDiagnosticWarning     Information
# }

plug "h-youhei/kakoune-surround" %{
	declare-user-mode surround
	map global user 's' ': surround<ret>' -docstring 'add surround'
	map global user 'c' ': change-surround<ret>' -docstring 'change surround'
	map global user 'd' ': delete-surround<ret>' -docstring 'delete surround'
}

plug "eraserhd/parinfer-rust" do %{ cargo install --path . } config %{
	hook global WinSetOption filetype=(clojure|scheme|lisp) 'parinfer-enable-window -indent'
}

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
} defer fzf-grep %{
	set-option global fzf_grep_command 'rg'
}

plug "alexherbo2/volatile-highlighter.kak" demand volatile-highlighter %{
  volatile-highlighter-enable
}

plug "abuffseagull/kakoune-toggler" do %{ cargo install --path . } %{
	map global user t ': toggle-word<ret>' -docstring 'toggle word'
	map global user T ': toggle-WORD<ret>' -docstring 'toggle WORD'
}

plug "andreyorst/smarttab.kak" defer smarttab %{
	set-option global softtabstop 4
} config %{
	hook global BufSetOption filetype=* expandtab
	hook global BufSetOption filetype=(elixir|eex|scheme|lisp) %[
		set-option buffer softtabstop 2
		set-option buffer tabstop 2
		set-option buffer indentwidth 2
	]
	define-command width -params 1 %{
		set-option buffer indentwidth %arg{1}
		set-option buffer tabstop %arg{1}
		# set-option buffer softtabstop %arg{1}
	}
}

plug "uniquepointer/pastebin.kak" %{
	map global user Y ": enter-pastebin-mode<ret>" -docstring "pastebin"
}

# TODO: make this into a plugin
hook global KakBegin .* idsession

plug "occivink/kakoune-sudo-write"
plug "abuffseagull/kakoune-vue"
plug "delapouite/kakoune-auto-percent"
plug "eraserhd/kak-ansi"

plug "abuffseagull/nord.kak" theme %{ colorscheme nord }

plug "vurich/zig-kak"
plug "abuffseagull/liquid.kak"
plug "abuffseagull/odin-kak"
plug "stoand/kakoune-mercury"

### Indenting ###
set-option global tabstop     4
set-option global indentwidth 4
set-option global aligntab    false

### UX Stuff ###
# Mouse Support
set-option -add global ui_options ncurses_enable_mouse=true ncurses_set_title=true
# Double h instead of escape
hook global InsertChar h %{ try %{
exec -draft hH <a-k>hh<ret> d
		exec <esc>
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

map global normal '<a-c>' 'Glc'
map global normal '<a-d>' 'Gld'
map global goto L l
map global goto H h
map global normal / '/(?i)'
map global normal '<a-/>' '<a-/>(?i)'

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

hook global WinCreate ^[^*]+$ %{ editorconfig-load }

define-command haste %{
	execute-keys Z\%<a-|>haste<space>|<space>xsel<space><minus>ib<ret>z
}


set-option global autoreload yes

### UI Stuff ###
hook global WinCreate .* %{
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

hook global InsertChar , %{ try %{
	exec -draft hH <a-k>,,<ret> d
	exec <esc>Gi_|<space>emmet<ret>
}}

### Language Specific Stuff ###
hook global BufSetOption filetype=(vue|html|json|s?css) %{
	set-option buffer formatcmd "npx prettier --stdin-filepath %val{buffile}"
}

hook global BufSetOption filetype=(javascript|typescript) %{
	set-option buffer formatcmd "deno fmt -"
	hook buffer BufWritePre .* format
}

# hook global BufSetOption filetype=(javascript|typescript|vue|html) %{
#   set-option buffer makecmd 'npm'
#   lint-enable
#   lint
# }

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
	hook buffer BufWritePre .* format
}

# Elixir
hook global BufSetOption filetype=elixir %{
	set-option buffer formatcmd 'mix format -'
	set-option buffer makecmd 'mix'
}

# Clojure
hook global BufSetOption filetype=(clojure|scheme|lisp) %{
	set-option buffer comment_line ';'
}

# Python
hook global BufSetOption filetype=python %{
	set-option buffer formatcmd 'black -'
}

hook global BufSetOption filetype=java %{
	set-option buffer formatcmd 'astyle'
}

hook global BufSetOption filetype=zig %{
	set-option buffer formatcmd 'zig fmt --stdin'
	set-option buffer makecmd  'zig'
	set-option buffer comment_line '//'
	hook buffer BufWritePre .* format
}

hook global BufSetOption filetype=dart %{
	set-option buffer formatcmd 'dartfmt'
}

hook global BufSetOption filetype=elm %{
	set-option buffer formatcmd 'elm-format --stdin'
}

hook global BufSetOption filetype=liquid %{
	set-option buffer comment_block_begin '<!--'
	set-option buffer comment_block_end '-->'
set-option buffer formatcmd 'prettier --parser html'
}

hook global BufCreate .*\.rkt %{
	set-option buffer filetype scheme
}
