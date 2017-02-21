
function! json_parser#test()
  let parser = json_parser#create('test.json')
  let json = parser.deserialize()
  echom 'json: ' . json['TEST']
endfunction

let s:json_parser = {}
function! json_parser#create(file)
  let obj = copy(s:json_parser)
  let obj.file = a:file
  
  let text_stream = json_text_stream#create(a:file)
  let obj.tokenizer = json_tokenizer#create(text_stream)
  let obj.state = 'INIT'
  let obj.value = ''
  return obj
endfunction

function! s:json_parser.deserialize() dict abort
  if self.tokenizer.next_token() != 'EOF'
    let self.value = self.deserialize_any()
  endif
  return self.value
endfunction

function! s:json_parser.deserialize_any() dict abort
  if self.tokenizer.token_type == '{'
    return self.deserialize_map()
  elseif self.tokenizer.token_type == '['
    return self.deserialize_list()
  else
    self.deserialize_value()
  else
    " parse error
  endif
endfunction

function! s:json_parser.deserialize_map() dict abort
  let result = {}
  while self.tokenizer.next_token() == ','
    if self.tokenizer.token_type != 'STRING'
      " parse error
    endif

    let key = self.tokenizer.token
    let value = json_parser.deserialize_any()
    let result[key] = value
  endwhile

  if self.tokenizer.token != '}'
    " parse error
  endif

  return result
endfunction

function! s:json_parser.deserialize_list() dict abort
  let result = []

  while self.tokenizer.next_token() == ','
    let value = self.deserialize_any()
    call add(result, value)
  endwhile

  if self.tokenizer.token != ']'
    " parser error
  endif

  return result
endfunction

function! s:json_parser.deserialize_value()
  if self.tokenizer.token_type == 'STRING'
    return self.tokenizer.token
  elseif self.tokenizer.token_type == 'NUMBER'
    return str2nr(self.tokenizer.token)
  elseif self.tokenizer.token_type == 'BOOL'
    return self.tokenizer.token =~ 'true\c' ? 1 : 0
  else
    " parser error
  endif 
endfunction
