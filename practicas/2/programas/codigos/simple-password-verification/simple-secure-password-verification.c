#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <crypt.h>

#define MAX_PASSWORD_LEN 16
#define SALT "$6$rounds=5000$"  // Salt que se encuentra al inicio del hash

char *stored_hash = "$6$rounds=5000$ZJKabZ3Mlnd3wZy5$yybAnH.3ObM2Anz9h71q2PmtJFE8k1dd6lJmWac1WYmvnObONIMqFTgo2AlMIWyX7nv.f3FdqlJNmDUPpZCGxO.";

int granted()
{
    printf("Lograste llegar hasta aquí. ¡Felicidades!\n");
    printf("Acceso Autorizado...\n");

    // Creamos un arreglo de argumentos
    char *args[] = {"/usr/bin/gnome-terminal", "-x", "sh", "-c", "./simple-password-verification.out", NULL};
    execvp(args[0], args); // Usamos execvp(), que es más seguro que system()
    perror("Error al ejecutar el terminal"); // En caso de que haya un error, redirigimos al usuario.
    return 0;
}

int main()
{
    char password[MAX_PASSWORD_LEN];
    char *entered_hash;

    printf("¡Bienvenido!\n");
    printf("Anota la contraseña por favor: ");

    // Uso de fgets reemplazando a gets
    if (fgets(password, sizeof(password), stdin) != NULL)
    {
        // Evita que fgets deje un salto de línea al final de la cadena
        password[strcspn(password, "\n")] = '\0';

        //Hasheamos la entrada
        entered_hash = crypt(password, SALT);

        // Comprobamos que ambos hashes coincidan
        if (strcmp(entered_hash, stored_hash) != 0)
        {
            printf("Lo siento, la contraseña es incorrecta.\nAcceso Denegado\n");
        }
        else
        {
            granted();
        }
    }
    else
    {
        //En caso de que haya un error con fgets, redireccionamos al usuario
        printf("Error en la entrada de datos.\n");
    }

    return 0;
}
