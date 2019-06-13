TITLE ENCRYPTION USING ROTATE
; Uses a key to encrypt / decrypt
; a plaintext message

INCLUDE Irvine32.inc
.data
key			SBYTE	-4,1,7,-4,7,-7,4,5,3,-2
messege		BYTE	"I can't seem to find my decoder ring!"
messege2	BYTE	"Words are very unnecessary"
encrypted	BYTE	255 DUP(?)
encrypted2	BYTE	255 DUP(?)

EncryptMessege PROTO keyLoc			:PTR SBYTE,
					messegeLoc		:PTR BYTE,
					encryptedLoc	:PTR BYTE,
					keyLength		:BYTE,
					messegeLength	:BYTE

ReadEncryption	PROTO	keyLoc			:PTR SBYTE,
						encryptedLoc	:PTR BYTE,
						keyLength		:BYTE,
						encryptedLength	:BYTE



.code
main PROC
	
	mov		dl,LENGTHOF key		; 255 characters max
	mov		dh,LENGTHOF messege	; Use as counter
	invoke	EncryptMessege, OFFSET key,
							OFFSET messege,
							OFFSET encrypted,
							LENGTHOF key,
							LENGTHOF messege	; Create the encryption using predetermined key

	invoke	EncryptMessege, OFFSET key,
							OFFSET messege2,
							OFFSET encrypted2,
							LENGTHOF key,
							LENGTHOF messege2	; Create the encryption using predetermined key

	invoke	ReadEncryption,	OFFSET key,
							OFFSET encrypted,
							LENGTHOF key,
							LENGTHOF messege	; Reads encryption using same key

	invoke	ReadEncryption,	OFFSET key,
							OFFSET encrypted2,
							LENGTHOF key,
							LENGTHOF messege2	; Reads encryption using same key



exit
main ENDP

;---------------------------------------------------------------;
EncryptMessege PROC keyLoc			:PTR SBYTE,
					messegeLoc		:PTR BYTE,
					encryptedLoc	:PTR BYTE,
					keyLength		:BYTE,
					messegeLength	:BYTE;
																
;					Description: Creates an encrypted messege	;
;								using rotates based on a key	;
;---------------------------------------------------------------;
	pushad;

	mov		esi,keyLoc			;
	movzx	ecx,messegeLength	; Length of messege
	mov		bl,keyLength		; mod by this number (length of key)
	mov		edi,0				; Clear counter		
	L1:
		mov		eax,edi				; current location number to al
		div		bl					; Return al % bl to ah
		movzx	edx,ah				; move remainder to bh
		push	ecx					; Using cl for rotation
		mov		esi,keyLoc			; Move key ptr to esi
		mov		cl,[esi+edx]		; Move current key value to cl
		mov		esi,messegeLoc		; Move messege ptr to esi
		mov		al,[esi+edi]		; move messege[current] to al
		ror		al,cl				; rotate by key[al % bl]
		pop		ecx					; Restore ecx
		mov		esi,encryptedLoc	;
		mov		[esi+edi],al		; Encrypted messege being stored
		inc		edi					; move to next location
		Loop	L1					;

	popad;
	ret
EncryptMessege	ENDP

;---------------------------------------------------------------;
ReadEncryption	PROC	keyLoc			:PTR SBYTE,
						encryptedLoc	:PTR BYTE,
						keyLength		:BYTE,
						messegeLength	:BYTE	
						
;					Description: Unencrypts a messege using		;
;								rotate commands based on a key	;
;---------------------------------------------------------------;
	pushad;

	movzx	esi,messegeLength	;
	mov		ecx,esi				; Length of (encrypted) messege
	mov		bl,keyLength		; mod by this number (length of key)
	mov		edi,0				; Clear counter
	L1:
		mov		eax,edi				; current location number to al
		div		bl					; Return al % bl to ah
		movzx	edx,ah				; move remainder to bh
		push	ecx					; Using cl for rotation
		mov		esi,keyLoc			; Move key ptr to esi
		mov		cl,[esi+edx]		; Move current key value to cl
		mov		esi,encryptedLoc	; move encrypted ptr to esi
		mov		al,[esi+edi]		; move encrypted[current] to al
		rol		al,cl				; (un)rotate by key[al % bl]
		pop		ecx					; Restore ecx
		call	WriteChar			; Display current character
		inc		edi					; move to next location
		Loop	L1					;
	
	call	Crlf;
	call	Crlf;

	popad;
	ret
ReadEncryption	ENDP
END main