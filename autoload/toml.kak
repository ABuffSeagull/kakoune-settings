hook global BufCreate .*\.toml %{
    set-option buffer filetype toml
}

add-highlighter shared/ regions -default code toml \
    double_string '"' (?<!\\)(\\\\)*" '' \
    single_string "'" (?<!\\)(\\\\)*' '' \
    comment '(^|\h)\K[#;]' $ ''

add-highlighter shared/toml/code regex "^\h*\[[^\]]*\]" 0:title
add-highlighter shared/toml/code regex "^\h*([^\[][^=\n]*=)" 0:variable
add-highlighter shared/toml/code regex "\b((\d|_)+(\.\d+)?([eE](\+|-)?\d+)?)" 0:value
add-highlighter shared/toml/code regex "\b(true|false)" 0:value

add-highlighter shared/toml/comment fill comment
add-highlighter shared/toml/single_string fill string
add-highlighter shared/toml/double_string fill string

hook -group toml-highlight global WinSetOption filetype=toml %{ add-highlighter window ref toml }
hook -group toml-highlight global WinSetOption filetype=(?!toml).* %{ remove-highlighter window/toml }
