/*
** Lenguajes de Interfaz
** Nombre:** Pozos Flores Norberto  
** Número de Control:** 22210336  
** Fecha:** 07 de Noviembre del 2024  
*/
// Equivalente en C#:
/*
using System;
using System.Runtime.InteropServices;
using System.Text;

class Program
{
    // Importar la función de verificación de palíndromo desde la biblioteca compartida
    [DllImport("libcalculations.so")]
    public static extern int es_palindromo(StringBuilder str);

    static void Main()
    {
        // Pedir al usuario que ingrese una cadena
        Console.Write("Ingresa una cadena para verificar si es palíndromo: ");
        string input = Console.ReadLine();

        // Convertir la cadena a StringBuilder (mutable)
        StringBuilder cadena = new StringBuilder(input);

        // Llamar a la función para verificar si es palíndromo
        int resultado = es_palindromo(cadena);

        // Mostrar el resultado
        if (resultado == 1)
        {
            Console.WriteLine($"\"{input}\" es un palíndromo.");
        }
        else
        {
            Console.WriteLine($"\"{input}\" no es un palíndromo.");
        }
    }
}
*/


.section .data
    prompt:     .asciz "Ingresa para verificar si es palindromo:"
    is_pal:     .asciz "\"\n es palindromo.\n"
    not_pal:    .asciz "\" \n no es palindromo.\n"
    quote:      .asciz "\""
    buffer:     .skip 100
    len:        .quad 0

.section .text
.global _start

es_palindromo:
    // Guardar registros
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Encuentra la longitud de la cadena
    mov x1, x0             // x1 apunta al inicio de la cadena
find_end:
    ldrb w2, [x1], #1      // Leer el siguiente byte (carácter) y avanzar
    cbz w2, check_palindrome // Si llegamos al final ('\0'), comenzar verificación
    b find_end             // Continuar hasta encontrar el final

check_palindrome:
    sub x1, x1, #2         // Retroceder una posición (x1 apunta al último carácter)
    mov x2, x1             // x2 apunta al final de la cadena
    mov x3, x0             // x3 apunta al inicio de la cadena

compare_loop:
    cmp x3, x2             // Comparar el inicio con el final
    bge is_palindrome      // Si se cruzan, es un palíndromo
    ldrb w4, [x3]          // Leer carácter desde el inicio
    ldrb w5, [x2]          // Leer carácter desde el final
    cmp w4, w5             // Comparar caracteres
    bne not_palindrome     // Si no son iguales, no es palíndromo
    add x3, x3, #1         // Avanzar el inicio
    sub x2, x2, #1         // Retroceder el final
    b compare_loop         // Repetir la comparación

is_palindrome:
    mov w0, #1              // Retornar 1 si es palíndromo
    b end_palindrome

not_palindrome:
    mov w0, #0              // Retornar 0 si no es palíndromo

end_palindrome:
    // Restaurar registros
    ldp x29, x30, [sp], #16
    ret

_start:
    // Imprimir prompt
    mov x0, #1              // stdout
    adr x1, prompt         // mensaje
    mov x2, #44            // longitud
    mov x8, #64            // write syscall
    svc #0

    // Leer entrada
    mov x0, #0              // stdin
    adr x1, buffer         // buffer
    mov x2, #100           // tamaño máximo
    mov x8, #63            // read syscall
    svc #0

    // Guardar longitud
    sub x0, x0, #1         // restar 1 para quitar el newline
    adr x1, len
    str x0, [x1]           // guardar longitud

    // Poner null terminator
    adr x1, buffer
    strb wzr, [x1, x0]     // reemplazar newline con null

    // Imprimir comilla inicial
    mov x0, #1
    adr x1, quote
    mov x2, #1
    mov x8, #64
    svc #0

    // Imprimir cadena original
    mov x0, #1
    adr x1, buffer
    adr x2, len
    ldr x2, [x2]
    mov x8, #64
    svc #0

    // Llamar a es_palindromo
    adr x0, buffer
    bl es_palindromo
    mov x19, x0            // guardar resultado

    // Imprimir mensaje según resultado
    mov x0, #1
    cmp x19, #1
    beq .Lprint_is
    
    // No es palíndromo
    adr x1, not_pal
    mov x2, #20
    b .Lprint_result

.Lprint_is:
    // Es palíndromo
    adr x1, is_pal
    mov x2, #17

.Lprint_result:
    mov x8, #64
    svc #0

    // Salir
    mov x0, #0
    mov x8, #93
    svc #0