
function! json_parser#test()
  let parser = json_parser#create('test.json')
  let json = parser.deserialize()
"  echom 'json: ' . json.TEST
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
  if self.tokenizer.token_type != 'EOF'
    let self.value = self.deserialize_any()
  endif
  return self.value
endfunction

function! s:json_parser.deserialize_any() dict abort
  echom 'json_parser.deserialize_any: ' . self.tokenizer.token_type
  call self.tokenizer.next_token()

  if self.tokenizer.token_type == '{'
    return self.deserialize_map()
  elseif self.tokenizer.token_type == '['
    return self.deserialize_list()
  else
    return self.deserialize_value()
  endif
endfunction

function! s:json_parser.deserialize_map() dict abort
  let result = {}
  while 1
    if self.tokenizer.next_token() != 'STRING'
      " parse error
    endif
    let key = self.tokenizer.token

    if self.tokenizer.next_token() != ':'
      "parse error
    endif

    let value = self.deserialize_any()
    echom 'json_parser.deserialize_map: key:' . key . ', value:' . value
    let result[key] = value

    if self.tokenizer.next_token() == '}'
      break
    elseif self.tokenizer.token_type != ','
      "parse error
    endif
  endwhile
  return result
endfunction

function! s:json_parser.deserialize_list() dict abort
  let result = []

  while self.tokenizer.next_token() != ']'
    let value = self.deserialize_any()
    echom 'json_parser.deserialize_list: value:' . value
    call add(result, value)
  endwhile
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
