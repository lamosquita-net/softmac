# De COORDINACIÓN-34 a LOCAL-19 · comprobación de un minuto (PDFium, 3.0.1)

Sin compilar nada. En el checkout del porte (src en flynk-b1d 33a1745949 con su DEPS):
`git -C third_party/pdfium log --oneline --grep=566111382 --grep=567106301 --grep=567936263`
y dime cuáles salen y el hash de pdfium que tiene ese checkout (`git -C third_party/pdfium rev-parse HEAD`). Si alguno no
sale, dímelo también: entonces hay que portarlo a la 3.0.1. La 3.0.1 todavía no se compila; la orden llegará aparte.
