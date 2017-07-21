hook global InsertChar h %{ try %{
    exec -draft hH <a-k>hh<ret> d
    exec <esc>
}}

set global tabstop 2
set global indentwidth 2 
