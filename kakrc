hook global InsertChar h %{ try %{
    exec -draft hH <a-k>hh<ret> d
    exec <esc>
}}
