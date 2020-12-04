include WINDOWS.inc

include user32.inc
include kernel32.inc
include comdlg32.inc

includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib

.data
	pmem dd 0
	readed dd 0
	hFile dd 0

	filename db 260 dup(0)
	initdir db 260 dup(0)