# Bash completion for DocDiff

_docdiff_completions()
{
  local cur prev opts
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="\
    --resolution \
    --line --word --char \
    --encoding \
    --ascii --iso8859x --eucjp --sjis --cp932 --utf8 \
    --eol \
    --cr --lf --crlf \
    --format \
    --tty --manued --html --wdiff --stat \
    -L --label \
    --digest --summary \
    --display \
    --cache \
    --no-config-file \
    --config-file \
    --verbose \
    --help \
    --version \
    --license \
    --author\
    "
  COMPREPLY=()

  case ${prev} in
    --resolution)
      COMPREPLY=( $(compgen -W 'line word char' -- "${cur}") )
      return 0
      ;;
    --encoding)
      COMPREPLY=( $(compgen -W 'ASCII EUC-JP Shift_JIS CP932 UTF-8 auto' -- "${cur}") )
      return 0
      ;;
    --eol)
      COMPREPLY=( $(compgen -W 'CR LF CRLF auto' -- "${cur}") )
      return 0
      ;;
    --format)
      COMPREPLY=( $(compgen -W 'tty manued html wdiff stat user' -- "${cur}") )
      return 0
      ;;
    --display)
      COMPREPLY=( $(compgen -W 'inline multi' -- "${cur}") )
      return 0
      ;;
    --config-file)
      COMPREPLY=( $(compgen -A file -- "${cur}") )
      return 0
      ;;
    --help | --version | --license | --author)
      return 0
      ;;
  esac

  if [[ ${cur} == -* ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return
  fi
} &&
  complete -o bashdefault -o default -F _docdiff_completions docdiff
