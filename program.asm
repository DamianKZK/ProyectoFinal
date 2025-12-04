#    Entrada:
#       12 = puntero al arreglo
#       13 = tamaño
#       16 = valor buscado
#    Salida:
#       v0 = índice si se encontró
#       v0 = -1 si no se encontró

    array: 
        .word 3, 8, 15, 20, 42, 7
#
# Memoria precargada
# $0: 0
# $2: 3
# $3: 8
# $4: 15
# $5: 15
# $6: 20
# $7: 42
# $8: 7
#

linear_search:
    addi $9, $0, -1          # retorno por defecto
    addi $10, $0, 0           # 10 = índice i

loop:
    beq  $10, $13, end    # si i == n -> fin

    add  $11, $12, $14    # dirección del elemento
    lw   $15, $11, #0      # cargar elemento

    beq  $15, $16, found  # si array[i] == target → encontrado

    addi $10, $10, 1      # i++
    addi $14, $14, 4      # 14 += 4
    j loop

found:
    add $9, $0, $10         # v0 = índice

end:
    j final              # regresar a quien llamó


main:
    add $12, $0, $2    # dirección del arreglo
    addi $13, $0,  6   # tamaño
    addi $16, $0, 20   # número a buscar

    j  linear_search
final:
    # Al regresar:
    #   v0 contiene el índice o -1
