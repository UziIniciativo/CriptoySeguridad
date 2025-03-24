#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int secretMsg()
{
    printf("Lo lograste, el secreto es tomar mucha awuita\n");
    printf("Lograste llegar hasta aquí. Felicidades");
    return 0; 
}

int main ()
{
    char pass[16];
    printf("Anota una palabra e intenta descubrir el secreto: \n");

    // Uso de fgets reemplazando a gets
    if (fgets(pass, sizeof(pass), stdin) != NULL)
    {
        // Evita que fgets deje un salto de línea al final de la cadena
        pass[strcspn(pass, "\n")] = '\0';

        if (pass[0] == '\0')
        {
            printf("No lo lograste. Intenta de nuevo\n");
            return 0;
        }
        else if (strlen(pass) < 11)
        {
            secretMsg();
        }
        else
        {
            printf("No lo lograste. Intenta de nuevo\n");
            return 0;
        }
    }
    else
    {
        //En caso de que haya un error con fgets, redireccionamos al usuario
        printf("Error leyendo la entrada\n");
        return 0;
    }
}
