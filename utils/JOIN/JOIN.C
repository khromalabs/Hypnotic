//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±									     ±
//±   Joiner for morph files...                                              ±
//±									     ±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#define WORD unsigned short
#define BYTE unsigned char
#define BOOL unsigned char

#define TRUE  1
#define FALSE 0

#define SEEK_SET  0
#define SEEK_CUR  1
#define SEEK_END  2

typedef struct {
   WORD ident;
   BYTE atrib;
   BYTE steps;
   WORD numverts;
   WORD numfaces;
} SHPfile;

/* Functions */
long filesize(FILE *);
void getns(char *, char *);
long finddata(char *, char *);
void clnumb(char *, char *);
void extname(char *, char *);
void readmat(FILE *, char *);
long filesize(FILE *stream);
char getarg(char argc, char **argv, char arg);
int  init_seq(BYTE *);
int process(BYTE *);

int steps = 0;
FILE *script, *morph[64], *dout;
BYTE files[64][128], nscript[64], nfileout[64];
SHPfile head;
BYTE *Pvertx, *Pfaces;
BYTE svertx, sface, atribute;
long nvertx, nfaces;

void main(short argc, char *argv[])
{
   SHPfile mainheader;
   BYTE endload;
   short i, j;
   long size;

   cprintf("\n\rJOIN - Join SHPs files in morphs SHPs");
   cprintf("\n\r1995 Copyright (c) Khroma (AKA Rub‚n G¢mez)");
   cprintf("\n\rÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\n");

   if(argc <= 1) {
     cprintf("\n\rUsage:\n\rJOIN filescript");
     cprintf("\n\r filescript: Group of files to join (Without extension!)\n\r");
     return;
   }


   if((script = fopen(argv[1], "rt")) == NULL) {
     cprintf("\n\r Can't open script file '%s'", script);
     return;
   }

   strcpy(nscript, argv[1]);
   strcpy(nfileout, argv[1]);
   strlwr(nscript);

   if((strchr(nscript, '.')) != NULL) {
     for(i = 0; nscript[i] != '.'; i++);
     nfileout[i] = NULL;
   }
   strcat(nfileout, ".shp");


   if((dout = fopen(nfileout, "wb")) == NULL) {
     cprintf("\n\r Can't open out file '%s'", nfileout);
     return;
   }

   size = filesize(script);

   for(i = 0; i != 64; i++) {
     if((fgets(files[i], 64, script)) == NULL) break;
     if(files[i][0] == ';') i--; 
     else {
       for(j=0; j!=63; j++) {
         if(files[i][j] == 10 || files[i][j] == 13) {
	   files[i][j] = NULL;
	   if(j == 0) i--;
	   break;
         }
       }
     }
   }

   steps = i;
   if(steps < 1) {
     cprintf("\n\r Insuficient steps in script.");
     return;
   } else {
     cprintf("\n\r Found %d steps.", steps);
   }

// Process the file list
  if((init_seq(files[0])) == -1) {
   fclose(dout);
   remove(nfileout);
   return;
  }

  for(i = 1; i < steps; i++) {
    if((process(files[i])) == -1) {
     cprintf("\n\r ERROR: Truncated morph secuence!\n");
     fclose(dout);
     remove(nfileout);
     return;
    }
  }

  fwrite((void *)Pfaces, 1, (nfaces * sface), dout);
  cprintf("\n\r Done.\n");

}


int init_seq(BYTE *filein)
{
   FILE *din;
   int i, j;
   char *mmsg = "Insuficient memory!\n";

   if((din = fopen(filein, "rb")) == NULL) {
     cprintf("\n\r Can't open mather mesh file %s\n", filein);
     return -1;
   } else {
     cprintf("\n\r Opened mather mesh file %s...\n\r", filein);
   }

   fread((void *)&head, 1, sizeof(SHPfile), din);
   nfaces = head.numfaces;
   nvertx = head.numverts;

   head.steps = steps;
   svertx = 24;
   if((head.atrib & 1) != 0) {
        svertx += 8;
       cprintf("\n\r Mesh mapped\n\r", filein);
   }


   atribute = head.atrib;
   head.atrib |= 2;
   sface = 4*2;


// Reserva memoria
   if((Pvertx = (BYTE *) malloc(head.numverts * svertx)) == NULL) {
     cprintf(mmsg);
     return -1;
   }
   if((Pfaces = (BYTE *) malloc(head.numfaces * sface)) == NULL) {
     cprintf(mmsg);
     return -1;
   }

// Lee los datos...
   fread((void *)Pvertx, 1, (head.numverts * svertx), din);
   fread((void *)Pfaces, 1, (head.numfaces * sface), din);

// Escribe los datos...
   fwrite((void *)&head, 1, sizeof(SHPfile), dout);
   fwrite((void *)Pvertx, 1, (head.numverts * svertx), dout);

// Exit Guai :)
   return 0;
}

int process(BYTE *filein)
{
   FILE *din;
   int i, j;
   char *mmsg = "Insuficient memory!\n";

   if((din = fopen(filein, "rb")) == NULL) {
     cprintf("\n\r Can't open mesh file %s\n", filein);
     return -1;
   } else {
     cprintf("\n\r Procesing mesh file %s...", filein);
   }

   fread((void *)&head, 1, sizeof(SHPfile), din);
   if(nfaces != head.numfaces || nvertx != head.numverts) {
     cprintf("\n\r Mesh file %s isn't a morph of mather file!\n\r", filein);
     return -1;
   }

   if(head.atrib != atribute) {
     cprintf("\n\r Incorrect attribute in mesh '%s'", filein);
     return -1;
   }

// Lee los datos...
   fread((void *)Pvertx, 1, (head.numverts * svertx), din);

// Escribe los datos...
   fwrite((void *)Pvertx, 1, (head.numverts * svertx), dout);

   fclose(din);

// Exit Guaix :)
   return 0;

}

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//   TEXT FUNCTIONS
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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


