let s:json_text_stream = {}
function! json_text_stream#create(file)
  let obj = copy(s:json_text_stream)
  let obj.file = a:file
  let obj.column = 0
  let obj.linenum = 0
  let obj.matched_string = ''
  let obj.lines = readfile(a:file)
  return obj
endfunction

function! s:json_text_stream.match(pattern) dict abort
  while 1
    let match_result = matchstrpos(self.lines[self.linenum], '^\s+$', self.column)
    if empty(match_result[0])
      echom "1 break"
      break
    endif
    let self.column = 0
    let self.linenum += 1
    echom '2 linenum: ' . self.linenum
  endwhile

  echom '3 self.linenum: ' . self.linenum . ', len:' . len(self.lines) 

  if self.linenum < len(self.lines)
    let match_result = matchstrpos(self.lines[self.linenum], '^\s*' . a:pattern, self.column)
    echom '4 match?: ' . a:pattern . ', line: ' . self.lines[self.linenum] . ', match_result[1]: ' . match_result[1]
    if empty(match_result[0])
      echom '5 '
      return 0
    endif
    
    let self.column = match_result[2] 
    let self.matched_string = match_result[0]
    echom '6 column: ' . self.column
    return 1
  endif
  return 0
endfunction


