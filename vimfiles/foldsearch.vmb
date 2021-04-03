" Vimball Archiver by Charles E. Campbell
UseVimball
finish
.hgtags	[[[1
4
cbd05088809cee441506f4b9e9e47f2d027e7f04 v1.0.0
cbd05088809cee441506f4b9e9e47f2d027e7f04 v1.0.0
69e896ea55bb6a64123fba3b837b5bc7e6e78b35 v1.1.0
f5dc2399de3b7e9ee098192bf5c6ce5bf6ee2e74 v1.1.1
README.md	[[[1
139
# Foldsearch

This plugin provides commands that fold away lines that don't match a specific
search pattern. This pattern can be the word under the cursor, the last search
pattern, a regular expression or spelling errors. There are also commands to
change the context of the shown lines.

The plugin can be found on [Bitbucket], [GitHub] and [VIM online].

## Commands

### The `:Fw` command

Show lines which contain the word under the cursor.

The optional *context* option consists of one or two numbers:

  - A 'unsigned' number defines the context before and after the pattern.
  - If a number has a '-' prefix, it defines only the context before the pattern.
  - If it has a '+' prefix, it defines only the context after a pattern.

Default *context* is current context.

### The `:Fs` command

Show lines which contain previous search pattern.

For a description of the optional *context* please see |:Fw|

Default *context* is current context.

### The `:Fp` command

Show the lines that contain the given regular expression.

Please see |regular-expression| for patterns that are accepted.

### The `:FS` command

Show the lines that contain spelling errors.

### The `:Fl` command

Fold again with the last used pattern

### The `:Fc` command

Show or modify current *context* lines around matching pattern.

For a description of the optional *context* option please see |:Fw|

### The `:Fi` command

Increment *context* by one line.

### The `:Fd` command

Decrement *context* by one line.

### The `:Fe` command

Set modified fold options to their previous value and end foldsearch.

## Mappings

  - `Leader>fw` : `:Fw` with current context
  - `Leader>fs` : `:Fs` with current context
  - `Leader>fS` : `:FS`
  - `Leader>fl` : `:Fl`
  - `Leader>fi` : `:Fi`
  - `Leader>fd` : `:Fd`
  - `Leader>fe` : `:Fe`

Mappings can be disabled by setting |g:foldsearch_disable_mappings| to 1

## Settings

Use: `let g:option_name=option_value` to set them in your global vimrc.

### The `g:foldsearch_highlight` setting

Highlight the pattern used for folding.

  - Value `0`: Don't highlight pattern
  - Value `1`: Highlight pattern
  - Default: `0`

### The `g:foldsearch_disable_mappings` setting

Disable the mappings. Use this to define your own mappings or to use the
plugin via commands only.

  - Value `0`: Don't disable mappings (use mappings)
  - Value `1`: Disable Mappings
  - Default: `0`

## Contribute

To contact the author (Markus Braun), please send an email to <markus.braun@krawel.de>

If you think this plugin could be improved, fork on [Bitbucket] or [GitHub] and
send a pull request or just tell me your ideas.

## Credits

  - Karl Mowatt-Wilson for bug reports
  - John Appleseed for patches

## Changelog

v1.1.1 : 2014-12-17

  - bugfix: add missing `call` to ex command

v1.1.0 : 2014-12-15

  - use vim autoload feature to load functions on demand
  - better save/restore of modified options

v1.0.1 : 2013-03-20

  - added |g:foldsearch_disable_mappings| config variable

v1.0.0 : 2012-10-10

  - handle multiline regular expressions correctly

v2213 : 2008-07-26

  - fixed a bug in context handling

v2209 : 2008-07-17

  - initial version


[Bitbucket]: https://bitbucket.org/embear/foldsearch
[GitHub]: https://github.com/embear/vim-foldsearch
[VIM online]: http://www.vim.org/scripts/script.php?script_id=2302
RELEASE.md	[[[1
15
# Create a release

  1. Update Changelog in `README.md`
  2. Convert `README.md` to help file: `html2vimdoc -f foldsearch README.md >doc/foldsearch.txt`
  3. Commit current version: `hg commit -m 'prepare release vX.Y.Z'`
  4. Tag version: `hg tag vX.Y.Z -m 'tag release vX.Y.Z'`
  5. Push release to [Bitbucket] and [GitHub]:
    - `hg push ssh://hg@bitbucket.org/embear/foldsearch`
    - `hg push git+ssh://git@github.com:embear/vim-foldsearch.git`
  6. Create a Vimball archive: `hg locate | vim -C -c '%MkVimball! foldsearch .' -c 'q!' -`
  7. Update [VIM online]

[Bitbucket]: https://bitbucket.org/embear/foldsearch
[GitHub]: https://github.com/embear/vim-foldsearch
[VIM online]: http://www.vim.org/scripts/script.php?script_id=2302
autoload/foldsearch/foldsearch.vim	[[[1
389
" Name:    foldsearch.vim
" Version: 1.1.0
" Author:  Markus Braun <markus.braun@krawel.de>
" Summary: Vim plugin to fold away lines that don't match a pattern
" Licence: This program is free software: you can redistribute it and/or modify
"          it under the terms of the GNU General Public License as published by
"          the Free Software Foundation, either version 3 of the License, or
"          (at your option) any later version.
"
"          This program is distributed in the hope that it will be useful,
"          but WITHOUT ANY WARRANTY; without even the implied warranty of
"          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"          GNU General Public License for more details.
"
"          You should have received a copy of the GNU General Public License
"          along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
" Section: Functions {{{1

" Function: foldsearch#foldsearch#FoldCword(...) {{{2
"
" Search and fold the word under the cursor. Accept a optional context argument.
"
function! foldsearch#foldsearch#FoldCword(...)
  " define the search pattern
  let w:foldsearch_pattern = '\<'.expand("<cword>").'\>'

  " determine the number of context lines
  if (a:0 ==  0)
    call foldsearch#foldsearch#FoldSearchDo()
  elseif (a:0 == 1)
    call foldsearch#foldsearch#FoldSearchContext(a:1)
  elseif (a:0 == 2)
    call foldsearch#foldsearch#FoldSearchContext(a:1, a:2)
  endif

endfunction

" Function: foldsearch#foldsearch#FoldSearch(...) {{{2
"
" Search and fold the last search pattern. Accept a optional context argument.
"
function! foldsearch#foldsearch#FoldSearch(...)
  " define the search pattern
  let w:foldsearch_pattern = @/

  " determine the number of context lines
  if (a:0 == 0)
    call foldsearch#foldsearch#FoldSearchDo()
  elseif (a:0 == 1)
    call foldsearch#foldsearch#FoldSearchContext(a:1)
  elseif (a:0 == 2)
    call foldsearch#foldsearch#FoldSearchContext(a:1, a:2)
  endif

endfunction

" Function: foldsearch#foldsearch#FoldPattern(pattern) {{{2
"
" Search and fold the given regular expression.
"
function! foldsearch#foldsearch#FoldPattern(pattern)
  " define the search pattern
  let w:foldsearch_pattern = a:pattern

  " call the folding function
  call foldsearch#foldsearch#FoldSearchDo()
endfunction

" Function: foldsearch#foldsearch#FoldSpell(...)  {{{2
"
" do the search and folding based on spellchecker
"
function! foldsearch#foldsearch#FoldSpell(...)
  " if foldsearch_pattern is not defined, then exit
  if (!&spell)
    echo "Spell checking not enabled, ending Foldsearch"
    return
  endif

  let w:foldsearch_pattern = ''

  " do the search (only search for the first spelling error in line)
  let lnum = 1
  while lnum <= line("$")
    let bad_word = spellbadword(getline(lnum))[0]
    if bad_word != ''
      if empty(w:foldsearch_pattern)
        let w:foldsearch_pattern = '\<\(' . bad_word
      else
        let w:foldsearch_pattern = w:foldsearch_pattern . '\|' . bad_word
      endif
    endif
    let lnum = lnum + 1
  endwhile

  let w:foldsearch_pattern = w:foldsearch_pattern . '\)\>'

  " report if pattern not found and thus no fold created
  if (empty(w:foldsearch_pattern))
    echo "No spelling errors found!"
  else
    " determine the number of context lines
    if (a:0 == 0)
      call foldsearch#foldsearch#FoldSearchDo()
    elseif (a:0 == 1)
      call foldsearch#foldsearch#FoldSearchContext(a:1)
    elseif (a:0 == 2)
      call foldsearch#foldsearch#FoldSearchContext(a:1, a:2)
    endif
  endif

endfunction

" Function: foldsearch#foldsearch#FoldLast(...) {{{2
"
" Search and fold the last pattern
"
function! foldsearch#foldsearch#FoldLast()
  if (!exists("w:foldsearch_context_pre") || !exists("w:foldsearch_context_post") || !exists("w:foldsearch_pattern"))
    return
  endif

  " call the folding function
  call foldsearch#foldsearch#FoldSearchDo()
endfunction

" Function: foldsearch#foldsearch#FoldSearchContext(context) {{{2
"
" Set the context of the folds to the given value
"
function! foldsearch#foldsearch#FoldSearchContext(...)
  " force context to be defined
  if (!exists("w:foldsearch_context_pre"))
    let w:foldsearch_context_pre = 0
  endif
  if (!exists("w:foldsearch_context_post"))
    let w:foldsearch_context_post = 0
  endif

  if (a:0 == 0)
    " if no new context is given display current and exit
    echo "Foldsearch context: pre=".w:foldsearch_context_pre." post=".w:foldsearch_context_post
    return
  else
    let number=1
    let w:foldsearch_context_pre = 0
    let w:foldsearch_context_post = 0
    while number <= a:0
      execute "let argument = a:" . number . ""
      if (strpart(argument, 0, 1) == "-")
	let w:foldsearch_context_pre = strpart(argument, 1)
      elseif (strpart(argument, 0, 1) == "+")
	let w:foldsearch_context_post = strpart(argument, 1)
      else
	let w:foldsearch_context_pre = argument
	let w:foldsearch_context_post = argument
      endif
      let number = number + 1
    endwhile
  endif

  if (w:foldsearch_context_pre < 0)
    let w:foldsearch_context_pre = 0
  endif
  if (w:foldsearch_context_post < 0)
    let w:foldsearch_context_post = 0
  endif

  " call the folding function
  call foldsearch#foldsearch#FoldSearchDo()
endfunction

" Function: foldsearch#foldsearch#FoldContextAdd(change) {{{2
"
" Change the context of the folds by the given value.
"
function! foldsearch#foldsearch#FoldContextAdd(change)
  " force context to be defined
  if (!exists("w:foldsearch_context_pre"))
    let w:foldsearch_context_pre = 0
  endif
  if (!exists("w:foldsearch_context_post"))
    let w:foldsearch_context_post = 0
  endif

  let w:foldsearch_context_pre = w:foldsearch_context_pre + a:change
  let w:foldsearch_context_post = w:foldsearch_context_post + a:change

  if (w:foldsearch_context_pre < 0)
    let w:foldsearch_context_pre = 0
  endif
  if (w:foldsearch_context_post < 0)
    let w:foldsearch_context_post = 0
  endif

  " call the folding function
  call foldsearch#foldsearch#FoldSearchDo()
endfunction

" Function: foldsearch#foldsearch#FoldSearchInit() {{{2
"
" initialize fold searching for current buffer
"
function! foldsearch#foldsearch#FoldSearchInit()
  " force context to be defined
  if (!exists("w:foldsearch_context_pre"))
    let w:foldsearch_context_pre = 0
  endif
  if (!exists("w:foldsearch_context_post"))
    let w:foldsearch_context_post = 0
  endif

  " save current setup
  if (!exists("w:foldsearch_viewfile"))
    " save user settings before making changes
    let w:foldsearch_foldtext = &foldtext
    let w:foldsearch_foldmethod = &foldmethod
    let w:foldsearch_foldenable = &foldenable
    let w:foldsearch_foldminlines = &foldminlines

    " modify settings
    let &foldtext = ""
    let &foldmethod = "manual"
    let &foldenable = 1
    let &foldminlines = 0

    " create a file for view options
    let w:foldsearch_viewfile = tempname()

    " make a view of the current file for later restore of manual folds
    let l:viewoptions = &viewoptions
    let &viewoptions = "folds"
    execute "mkview " . w:foldsearch_viewfile
    let &viewoptions = l:viewoptions

    " for unnamed buffers, an 'enew' command gets added to the view which we
    " need to filter out.
    let l:lines = readfile(w:foldsearch_viewfile)
    call filter(l:lines, 'v:val != "enew"')
    call writefile(l:lines, w:foldsearch_viewfile)
  endif

  " erase all folds to begin with
  normal! zE
endfunction

" Function: foldsearch#foldsearch#FoldSearchDo()  {{{2
"
" do the search and folding based on w:foldsearch_pattern and
" w:foldsearch_context
"
function! foldsearch#foldsearch#FoldSearchDo()
  " if foldsearch_pattern is not defined, then exit
  if (!exists("w:foldsearch_pattern"))
    echo "No search pattern defined, ending fold search"
    return
  endif

  " initialize fold search for this buffer
  call foldsearch#foldsearch#FoldSearchInit()

  " highlight search pattern if requested
  if (g:foldsearch_highlight == 1)
    if (exists("w:foldsearch_highlight_id"))
      call matchdelete(w:foldsearch_highlight_id)
    endif
    let w:foldsearch_highlight_id = matchadd("Search", w:foldsearch_pattern)
  endif

  " save cursor position
  let cursor_position = line(".") . "normal!" . virtcol(".") . "|"

  " move to the end of the file
  normal! $G$
  let pattern_found = 0      " flag to set when search pattern found
  let fold_created = 0       " flag to set when a fold is found
  let flags = "w"            " allow wrapping in the search
  let line_fold_start =  0   " set marker for beginning of fold

  " do the search
  while search(w:foldsearch_pattern, flags) > 0
    " patern had been found
    let pattern_found = 1

    " determine end of fold
    let line_fold_end = line(".") - 1 - w:foldsearch_context_pre

    " validate line of fold end and set fold
    if (line_fold_end >= line_fold_start && line_fold_end != 0)
      " create fold
      execute ":" . line_fold_start . "," . line_fold_end . " fold"

      " at least one fold has been found
      let fold_created = 1
    endif

    " jump to the end of this match. needed for multiline searches
    call search(w:foldsearch_pattern, flags . "ce")

    " update marker
    let line_fold_start = line(".") + 1 + w:foldsearch_context_post

    " turn off wrapping
    let flags = "W"
  endwhile

  " now create the last fold which goes to the end of the file.
  normal! $G
  let  line_fold_end = line(".")
  if (line_fold_end  >= line_fold_start && pattern_found == 1)
    execute ":". line_fold_start . "," . line_fold_end . "fold"
  endif

  " report if pattern not found and thus no fold created
  if (pattern_found == 0)
    echo "Pattern not found!"
  elseif (fold_created == 0)
    echo "No folds created"
  else
    echo "Foldsearch done"
  endif

  " restore position before folding
  execute cursor_position

  " make this position the vertical center
  normal! zz

endfunction

" Function: foldsearch#foldsearch#FoldSearchEnd() {{{2
"
" End the fold search and restore the saved settings
"
function! foldsearch#foldsearch#FoldSearchEnd()
  " save cursor position
  let cursor_position = line(".") . "normal!" . virtcol(".") . "|"

  " restore the folds before foldsearch
  if (exists("w:foldsearch_viewfile"))
    execute "silent! source " . w:foldsearch_viewfile
    call delete(w:foldsearch_viewfile)
    unlet w:foldsearch_viewfile

    " restore user settings before making changes
    let &foldtext = w:foldsearch_foldtext
    let &foldmethod = w:foldsearch_foldmethod
    let &foldenable = w:foldsearch_foldenable
    let &foldminlines = w:foldsearch_foldminlines

    " remove user settings after restoring them
    unlet w:foldsearch_foldtext
    unlet w:foldsearch_foldmethod
    unlet w:foldsearch_foldenable
    unlet w:foldsearch_foldminlines
  endif

  " delete highlighting
  if (exists("w:foldsearch_highlight_id"))
    call matchdelete(w:foldsearch_highlight_id)
    unlet w:foldsearch_highlight_id
  endif

  " give a message to the user
  echo "Foldsearch ended"

  " open all folds for the current cursor position
  normal! zv

  " restore position before folding
  execute cursor_position

  " make this position the vertical center
  normal! zz

endfunction

" Function: foldsearch#foldsearch#FoldSearchDebug(level, text) {{{2
"
" output debug message, if this message has high enough importance
"
function! foldsearch#foldsearch#FoldSearchDebug(level, text)
  if (g:foldsearch_debug >= a:level)
    echom "foldsearch: " . a:text
  endif
endfunction

" vim600: foldmethod=marker foldlevel=1 :
doc/foldsearch.txt	[[[1
196
*foldsearch*  Foldsearch

===============================================================================
Contents ~

 1. Introduction                                      |foldsearch-introduction|
 2. Commands                                              |foldsearch-commands|
  1. The |:Fw| command
  2. The |:Fs| command
  3. The |:Fp| command
  4. The |:FS| command
  5. The |:Fl| command
  6. The |:Fc| command
  7. The |:Fi| command
  8. The |:Fd| command
  9. The |:Fe| command
 3. Mappings                                              |foldsearch-mappings|
 4. Settings                                              |foldsearch-settings|
  1. The |g:foldsearch_highlight| setting
  2. The |g:foldsearch_disable_mappings| setting
 5. Contribute                                          |foldsearch-contribute|
 6. Credits                                                |foldsearch-credits|
 7. Changelog                                            |foldsearch-changelog|
 8. References                                          |foldsearch-references|

===============================================================================
                                                      *foldsearch-introduction*
Introduction ~

This plugin provides commands that fold away lines that don't match a specific
search pattern. This pattern can be the word under the cursor, the last search
pattern, a regular expression or spelling errors. There are also commands to
change the context of the shown lines.

The plugin can be found on Bitbucket [1], GitHub [2] and VIM online [3].

===============================================================================
                                                          *foldsearch-commands*
Commands ~

-------------------------------------------------------------------------------
The *:Fw* command

Show lines which contain the word under the cursor.

The optional _context_ option consists of one or two numbers:

- A 'unsigned' number defines the context before and after the pattern.
- If a number has a '-' prefix, it defines only the context before the
  pattern.
- If it has a '+' prefix, it defines only the context after a pattern.

Default _context_ is current context.

-------------------------------------------------------------------------------
The *:Fs* command

Show lines which contain previous search pattern.

For a description of the optional _context_ please see |:Fw|

Default _context_ is current context.

-------------------------------------------------------------------------------
The *:Fp* command

Show the lines that contain the given regular expression.

Please see |regular-expression| for patterns that are accepted.

-------------------------------------------------------------------------------
The *:FS* command

Show the lines that contain spelling errors.

-------------------------------------------------------------------------------
The *:Fl* command

Fold again with the last used pattern

-------------------------------------------------------------------------------
The *:Fc* command

Show or modify current _context_ lines around matching pattern.

For a description of the optional _context_ option please see |:Fw|

-------------------------------------------------------------------------------
The *:Fi* command

Increment _context_ by one line.

-------------------------------------------------------------------------------
The *:Fd* command

Decrement _context_ by one line.

-------------------------------------------------------------------------------
The *:Fe* command

Set modified fold options to their previous value and end foldsearch.

===============================================================================
                                                          *foldsearch-mappings*
Mappings ~

- 'Leader>fw' : |:Fw| with current context
- 'Leader>fs' : |:Fs| with current context
- 'Leader>fS' : |:FS|
- 'Leader>fl' : |:Fl|
- 'Leader>fi' : |:Fi|
- 'Leader>fd' : |:Fd|
- 'Leader>fe' : |:Fe|

Mappings can be disabled by setting |g:foldsearch_disable_mappings| to 1

===============================================================================
                                                          *foldsearch-settings*
Settings ~

Use: 'let g:option_name=option_value' to set them in your global vimrc.

-------------------------------------------------------------------------------
The *g:foldsearch_highlight* setting

Highlight the pattern used for folding.

- Value '0': Don't highlight pattern
- Value '1': Highlight pattern
- Default: '0'

-------------------------------------------------------------------------------
The *g:foldsearch_disable_mappings* setting

Disable the mappings. Use this to define your own mappings or to use the plugin
via commands only.

- Value '0': Don't disable mappings (use mappings)
- Value '1': Disable Mappings
- Default: '0'

===============================================================================
                                                        *foldsearch-contribute*
Contribute ~

To contact the author (Markus Braun), please send an email to
markus.braun@krawel.de

If you think this plugin could be improved, fork on Bitbucket [1] or GitHub [2]
and send a pull request or just tell me your ideas.

===============================================================================
                                                           *foldsearch-credits*
Credits ~

- Karl Mowatt-Wilson for bug reports
- John Appleseed for patches

===============================================================================
                                                         *foldsearch-changelog*
Changelog ~

v1.1.1 : 2014-12-17

- bugfix: add missing 'call' to ex command

v1.1.0 : 2014-12-15

- use vim autoload feature to load functions on demand
- better save/restore of modified options

v1.0.1 : 2013-03-20

- added |g:foldsearch_disable_mappings| config variable

v1.0.0 : 2012-10-10

- handle multiline regular expressions correctly

v2213 : 2008-07-26

- fixed a bug in context handling

v2209 : 2008-07-17

- initial version

===============================================================================
                                                        *foldsearch-references*
References ~

[1] https://bitbucket.org/embear/foldsearch
[2] https://github.com/embear/vim-foldsearch
[3] http://www.vim.org/scripts/script.php?script_id=2302

vim: ft=help
plugin/foldsearch.vim	[[[1
85
" Name:    foldsearch.vim
" Version: 1.1.0
" Author:  Markus Braun <markus.braun@krawel.de>
" Summary: Vim plugin to fold away lines that don't match a pattern
" Licence: This program is free software: you can redistribute it and/or modify
"          it under the terms of the GNU General Public License as published by
"          the Free Software Foundation, either version 3 of the License, or
"          (at your option) any later version.
"
"          This program is distributed in the hope that it will be useful,
"          but WITHOUT ANY WARRANTY; without even the implied warranty of
"          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"          GNU General Public License for more details.
"
"          You should have received a copy of the GNU General Public License
"          along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
" Section: Plugin header {{{1

" guard against multiple loads {{{2
if (exists("g:loaded_foldsearch") || &cp)
  finish
endi
let g:loaded_foldsearch = 1

" check for correct vim version {{{2
" matchadd() requires at least 7.1.40
if !(v:version > 701 || (v:version == 701 && has("patch040")))
  finish
endif

" define default "foldsearch_highlight" {{{2
if (!exists("g:foldsearch_highlight"))
  let g:foldsearch_highlight = 0
endif

" define default "foldsearch_disable_mappings" {{{2
if (!exists("g:foldsearch_disable_mappings"))
  let g:foldsearch_disable_mappings = 0
endif

" define default "foldsearch_debug" {{{2
if (!exists("g:foldsearch_debug"))
  let g:foldsearch_debug = 0
endif

" Section: Commands {{{1

command! -nargs=* -complete=command Fs call foldsearch#foldsearch#FoldSearch(<f-args>)
command! -nargs=* -complete=command Fw call foldsearch#foldsearch#FoldCword(<f-args>)
command! -nargs=1 Fp call foldsearch#foldsearch#FoldPattern(<q-args>)
command! -nargs=* -complete=command FS call foldsearch#foldsearch#FoldSpell(<f-args>)
command! -nargs=0 Fl call foldsearch#foldsearch#FoldLast()
command! -nargs=* Fc call foldsearch#foldsearch#FoldSearchContext(<f-args>)
command! -nargs=0 Fi call foldsearch#foldsearch#FoldContextAdd(+1)
command! -nargs=0 Fd call foldsearch#foldsearch#FoldContextAdd(-1)
command! -nargs=0 Fe call foldsearch#foldsearch#FoldSearchEnd()

" Section: Mappings {{{1

if !g:foldsearch_disable_mappings
   map <Leader>fs :call foldsearch#foldsearch#FoldSearch()<CR>
   map <Leader>fw :call foldsearch#foldsearch#FoldCword()<CR>
   map <Leader>fS :call foldsearch#foldsearch#FoldSpell()<CR>
   map <Leader>fl :call foldsearch#foldsearch#FoldLast()<CR>
   map <Leader>fi :call foldsearch#foldsearch#FoldContextAdd(+1)<CR>
   map <Leader>fd :call foldsearch#foldsearch#FoldContextAdd(-1)<CR>
   map <Leader>fe :call foldsearch#foldsearch#FoldSearchEnd()<CR>
endif

" Section: Menu {{{1

if has("menu")
  amenu <silent> Plugin.FoldSearch.Context.Increment\ One\ Line :Fi<CR>
  amenu <silent> Plugin.FoldSearch.Context.Decrement\ One\ Line :Fd<CR>
  amenu <silent> Plugin.FoldSearch.Context.Show :Fc<CR>
  amenu <silent> Plugin.FoldSearch.Search :Fs<CR>
  amenu <silent> Plugin.FoldSearch.Current\ Word :Fw<CR>
  amenu <silent> Plugin.FoldSearch.Pattern :Fp
  amenu <silent> Plugin.FoldSearch.Spelling :FS<CR>
  amenu <silent> Plugin.FoldSearch.Last :Fl<CR>
  amenu <silent> Plugin.FoldSearch.End :Fe<CR>
endif

" vim600: foldmethod=marker foldlevel=0 :
