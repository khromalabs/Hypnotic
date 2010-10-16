/*°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  PCX2DAT  - Convierte un fichero PCX en uno RAW (dat)
  1995- Khroma / Exobit
°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#define DIBU_X 320
#define DIBU_Y 200

#define TRUE  1
#define FALSE 0

#define WORD unsigned short
#define BYTE unsigned char
#define BOOL unsigned char

#define SEEK_SET    0
#define SEEK_CUR    1
#define SEEK_END    2

long filesize(FILE *stream);
BOOL convert(FILE *D_in, FILE *D_out);
void unpack(BYTE *data, BYTE *buffer);
char getarg(char, char **, char);
BOOL check_file(char *filebuf);

int weight = DIBU_X;
int height = DIBU_Y;
int res_x = DIBU_X;
int res_y = DIBU_Y;

BOOL h_init = FALSE;
BOOL w_init = FALSE;


#ifdef __WATCOMC__
 #define getkey  getch
#endif

void main(short argc, char *argv[])
{
   FILE *din, *dout;

   char i, *ptr;
   char nfilein[225];
   char nfileout[225];
   char *abort = "\nProcess aborted.\n";


   cprintf("\n\rPCX2DAT - Convert pcx files in raw data files");
   cprintf("\n\r1995 Copyright (c) Khroma/îXéB1â (AKA Rub‚n G¢mez)");
   cprintf("\n\rÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\n");

   if(argc <= 1) {
      cprintf("\n\rUsage:\n\rpcx2dat filein.ext [fileout.dat] [-HXXX] [-WXXX]\n");
      cprintf("\n\r/H: Out file Height");
      cprintf("\n\r/W: Out file Weight\n");
      return;
   }

   strcpy(nfilein, argv[1]);

/* Check arguments */
   if(argc > 2 && (argv[2][0] != '-' && argv[2][0] != '/')) {
     strcpy(nfileout, argv[2]);
   } else {
     strcpy(nfileout, argv[1]);
     for(i = 0; nfilein[i] != '.'; i++);
     nfileout[i] = 0;
     strcat(nfileout, ".dat");
   }

   i = getarg(argc, argv, 'H');
   ptr = (char *) &argv[i][2];
   if(i != FALSE) {
     height = atoi(ptr);
     h_init = TRUE;
   }
   
   i = getarg(argc, argv, 'W');
   ptr = (char *) &argv[i][2];
   if(i != FALSE) {
     weight = atoi(ptr);
     w_init = TRUE;
   }
     
   strlwr(nfilein);
   strlwr(nfileout);

   if((din = fopen(nfilein, "rb")) == NULL) {
    cprintf("\n\rCan't open input file '%s'!\n", nfilein);
    return;
   }

   if((dout = fopen(nfileout, "rb")) != NULL) {
     do {
       cprintf("\n\rWarning '%s' exists, overwrite?(Y/N)\n\r", nfileout);
       i = getkey();
     } while(i != 'y' && i != 'Y' && i != 'n' && i != 'N');
     
     if(i != 'y' && i != 'Y') {
       fclose(din);
       fclose(dout);
       cprintf(abort);
       return;
     }
   fclose(dout);
   }

   if((dout = fopen(nfileout, "wb")) == NULL) {
     cprintf("\n\rCan't open output file '%s'!\n", nfileout);
     return;
   }

  if((convert(din, dout)) == FALSE) {
    cprintf("\n\rFile was NOT converted.\n");
    fclose(dout);
    remove(nfileout);
  } else {
    cprintf("\n\rDone.\n");
  }
}

BOOL convert(FILE *D_in, FILE *D_out)
{
/* Buffers utilizados por la rutina */
  BYTE    *filebuf, *dataptr;

/* Datos varios */
  long    i, j, k, len;
  char    *errorm = { "\n\r   Insuficient memory!!!\n" };

  len = filesize(D_in);

 /* Alojamos la memoria necesaria para leer el archivo */
  cprintf("\n\rInitializing memory...");
  if((filebuf = (char *) malloc(len)) == NULL) {
    cprintf(errorm);
    return FALSE;
  }

  cprintf("\n\r  Reading input file...");
  fread(filebuf, 1, (size_t)len, D_in);

  cprintf("\n\r  Verifing File...");
  if((check_file(filebuf)) == FALSE) {
    cprintf("\n\n    Hey dude, this file isn't a PCX!...\n");
    return FALSE;
  }

  if(w_init == FALSE) weight = res_x;
  if(h_init == FALSE) height = res_y;

  if((dataptr = (char *) malloc(height * weight)) == NULL) {
    cprintf(errorm);
    return FALSE;
  }

  /* Test coordinates */
  cprintf("\n\r  Input file values: X:%d Y:%d", res_x, res_y);
  cprintf("\n\r  Output file values: W:%d H:%d", weight, height);

  if(res_x < weight || res_y < height || weight <= 0 || height <= 0) {
    cprintf("\n\r    Error in output file coordinates!\n");
    return FALSE;
  }

  cprintf("\n\r  Unpacking...");
  unpack(filebuf, dataptr);
  
/* Una vez concluido el proceso de extracci¢n, guardamos los resultados: */
  cprintf("\n\r  Written to disk...");
  fwrite(dataptr, 1, height*weight, D_out);
  return TRUE;
}

void unpack(BYTE *data, BYTE *buffer)
{
  BYTE byte;
  WORD tcol, col, lines;
  long contador;

  data += 128;
  
  for(lines = height; lines != 0; --lines) {
    tcol = res_x;
    col = weight;
    while(tcol != 0) {
      byte = *data; ++data;
      if(byte <= 192) {
	--tcol;
        if(col != 0) {
          *buffer=byte; buffer++; --col; 
        }
      } else {
	contador = byte&63; byte = *data; ++data;
	for(; contador != 0; --contador, --tcol) {
          if(col != 0) {
 	    *buffer=byte; buffer++; --col;
          }
	}
      }
    }
  }

}


long filesize(FILE *stream)
{
   long curpos, length;

   curpos = ftell(stream);
   fseek(stream, 0L, SEEK_END);
   length = ftell(stream);
   fseek(stream, curpos, SEEK_SET);
   return length;
}


char getarg(char argc, char **argv, char arg)
{
   char othercase;
   char i;
   
   /* If the arg passed is lower case, we make it upper */
   if(arg > 90) arg -= 32;
 
   /* Search the switch */
   for(i = 1; i < argc; i++) {
     if(argv[i][0] == '/' || argv[i][0] == '-')
       if(argv[i][1] == arg || argv[i][1] == arg+32)
       	 return i;
   }
     
   return FALSE;
}

BOOL check_file(char *filebuf)
{
   if(((*filebuf)==10)&&(*(filebuf+1)==5)&&(*(filebuf+2)==1)) {
     res_x = filebuf[9]*256 + filebuf[8] + 1;
     res_y = filebuf[11]*256 + filebuf[10] + 1;
     if(res_x > 1024 || res_y > 728) return FALSE;
   } else {
     return FALSE;
   }
   return TRUE;
}
