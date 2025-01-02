augroup('setIndent', { clear = true })
autocmd('Filetype', {
  group = 'setIndent',
  pattern = { 'make', 'dts' }
  },
  command = 'setlocal shiftwidth=4 tabstop=4 smartindent smarttab softtabstop=4'
})
