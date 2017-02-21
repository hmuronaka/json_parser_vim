
function! json_parser#test()
  let parser = json_parser#create('test.json')
  let json = parser.deserialize()
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
      throw 'json_parser.deserialize_map invalid token type: ' . self.tokenizer.token_type
      echom 'parse error'
    endif
    let key = self.tokenizer.token

    if self.tokenizer.next_token() != ':'
      throw 'json_parser.deserialize_map invalid token type: ' . self.tokenizer.token_type
    endif

    let value = self.deserialize_any()
    let result[key] = value

    if self.tokenizer.next_token() == '}'
      break
    elseif self.tokenizer.token_type != ','
      throw 'json_parser.deserialize_map invalid token type: ' . self.tokenizer.token_type
    endif
  endwhile
  return result
endfunction

function! s:json_parser.deserialize_list() dict abort
  let result = []

  while 1
    let value = self.deserialize_any()
    call add(result, value)

    if self.tokenizer.next_token() == ']'
      break
    elseif self.tokenizer.token_type != ','
      throw 'json_parser.deserialize_list invalid token type: ' . self.tokenizer.token_type
    endif 
  endwhile
  return result
endfunction

function! s:json_parser.deserialize_value()
  let result = ''
  if self.tokenizer.token_type == 'STRING'
    let result =  self.tokenizer.token
  elseif self.tokenizer.token_type == 'NUMBER'
    let result = str2nr(self.tokenizer.token)
  elseif self.tokenizer.token_type == 'BOOL'
    let result = (self.tokenizer.token =~ 'true\c' ? 1 : 0)
  else
    throw 'json_parser.deserialize_value invalid token type: ' . self.tokenizer.token_type
  endif 
  return result
endfunction
