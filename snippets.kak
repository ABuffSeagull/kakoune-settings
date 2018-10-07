hook global WinSetOption filetype=vue %{
  set-option -add buffer snippets \
  	scaffold '<lt>template<gt><ret>  #<ret><lt>/template<gt><ret><ret><lt>script<gt><ret>export default {<ret>  #<ret>};<ret><lt>/script<gt><esc>/#<ret>c'
}
