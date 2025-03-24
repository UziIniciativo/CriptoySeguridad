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
	gets(pass);
	if(pass[0]=='\0')
	{
		printf("No lo lograste. Intenta de nuevo");
		return 0;
	}else if(strlen(pass) < 11)
	{
		secretMsg();
	}else
	{
		printf("No lo lograste. Intenta de nuevo");
		return 0;
	}
}
