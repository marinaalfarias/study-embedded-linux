#include <stdio.h>
#include <unistd.h>

int contador = 0;

int main(void) {
    while (1) {
        contador++;
        printf("Contador: %d\n", contador);
        sleep(2);
    }
    return 0;
}