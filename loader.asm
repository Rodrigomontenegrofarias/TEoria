; Loader.asm
bits 32
extern main
global start

start:
  call main  ; Llamamos a main()
  cli        ; Deshabilitamos las interrupciones
  hlt        ; Paramos todo
