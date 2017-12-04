hook global BufCreate .*\.kt %{
    set buffer filetype kotlin
}

add-highlighter -group / regions -default code kotlin \
    string %{(?<!')"} %{(?<!\\)(\\\\)*"} '' \
    comment /\* \*/ '' \
    comment // $ ''

add-highlighter -group /kotlin/string fill string
add-highlighter -group /kotlin/string regex \$(\w+|{.*?}) 0:value
add-highlighter -group /kotlin/comment fill comment

add-highlighter -group /kotlin/code regex "\b(this|true|false|it|null|super)\b" 0:value
add-highlighter -group /kotlin/code regex "\b\d(\d|_)*L\b" 0:value
add-highlighter -group /kotlin/code regex "\b(\d(\d|_)*(.\d(\d|_)*)?)((e|E)(\+|-)?\d+)?\b" 0:value
add-highlighter -group /kotlin/code regex "\b((0b(0|1|_)+)|(0o(\d|_)+)|(0d(\d|_)+)|(0[xX]([0-9a-fA-F]|_)+))\b" 0:value
add-highlighter -group /kotlin/code regex "\b(Double|Float|Long|Int|Short|Byte|Char|Boolean|String|Array)\b" 0:type
add-highlighter -group /kotlin/code regex "\b(as|break|class|continue|do|else|false|for|fun|if|in|interface|is|object|package|return|throw|try|typealias|val|var|when|while|by|catch|constructor|finally|get|import|init|set|where|field)\b" 0:keyword
add-highlighter -group /kotlin/code regex "\b(abstract|annotation|companion|const|crossinline|data|enum|external|final|infix|inline|inner|internal|lateinit|noinline|open|operator|out|override|private|protected|public|reified|sealed|suspend|tailrec|vararg)\b" 0:attribute
add-highlighter -group /kotlin/code regex "@\w+\b" 0:attribute

# Commands
# ‾‾‾‾‾‾‾‾

def -hidden kotlin-indent-on-new-line %~
    eval -draft -itersel %=
        # preserve previous line indent
        try %{ exec -draft \;K<a-&> }
        # indent after lines ending with { or (
        try %[ exec -draft k<a-x> <a-k> [{(]\h*$ <ret> j<a-gt> ]
        # cleanup trailing white spaces on the previous line
        try %{ exec -draft k<a-x> s \h+$ <ret>d }
        # align to opening paren of previous line
        try %{ exec -draft [( <a-k> \`\([^\n]+\n[^\n]*\n?\' <ret> s \`\(\h*.|.\' <ret> '<a-;>' & }
        # copy // comments prefix
        try %{ exec -draft \;<c-s>k<a-x> s ^\h*\K/{2,} <ret> y<c-o><c-o>P<esc> }
        # indent after a switch's case/default statements
        try %[ exec -draft k<a-x> <a-k> ^\h*(case|default).*:$ <ret> j<a-gt> ]
        # indent after keywords
        try %[ exec -draft \;<a-F>)MB <a-k> \`(if|else|while|for|try|catch)\h*\(.*\)\h*\n\h*\n?\' <ret> s \`|.\' <ret> 1<a-&>1<a-space><a-gt> ]
    =
~

def -hidden kotlin-indent-on-opening-curly-brace %[
    # align indent with opening paren when { is entered on a new line after the closing paren
    try %[ exec -draft -itersel h<a-F>)M <a-k> \`\(.*\)\h*\n\h*\{\' <ret> s \`|.\' <ret> 1<a-&> ]
]

def -hidden kotlin-indent-on-closing-curly-brace %[
    # align to opening curly brace when alone on a line
    try %[ exec -itersel -draft <a-h><a-k>^\h+\}$<ret>hms\`|.\'<ret>1<a-&> ]
]

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾
hook global WinSetOption filetype=kotlin %{
    # cleanup trailing whitespaces when exiting insert mode
    hook window InsertEnd .* -group kotlin-hooks %{ try %{ exec -draft <a-x>s^\h+$<ret>d } }
    hook window InsertChar \n -group kotlin-indent kotlin-indent-on-new-line
    hook window InsertChar \{ -group kotlin-indent kotlin-indent-on-opening-curly-brace
    hook window InsertChar \} -group kotlin-indent kotlin-indent-on-closing-curly-brace
    set buffer indentwidth 4
    set buffer tabstop 4
}

hook global WinSetOption filetype=(?!kotlin).* %{
    remove-hooks window kotlin-hooks
    remove-hooks window kotlin-indent
}
hook -group kotlin-highlight global WinSetOption filetype=kotlin %{ add-highlighter ref kotlin }
hook -group kotlin-highlight global WinSetOption filetype=(?!kotlin).* %{ remove-highlighter kotlin }
