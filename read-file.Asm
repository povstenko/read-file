.386
.model flat,STDCALL
option casemap :none  ;case sensitive

include read-file.inc

.code
Begin:
	call main
	
invoke ExitProcess,NULL

; ������ ��������� �������� ���'��
Mem_Alloc PROC Buf_Size:DWORD
	add Buf_Size,4	; �������� ����� �� 4 ����� ������
	invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT, Buf_Size   ; �������� ������� � ��������� ���'��
	push eax 	; �������� ����� ������ ��������� ������ � ����
	invoke GlobalLock,eax ;������� � ��������
	pop [eax]	;��������� � ����� ��������  � �������� � ����� 4 ����� ��������� ������, 
				;�� �������� � ���� ������ ������� ������
				;�������� Buf_Size ���� ������������� �� �����
	add eax,4	;������� �������� ������� ������ �� 4 �����, ������� ����� 4 ����� 
			;����� ��������� ������ ������
	ret	; �������� � ���������
Mem_Alloc endp

; ������ ��������� �������� ���'��.
Mem_Free PROC DATA:DWORD
	mov eax,DATA	;������� �������� ��������� ��������� � ������ eax, ���������� � 
					;��������� (������) ������ ������ ( ������� + 4 �����)
	sub eax,4	;���'�����, �� ������ 4 ����� ������  - �� ����� ������
	push [eax]	;������ �������� ������ �������� �� �����, �� ������ � ������ eax, �������� ���� � ����
	invoke GlobalUnlock,eax	;������������ ���'��� (��� ������� Buf_Size+4)
	call GlobalFree	;������� �������� ��� � �����, ��������� ��������� ��� ���������, �� ��������� ���������� 
					;call (������� ������ ������)
	ret	;����� � ���������
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
