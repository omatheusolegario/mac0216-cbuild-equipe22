#include<stdio.h>
#include "operacoes.h"

int main() {
    printf("Digite dois números inteiros: ");
    int a, b;
    scanf("%d %d", &a, &b);
    int resultado = soma(a, b);
    printf("A soma de %d e %d é: %d\n", a, b, resultado);
    return 0;
}