set -o vi
bind -m vi-command '"/": reverse-search-history'
bind -m vi-command '"H": beginning-of-line'
bind -m vi-command '"L": end-of-line'
bind -m vi-insert '"\C-l": clear-screen'
