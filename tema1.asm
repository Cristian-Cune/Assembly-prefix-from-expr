%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .bss
	expr: resb MAX_INPUT_SIZE
section .data
        negative_number db 0
section .text
global CMAIN

CMAIN:
    mov ebp, esp; for correct debugging
	push ebp
	mov ebp, esp

	GET_STRING expr, MAX_INPUT_SIZE
        xor eax,eax
        xor ecx,ecx
        xor edx,edx
go_through_expr:
skip:
        ;in negative_number vom avea o variabila booleana astfel incat daca intalnim un numar negativ
        ;nehative_number va avea valoarea 1 si daca intalnim unul pozitiv va avea valoarea 0
        mov byte[negative_number],0; presupunem la inceput ca este un numar pozitiv
        xor edx,edx
        mov dl,byte[ expr + ecx ];mutam caracter cu caracter in dl
        inc ecx

        cmp edx,0;verificam daca am ajuns la capatul sirului
        je finish
        
        cmp edx,'+'
        je operation
        
        cmp edx,'*'
        je operation
        
        cmp edx,'/'
        je operation
        
        ;verificam daca e numar negativ adica daca intalnim '-'
        cmp edx,'-'
        jne not_negative
        
        cmp byte[expr + ecx ],' ';verificam daca avem spatiu dupa '-'
        je operation
        cmp byte[expr + ecx ],0;verificam daca suntem la sfarsitul sirului
        je operation
        
        mov byte[negative_number],1;daca e negativ numarul trecem la urmatorul caracter
        xor edx,edx
        mov dl,byte[expr + ecx ]
        

not_negative:
        ;verificam daca e numar pozitiv
        cmp edx,'0'
        jl skip
        cmp edx,'9'
        jg skip
        
        
        sub edx,'0'
        xor ebx,ebx;numarul de zecimale pentru numarul gasit
        
        cmp byte[negative_number],0
        je number
        
        inc ebx
number:
        ;formam numarul din toate zecimalele gasite
        cmp byte[expr + ecx + ebx],' '
        je enough_digits
        
        cmp byte[expr + ecx + ebx],0
        je enough_digits
   
        mov eax,10
        mul edx
        mov edx,eax
        
        xor eax,eax
        mov al,byte[expr + ecx + ebx]
        sub eax,'0'
        add edx,eax
        inc ebx
        jmp number
        
        
enough_digits:     
       
        add ecx,ebx
        cmp byte[negative_number],0
        je positive
        
        not edx
        inc edx
positive:
        ;introducem numarul pe stiva si verificam daca am ajuns la final
        push edx
        mov eax,'\0'
        cmp eax,edx
        jne go_through_expr
        
        ;scoatem ultimele 2 elemente si efectuam operatia necesara
operation:
        cmp edx,'+'
        jne not_sum
        pop eax
        pop ebx
        add eax,ebx
        push eax
        jmp go_through_expr
 not_sum:
        cmp edx,'-'
        jne not_dif
        pop eax 
        pop ebx
        sub ebx,eax
        push ebx
        jmp go_through_expr
not_dif:       
        cmp edx,'*'
        jne not_prod
        pop ebx
        pop eax
        imul ebx
        push eax
        jmp go_through_expr
        
not_prod:
        cmp edx, '/'
        jne finish
        pop ebx
        pop eax
        push edx
        mov edx,0
        cdq
        idiv ebx
        pop edx
        push eax
        jmp go_through_expr
	
finish:
        ;scoatem ultimul rezultat de pe stiva si il afisam
        pop eax
        PRINT_DEC 4,eax
	xor eax, eax
        
	pop ebp
	ret
