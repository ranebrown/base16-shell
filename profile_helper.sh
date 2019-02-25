#!/usr/bin/env bash
if [ -s $BASH ]; then
    file_name=${BASH_SOURCE[0]}
elif [ -s $ZSH_NAME ]; then
    file_name=${(%):-%x}
fi
script_dir=$(cd $(dirname $file_name) && pwd)

# shellcheck source=/dev/null
. $script_dir/realpath/realpath.sh

if [ -f ~/.base16_theme ]; then
  script_name=$(basename "$(realpath ~/.base16_theme)" .sh)
  export BASE16_THEME=${script_name#*-}
  # shellcheck source=/dev/null
  . ~/.base16_theme
fi
# shellcheck source=/dev/null
base16()
{
  local script=$BASE16_SHELL/scripts/base16-${1}.sh
  if [ -f "$script" ]; then
      . "$script"
  else
    script=$BASE16_SHELL/scripts/${1}.sh
    [ -f "$script" ] && . "$script"
  fi
  ln -fs "$script" ~/.base16_theme
  export BASE16_THEME=${1%.sh}

  # special colorscheme handling
  if [ "${1}" == "ayu-dark" ]; then
    echo -e "if \0041exists('g:colors_name') || g:colors_name != 'base16-$1' || g:colors_name != '$1'\n  try\n    colorscheme base16-$1\n  catch /^Vim\%((\\\a\\+)\)\=:E185/\n    let ayucolor=\"dark\"\n    colorscheme ayu\n  endtry\nendif" >| ~/.vimrc_background
  elif [ "${1}" == "ayu-mirage" ]; then
    echo -e "if \0041exists('g:colors_name') || g:colors_name != 'base16-$1' || g:colors_name != '$1'\n  try\n    colorscheme base16-$1\n  catch /^Vim\%((\\\a\\+)\)\=:E185/\n    let ayucolor=\"mirage\"\n    let g:airline_theme=\"ayu_mirage\"\n    colorscheme ayu\n  endtry\nendif" >| ~/.vimrc_background
  elif [ "${1}" == "ayu-light" ]; then
    echo -e "if \0041exists('g:colors_name') || g:colors_name != 'base16-$1' || g:colors_name != '$1'\n  try\n    colorscheme base16-$1\n  catch /^Vim\%((\\\a\\+)\)\=:E185/\n    set background=light\n    let ayucolor=\"light\"\n    colorscheme ayu\n  endtry\nendif" >| ~/.vimrc_background
  else
    # standard colorschemes
    echo -e "if \0041exists('g:colors_name') || g:colors_name != 'base16-$1' || g:colors_name != '$1'\n  try\n    colorscheme base16-$1\n  catch /^Vim\%((\\\a\\+)\)\=:E185/\n    colorscheme $1\n  endtry\nendif" >| ~/.vimrc_background
  fi
}

_base16()
{
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts=$(cd "$BASE16_SHELL"/scripts && for script in ./*.sh; do tmp=${script#*base16-}; echo "${tmp%.sh}"; done)
    mapfile -t COMPREPLY < <(compgen -W "$opts" -- "${cur}")
    return 0
}
complete -F _base16 base16
