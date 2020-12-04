.386
.model flat,STDCALL
option casemap :none  ;case sensitive

include read-file.inc

.code
Begin:
	call main
	
invoke ExitProcess,NULL

; власна процедура виділення пам'яті
Mem_Alloc PROC Buf_Size:DWORD
	add Buf_Size,4	; виділяємо буфер на 4 байти більший
	invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT, Buf_Size   ; виділяємо область у динамічній пам'яті
	push eax 	; зберігаємо хендл області виділеного буфера у стек
	invoke GlobalLock,eax ;фіксуємо у реальній
	pop [eax]	;Витягнемо зі стеку значення  і запишемо у перші 4 байта виділеного масиву, 
				;це значення є хенд області виділеної області
				;наступні Buf_Size байт використовуємо як масив
	add eax,4	;зсуваємо вказівних початку масиву на 4 байти, оскільки перші 4 байти 
			;заняті значенням хендлу буфера
	ret	; виходимо з процедури
Mem_Alloc endp

; власна процедура знищення пам'яті.
Mem_Free PROC DATA:DWORD
	mov eax,DATA	;копіюємо значення параметра процедури у регістр eax, параметром є 
					;початкова (робоча) адреса буфера ( початок + 4 байти)
	sub eax,4	;пам'ятаємо, що перших 4 байти масиву  - це хендл буфера
	push [eax]	;беремо чотирьох байтне значення по адресі, що лежить у регістрі eax, заносимо його у стек
	invoke GlobalUnlock,eax	;розблоковуємо пам'ять (всю розміром Buf_Size+4)
	call GlobalFree	;оскільки параметр вже у стеці, викликаємо процедуру без параметрів, за дапомогою інструкції 
					;call (знищуємо хендел буфера)
	ret	;вихід з процедури
Mem_Free endp


main proc
	
	invoke Mem_Alloc, sizeof OPENFILENAME
	mov edi, eax
	assume edi: ptr OPENFILENAME
	
	invoke GetCurrentDirectory, 260, addr initdir
	mov [edi].lStructSize, sizeof OPENFILENAME
	mov [edi].lpstrFile, offset filename
	mov [edi].nMaxFile, 260
	mov [edi].lpstrInitialDir, offset initdir
	
	invoke GetOpenFileName, edi
	cmp eax, 0
	je exit
	
	invoke Mem_Alloc, 4000h 
	mov pmem, eax
	
	invoke CreateFile, addr filename, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp eax, -1
	je exit
	mov hFile, eax
	
	invoke ReadFile, hFile, pmem, 4000h, readed, 0
	
	invoke MessageBox, 0, pmem, 0, MB_OK
	
	invoke GetSaveFileName, edi
	cmp eax, 0
	je exit
	
	invoke CreateFile, addr filename, GENERIC_WRITE, FILE_SHARE_WRITE, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
	cmp eax, -1
    je exit
    mov hFile, eax
    
    invoke lstrlen, pmem
    invoke WriteFile, hFile, pmem, eax, addr readed, 0
    
exit:
	
	invoke CloseHandle, hFile
	invoke Mem_Free, edi
	assume edi:DWORD
	invoke Mem_Free, pmem
	
	ret

main endp

end Begin
