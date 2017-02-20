
function! json_tokenizer#test()
  let stream = json_text_stream#create('test.json')
  let tokenizer = json_tokenizer#create(stream)

  echom tokenizer.next_token() . ', ' . tokenizer.token
  echom tokenizer.next_token() . ', ' . tokenizer.token
  echom tokenizer.next_token() . ', ' . tokenizer.token
  echom tokenizer.next_token() . ', ' . tokenizer.token
  echom tokenizer.next_token() . ', ' . tokenizer.token
  echom tokenizer.next_token() . ', ' . tokenizer.token
  echom tokenizer.next_token() . ', ' . tokenizer.token
  echom tokenizer.next_token() . ', ' . tokenizer.token

endfunction

let s:json_tokenizer = {}
function! json_tokenizer#create(text_stream)
  let obj = copy(s:json_tokenizer)
  let obj.input = a:text_stream
  let obj.token = ''
  let obj.token_type = 'INIT'
  return obj
endfunction

function! s:json_tokenizer.next_token() dict abort
  if self.input.match('-\?\d\+(\.\d\+)\?([eE]\d+)?')
    let self.token = self.input.matched_string
    let self.token_type = 'NUMBER'
  elseif self.input.match('"(\"|[^"])*"')
    let self.token = self.input.matched_string
    let self.token_type = 'STRING'
  elseif self.input.match('(true|false)')
    let self.token = self.input.matched_string
    let self.token_type = 'BOOL'
  elseif self.input.match('[\]{}:,"'']')
    let self.token = self.input.matched_string
    let self.token_type = self.token
  else
    let self.token = ''
    let self.token_type = 'EOF'
  endif
  return self.token_type
endfunction
