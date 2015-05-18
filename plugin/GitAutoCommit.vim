let s:max_writes = get(g:, 'commit_after', 5)

let s:branch = ''
let s:commit = ''
let s:writes = 0

function! s:GitCommit()
    " Check if we are under version control
    " exit if not
    call system('git rev-parse --git-dir > /dev/null 2>&1')
    if v:shell_error
        return
    endif

    " Initialize variables.
    let branch = system('git rev-parse --abbrev-ref HEAD')
    let commit = system('git rev-parse --verify HEAD')

    if s:branch !=# branch || s:commit !=# commit
        let s:writes = 0
    endif

    let s:branch = branch
    let s:commit = commit

    if s:writes >= s:max_writes
        let message = input('Commit message? ', '')
        if message == ""
            let s:writes = s:writes + 1
            return
        endif
        call system('git add ' . expand('%:p'))
        call system('git commit -m ' . shellescape(message, 1))
        let s:writes = 0
    endif

    " increase number of uncommited saves
    let s:writes = s:writes + 1

endfun

augroup GitAutoCommit
    autocmd!
    autocmd BufWritePost * call s:GitCommit()
augroup END

