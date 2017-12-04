# Odin Programming language
#

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.odin %{
    set buffer filetype odin
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter -group / regions -default code odin \
    back_string '`' '`' '' \
    double_string '"' (?<!\\)(\\\\)*" '' \
    single_string "'" (?<!\\)(\\\\)*' '' \
    comment /\* \*/ '' \
    comment '//' $ ''

add-highlighter -group /odin/back_string fill string
add-highlighter -group /odin/double_string fill string
add-highlighter -group /odin/single_string fill string
add-highlighter -group /odin/comment fill comment

add-highlighter -group /odin/code regex %{\b(\d(\d|_)*(.\d(\d|_)*)?)((e|E)(\+|-)?\d+)?[ijk]?\b} 0:value
add-highlighter -group /odin/code regex %{\b((0b(0|1|_)+)|(0o(\d|_)+)|(0d(\d|_)+)|(0[xX]([0-9a-fA-F]|_)+))[ijk]?\b} 0:value

%sh{
    # Grammar
    keywords="import|export|foreign|foreign_library|forein_system_library"
    keywords="${keywords}|if|else|when|for|in|defer|match|return|const"
    keywords="${keywords}|fallthrough|break|continue|case|vector|static|dynamic|atomic"
    keywords="${keywords}|using|do|asm|yield|await|context|push_allocator|push_context"
    types="var|let|type|macro|struct|enum|union|map|bit_field"
    types="${types}|i8|i16|i32|i64|i128|int|u8|u16|u32|u64|u128|uint"
    types="${types}|f16|f32|f64|complex16|complex32|complex64|complex128"
    types="${types}|quaternion128|quaternion256|byte|bool|string|rune|rawptr|any"
    values="false|true|nil"
    functions="cast|transmute|proc|make|new|new_clone|size_of|align_of|offset_of"
    functions="${functions}|type_of|type_info_of|expand_to_tuple"
    ### Leftover stuff from the original ###
      #scope: keyword.function.odin
    #- match: '(#\s*{{identifier}})'
      # scope: storage.constant.tag.odin
      # scope: constant.numeric.tag.odin
      #scope: keyword.tag.odin
    #- match: \b(context)\b
      #scope: keyword.operator.odin

    # Add the language's grammar to the static completion list
    printf %s\\n "hook global WinSetOption filetype=odin %{
        set window static_words '${keywords}:${types}:${values}:${functions}'
    }" | sed 's,|,:,g'

    # Highlight keywords
    printf %s "
        add-highlighter -group /odin/code regex \b(${keywords})\b 0:keyword
        add-highlighter -group /odin/code regex \b(${attributes})\b 0:attribute
        add-highlighter -group /odin/code regex \b(${types})\b 0:type
        add-highlighter -group /odin/code regex \b(${values})\b 0:value
        add-highlighter -group /odin/code regex \b(${functions})\b 0:builtin
    "
}

# Commands
# ‾‾‾‾‾‾‾‾

def -hidden odin-indent-on-new-line %~
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
        # indent after if|else|while|for
        try %[ exec -draft \;<a-F>)MB <a-k> \`(if|else|while|for)\h*\(.*\)\h*\n\h*\n?\' <ret> s \`|.\' <ret> 1<a-&>1<a-space><a-gt> ]
    =
~

def -hidden odin-indent-on-opening-curly-brace %[
    # align indent with opening paren when { is entered on a new line after the closing paren
    try %[ exec -draft -itersel h<a-F>)M <a-k> \`\(.*\)\h*\n\h*\{\' <ret> s \`|.\' <ret> 1<a-&> ]
]

def -hidden odin-indent-on-closing-curly-brace %[
    # align to opening curly brace when alone on a line
    try %[ exec -itersel -draft <a-h><a-k>^\h+\}$<ret>hms\`|.\'<ret>1<a-&> ]
]

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook -group odin-highlight global WinSetOption filetype=odin %{ add-highlighter ref odin }

hook global WinSetOption filetype=odin %{
    # cleanup trailing whitespaces when exiting insert mode
    hook window InsertEnd .* -group odin-hooks %{ try %{ exec -draft <a-x>s^\h+$<ret>d } }
    hook window InsertChar \n -group odin-indent odin-indent-on-new-line
    hook window InsertChar \{ -group odin-indent odin-indent-on-opening-curly-brace
    hook window InsertChar \} -group odin-indent odin-indent-on-closing-curly-brace
    set buffer comment_line '//'
    set buffer comment_block '/*:*/'
}

hook -group odin-highlight global WinSetOption filetype=(?!odin).* %{ remove-highlighter odin }

hook global WinSetOption filetype=(?!odin).* %{
    remove-hooks window odin-hooks
    remove-hooks window odin-indent
}
