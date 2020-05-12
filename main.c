void clear()
{
  	char *vidptr = (char*)0xb8000; 	//donde está la memoria de video
	unsigned int i = 0;
	unsigned int j = 0;
	//clear all
	while(j < 80 * 25 * 2) {
		//espacio en blanco
		vidptr[j] = ' ';
		// byte de atributo: gris sobre negro
		vidptr[j+1] = 0x05;
		j = j + 2;
	}
}

void showstring(char* message)
{
  	char *vidptr = (char*)0xb8000	; 	//donde está la memoria de video
	unsigned int x = 22;
	unsigned int y = 9;

	unsigned int i = ((80*y)+x)*2;
	unsigned int j = 0;
	while(message[j] != '\0') {
		if(message[j]=='\n'){
			y=y+1;
			i = ((80*y)+x)*2;
			j++;
		}
		vidptr[i] = message[j];
		if(vidptr[i]=='*'){
			vidptr[i+1] = 0x0B;
		}else{
			vidptr[i+1] = 0x0E;
		}
		++j;
		i = i + 2;
	}
	
}

void main( void )
{
    char *str = "***********************************\n**  Tarea 1 Sistemas Operativos  **\n**  Integrantes:                 **\n**       Rodrigo Montenegro      **\n**       Francisco Moretti       **\n***********************************";
	clear();
	showstring(str);

  for(;;); /* Bucle para mantener el SO corriendo */
}

