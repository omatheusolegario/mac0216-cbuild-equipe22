#include<stdio.h>
#include "soma.h"
#include "subtracao.h"

int main() {
    printf("Digite dois números inteiros: ");
    int a, b;
    scanf("%d %d", &a, &b);
    printf("A soma muito top de %d e %d é: %d\n", a, b, soma(a,b));
    printf("A subtração muito top de %d e %d é: %d\n", a, b, subtracao(a,b));
    return 0;
}