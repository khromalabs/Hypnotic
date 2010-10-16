/*°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  BIN2INC  - Convierte un fichero cualquiera en un inc para el assembler
  1995- Khroma / Exobit
°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#ifdef __WATCOMC__
 #define getkey  getch
#endif

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
void appendbyte(BYTE data, BYTE *ptr);

long k;

void main(short argc, char *argv[])
{
   FILE *din, *dout;
   char nfilein[225];
   char nfileout[225];
   short i;
   char *abort = "\n\rProcess aborted.\n";


   cprintf("\n\rDAT2INC - Convert data files in include files");
   cprintf("\n\r1995 Copyright (c) Khroma/îXéB1T (AKA Rub‚n G¢mez)");
   cprintf("\n\rÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\n");

   if(argc <= 1) {
      cprintf("\n\rUsage:\n\rdat2inc filein.ext [fileout.inc] [/eXX] [/x]\n");
      cprintf("\n\r/e: Encript data by adding some value");
      cprintf("\n\r/x: Do a XOR with the data\n");
      return;
   }

   strcpy(nfilein, argv[1]);

   if(argc == 3) {
     strcpy(nfileout, argv[2]);
   } else {
     strcpy(nfileout, argv[1]);
     for(i = 0; nfilein[i] != '.'; i++);
     nfileout[i] = NULL;
     strcat(nfileout, ".inc");
   }
     
   strlwr(nfilein);
   strlwr(nfileout);

   if((din = fopen(nfilein, "rb")) == NULL) {
    cprintf("\n\rCan't open input file '%s'!\n", nfilein);
    return;
   }

   if((dout = fopen(nfileout, "rb")) != NULL) {
     do {
       cprintf("\n\rWarning '%s' exists, overwrite?(Y/N)\n", nfileout);
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
    fclose(dout);
    remove(nfileout);
  } else {
    cprintf("\n\rDone.\n");
  }
}

BOOL convert(FILE *D_in, FILE *D_out)
{
/* Buffers utilizados por la rutina */
  BYTE    *incbuf, *filebuf, *dataptr;

/* Datos varios */
  long    i=0, j=0, len;
  char    *errorm = { "\n\r   Insuficient memory!!!\n" };

  len = filesize(D_in);

 /* Alojamos la memoria necesaria para leer el archivo */
  cprintf("\n\rInitializing memory...");
  if((filebuf = (char *) malloc(len)) == NULL) {
    cprintf(errorm);
    return FALSE;
  }
  if((dataptr = incbuf = (char *) malloc(len*6)) == NULL) {
    cprintf(errorm);
    return FALSE;
  }

  cprintf("\n\r  Reading input file...");
  fread(filebuf, 1, (size_t)len, D_in);

  cprintf("\n\r  Procesing...");
  
  for(k = 0, i = 0, j = 0; i < len; i++) {
    if(i % 1024 == 0) cprintf(".");
    if(j == 0) {
     dataptr[k] = 100;
     dataptr[k+1] = 98;
     dataptr[k+2] = 32;
     dataptr[k+3] = 32;
     k += 4;
    }

    appendbyte(filebuf[i], dataptr);
    if(j == 14) {
      j = 0;
      dataptr[k] = 10;
      dataptr[k-1] = 13;
      k++;
    } else j++;
  }
  k--;

/* Una vez concluido el proceso de extracci¢n, guardamos los resultados: */
  cprintf("\n\r  Written to disk...");
  fwrite(incbuf, 1, k, D_out);
  return TRUE;
}

void appendbyte(BYTE data, BYTE *ptr)
{
  char *tableh = "0123456789ABCDEF";
  
  ptr[k] = '0';
  ptr[k+1] = tableh[data >> 4];
  ptr[k+2] = tableh[data & 15];
  ptr[k+3] = 'h';
  ptr[k+4] = ',';
  k += 5;
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
