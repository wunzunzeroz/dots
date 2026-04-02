#  mttchpmn          _
#          ____ ___ | |__  _ __ ___
#         |_  // __|| '_ \| '__/ __|
#          / / \__ \| | | | | | (__
#         /___||___/|_| |_|_|  \___|
#
# Modular zsh config -- sources conf files in order.

ZSH_CONF_DIR="$HOME/.zsh/conf"

source "$ZSH_CONF_DIR/options.conf"
source "$ZSH_CONF_DIR/path.conf"
source "$ZSH_CONF_DIR/aliases.conf"
source "$ZSH_CONF_DIR/functions.conf"
source "$ZSH_CONF_DIR/plugins.conf"
source "$ZSH_CONF_DIR/tools.conf"

# Starship prompt (must be last -- sets up precmd hooks)
eval "$(starship init zsh)"
