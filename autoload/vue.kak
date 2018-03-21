# http://w3.org/vue
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.vue %{
    set-option buffer filetype vue
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/ regions vue                  \
    comment <!--     -->                  '' \
    tag     <          >                  '' \
    style   <style\b.*?>\K  (?=</style>)  '' \
    script  <script\b.*?>\K (?=</script>) ''

add-highlighter shared/vue/comment fill comment

add-highlighter shared/vue/style  ref scss
add-highlighter shared/vue/script ref ecmascript

add-highlighter shared/vue/tag regex \b([a-zA-Z0-9_-]+)=? 1:attribute
add-highlighter shared/vue/tag regex </?(\w+) 1:keyword

add-highlighter shared/vue/tag regions content \
    string '"' (?<!\\)(\\\\)*"      '' \
    string "'" "'"                  ''

add-highlighter shared/vue/tag/content/string fill string

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden vue-filter-around-selections %{
    # remove trailing white spaces
    try %{ execute-keys -draft -itersel <a-x> s \h+$ <ret> d }
}

define-command -hidden vue-indent-on-greater-than %[
    evaluate-commands -draft -itersel %[
        # align closing tag to opening when alone on a line
        try %[ execute-keys -draft <space> <a-h> s ^\h+<lt>/(\w+)<gt>$ <ret> {c<lt><c-r>1,<lt>/<c-r>1<gt> <ret> s \A|.\z <ret> 1<a-&> ]
    ]
]

define-command -hidden vue-indent-on-new-line %{
    evaluate-commands -draft -itersel %{
        # preserve previous line indent
        try %{ execute-keys -draft \; K <a-&> }
        # filter previous line
        try %{ execute-keys -draft k : vue-filter-around-selections <ret> }
        # indent after lines ending with opening tag
        try %{ execute-keys -draft k <a-x> <a-k> <[^/][^>]+>$ <ret> j <a-gt> }
    }
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook -group vue-highlight global WinSetOption filetype=(vue) %{ add-highlighter window ref vue }

hook global WinSetOption filetype=(vue) %{
    hook window ModeChange insert:.* -group vue-hooks  vue-filter-around-selections
    hook window InsertChar '>' -group vue-indent vue-indent-on-greater-than
    hook window InsertChar \n -group vue-indent vue-indent-on-new-line
}

hook -group vue-highlight global WinSetOption filetype=(?!vue).* %{ remove-highlighter window/vue }

hook global WinSetOption filetype=(?!vue).* %{
    remove-hooks window vue-indent
    remove-hooks window vue-hooks
}
