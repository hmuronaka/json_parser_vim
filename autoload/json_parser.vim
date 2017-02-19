

let json_parser = {}
function! json_parser#create(file)
  let obj = copy(json_parser)
  obj.file = file
  
  let text_stream = text_stream#create(file)
  obj.tokenizer = json_tokenizer#create(text_stream)
  obj.state = 'INIT'
  obj.value = ''
  return obj
endfunction

function! json_parser.deserialize() dict abort
  if self.tokenizer.next_token() != 'EOF'
    obj.value = json_parser.deserialize_any()
  endif
endfunction

function! s:json_parser.deserialize_any() dict abort
  if self.tokenizer.token_type == '{'
    return json_parser.deserialize_map()
  elseif self.tokenizer.token_type == '['
    return json_parser.deserialize_list()
  else
    json_parser.deserialize_value()
  else
    " parse error
  endif
endfunction

function! s:json_parser.deserialize_map(parent) dict abort
  if empty(a:parent) 
    let a:parent = {}
  endif
  while self.tokenizer.next_token() == ','
    if self.tokenizer.token_type != 'STRING'
      " parse error
    endif

    let key = self.tokenizer.token
    let value = json_parser.deserialize_any()
    let a:parent[key] = value
  endwhile

  if self.tokenizer.token() != '}'
    " parse error
  endif

  return a:parent
endfunction

function! s:json_parser.deserialize_list(parent) dict abort
  if empty(a:parent)
    let a:parent = []
  endif

  while self.tokenizer.next_token() == ','
    let value = json_parser.deserialize_any()
    call add(a:parent, value)
  endwhile

  if self.tokenizer.token() != ']'
    " parser error
  endif

  return a:parent
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
