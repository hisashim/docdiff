#compdef docdiff

# Zsh completion for DocDiff

_docdiff() {
    integer ret=1
    local -a args
    args+=(
        '--resolution=[specify resolution (granularity)]:resolution:(line word char)'
        '--line[same as --resolution=line]'
        '--word[same as --resolution=word]'
        '--char[same as --resolution=char]'
        '--encoding=[specify character encoding]:encoding:(ASCII EUC-JP Shift_JIS CP932 UTF-8 auto)'
        '--ascii[same as --encoding=ASCII]'
        '--iso8859x[same as --encoding=ASCII]'
        '--eucjp[same as --encoding=EUC-JP]'
        '--sjis[same as --encoding=Shift_JIS]'
        '--cp932[same as --encoding=CP932]'
        '--utf8[same as --encoding=UTF-8]'
        '--eol=[specify end-of-line character]:eol:(CR LF CRLF auto)'
        '--cr[same as --eol=CR]'
        '--lf[same as --eol=LF]'
        '--crlf[same as --eol=CRLF]'
        '--format=[specify output format]:format:(tty manued html wdiff stat user)'
        '--tty[same as --format=tty]'
        '--manued[same as --format=manued]'
        '--html[same as --format=html]'
        '--wdiff[same as --format=wdiff]'
        '--stat[same as --format=stat (not implemented)]'
        '(--label= -L)'{--label=,-L}'[use label instead of file name (not implemented)]:label'
        '--digest[digest output, do not show all]'
        '--summary[same as --digest]'
        '--display=[specify presentation type (effective only with digest)]:type:(inline multi)'
        '--cache[use file cache (not implemented)]'
        '--config-file=[specify config file to read]:config_file:_files'
        '--no-config-file[do not read config files]'
        '--verbose[run verbosely (not well-supported)]'
        '(- *)--help[show this message]'
        '(- *)--version[show version]'
        '(- *)--license[show license]'
        '(- *)--author[show author(s)]'
        '*:file:_files'
    )
    _arguments $args[@] && ret=0
    return ret
}

_docdiff
