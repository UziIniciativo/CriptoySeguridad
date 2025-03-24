#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

char * login= "root";

int granted ()
{
	printf("Lograste llegar hasta aquí . ¡Felicidades!\n");
	printf("Acceso Autorizado...");
	// Esta linea  de código puede no funcionar en algunos SO
	// Realiza la practica en Kali Linux
	system("/usr/bin/gnome-terminal -x sh -c \"./simple-password-verification.out \"");
	return 0 ;
}
int main ()
{
	char password[16];
	printf("¡Bienvenido!\n");
	printf("Anota la contraseña por favor:");
	gets(password);
	if(strcmp(password,login))
	{
		printf("Lo siento la contraseña es incorrecta. \n Acceso Denegado");
	}
	else
	{
		granted();
	}
}
