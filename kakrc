# Double h instead of escape
hook global InsertChar h %{ try %{
    exec -draft hH <a-k>hh<ret> d
    exec <esc>
}}

# Indenting
set global tabstop 2
set global indentwidth 2

# Highlight 81 column
hook global WinCreate .* %{
  addhl regex ^(\t|\V{2}){40}(\V) 2:Error
}

# Number the lines
hook global WinCreate .* %{
  addhl number_lines
}
