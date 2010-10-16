//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±                                                                         ±
//±     Converter ASCII files 3DS4 to SHP (Exomotion)                       ±
//±	1995 Copyright (c) Khroma (AKA Rub‚n G¢mez)                         ±
//±                                                                         ±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#ifdef __WATCOMC__
 #define getkey  getch
#endif

#define U_TEXT 128
#define V_TEXT 128
#define MAX_ERRORS 16
#define MAX_MAT    32

#define WORD unsigned short
#define BYTE unsigned char
#define BOOL unsigned char

#define SCALE 2.3

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

typedef struct {
   float x;
   float y;
   float z;
} dot3d;

typedef struct {
  char equi;
  char name[32];
} Material;

typedef struct {
  long Number;
  Material Mlist[MAX_MAT];
} Mlist;


/* Functions */
void convert(FILE *, FILE *);
long filesize(FILE *);
void getns(char *, char *);
long finddata(char *, char *);
void clnumb(char *, char *);
void extname(char *, char *);
void readmat(FILE *, char *);
void GetNormal(WORD, WORD, WORD, float *, float *);
void Average_Dot(WORD *, long, long *, float *, WORD *);
dot3d CrossProd(dot3d *, dot3d *);
long filesize(FILE *stream);
char getarg(char argc, char **argv, char arg);


/* Static data */
char strtemp[255];   /* Temporal string */
SHPfile shape;
Mlist Mat;

char *mat_table[]    = { "CHROME BLUE SKY","MADERA","TOPTEXT","TOPTEXTB","PANTEXT","PANTEXTB",
                         "PIEL","ZAPATO" };


char *data_table[]   = { "Vertices:", "Faces:", "X:", "Y:", "Z:",
			 "Vertex list:", "Face list:", "A:", "B:", "C:",
			 "Page", "Face", "Named object:", "Vertex",
			 "U:", "V:", "Mapped", "Material" };

long pos = 0, colorbc = -1;
int  SizeVertex;

void main(short argc, char *argv[])
{
   FILE *din, *dout, *mat;
   char nfilein[225], *ptr;
   char nfileout[225];
   char *nfilemat = "material.def";
   short i;
/*   char buff[16384]; */

   cprintf("\n\rEXOMOTION - ASC2SHP Object Compiler");
   cprintf("\n\r1995 Copyright (c) Khroma (AKA Rub‚n G¢mez)");
   cprintf("\n\rÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\n");

   if(argc <= 1) {
      cprintf("\n\rUsage:\n\r3DOC filein[.asc] /c:[Color]");
      cprintf("\n\r /C: Color value\n\r ");
      exit(0);
   }


   i = getarg(argc, argv, 'C');
   ptr = (char *) &argv[i][2];
   if(i != FALSE) {
     colorbc = atoi(ptr);
     if(colorbc < 0 || colorbc > 255) {
       cprintf("\n\r\n\r Bad color value.\n\r ");
       return;
     }

   }
   
   strcpy(nfilein, argv[1]);
   strcpy(nfileout, argv[1]);
   strlwr(nfilein);

   if((strchr(nfilein, '.')) == NULL) {
     strcat(nfilein, ".asc");
   } else {
     for(i = 0; nfilein[i] != '.'; i++);
     nfileout[i] = NULL;
   }
   strcat(nfileout, ".shp");

/* Test if both names are the same */
   if( (strcmp(nfilein, nfileout)) == NULL) {
    cprintf("\r\nERROR: File Out & File In can't be the same\n");
    exit(0);
   }

/* Open input file */
   if((din = fopen(nfilein, "rb")) == NULL) {
    cprintf("\n\rERROR: Can't open input file '%s'\n", nfilein);
    exit(0);
   }

/* Test if this file previusly exists */
   if((dout = fopen(nfileout, "rb")) != NULL) {
     do {
       cprintf("\n\rWARNING: '%s' exists, overwrite?(Y/N)", nfileout);
       i = getkey();
       cprintf("%c", i);
     } while(i != 'y' && i != 'Y' && i != 'n' && i != 'N');
     
     if(i != 'y' && i != 'Y') {
       fclose(din);
       cprintf("\n\r Process aborted.\n");
       exit(0);
     }
   fclose(dout);
   }

/* Can open the output file? */
   if((dout = fopen(nfileout, "wb")) == NULL) {
     cprintf("\n\rERROR: Can't open output file '%s'\n", nfileout);
     exit(0);
   }

/* Try to open material file */
   if((mat = fopen(nfilemat, "rb")) == NULL) {
    cprintf("\n\rWARNING: Can't open material definitions file\n");
   } else {
    cprintf("\n\rReading materials definitions.\n");
/*    readmat(mat, buff); */
   }

 
   cprintf("\n\rProcesing mesh '%s':", nfilein);
   convert(din, dout);

   fclose(din);
   fclose(dout);
}


void readmat(FILE *mats, char *buffer)
{
  char *filebuf;
  long len;

  len = filesize(mats);

 /* Read the file into memory */
  if((filebuf = (char *) malloc(len)) == NULL) {
    cprintf("\n\rERROR: Insuficient memory for file buffer (ehhh¨?¨?)\n");
    exit(-1);
  }
  fread(filebuf, 1, (size_t)len, mats);

      
  free(filebuf);
}


void convert(FILE *D_in, FILE *D_out)
{
/* Buffers utilizados por la rutina */
  float   *fvertbuf;		 // Valores en coma flotante de los v‚rtices
  float   *nbuf;		 // Buffer de normales (averaged)
  long    *vertbuf;		 // Vertices en modo fixed
  WORD    *facebuf, *list;	 // Lista de caras... ; Lista de normales que converge...
  char    *filebuf;		 // Buffer del fichero cargado en memoria...

/* Datos varios */
  float   ftemp;
  long    ltemp;
  short   itemp;
  long    len;
  char    number[255];
  long    i=0, j=0, k=0, np=0, p=0;
  BYTE    col=0;
  float   scalar;
  char    *inmem = { "\n\rInsuficient memory!!!\n" };
  char    *errorv = { "\n\rError in Vertex %d:%c" };
  char    *errorf = { "\n\rError in Face %d:%c ; Value: %s" };
  char    *errord = { "\n\n\r Hey men, where are the %ss definitions?" };
  char    *abort = { "\n\n\r Too many errors!\n\r Aborted.\n" };
  long    error = 0;
  dot3d   normal;
  float   max, opt;


  len = filesize(D_in);

// Read the file into memory
  if((filebuf = (char *) malloc(len)) == NULL) {
    cprintf("\r\nERROR: Insuficient memory for file buffer (¨¨Comorllll??)\n");
    exit(0);
  }

  fread(filebuf, 1, (size_t)len, D_in);


// Initalize the struct
  shape.ident = 0x3DEF;
  shape.atrib = 0;

// Extract the number of vertx
  if((pos = finddata(filebuf, data_table[0])) == NULL) {
    cprintf("\n\r ERROR: Vertices not defined!");
    exit(0);
  }

  getns(filebuf, strtemp);
  shape.numverts = atoi(strtemp);
  cprintf("\n\r  Number of vertices: %d", shape.numverts);

// Now with the faces...
  if((pos = finddata(filebuf, data_table[1])) == NULL) {
    cprintf("\n\rERROR: Faces not defined!\n");
    exit(0);
  }

  getns(filebuf, strtemp);
  shape.numfaces = atoi(strtemp);
  cprintf("\n\r  Number of faces: %d", shape.numfaces);


// ¨Maped?
  getns(filebuf, strtemp);
  if((strcmp(strtemp, data_table[16])) == NULL) {
    cprintf("\n\r  Mesh Mapped.");
    shape.atrib |= 1;
    SizeVertex = 32 / 4;
  } else {
    SizeVertex = (32-8) / 4;
  }

// Here is the memory allocation
  if((vertbuf = (long *) malloc(shape.numverts * (SizeVertex*4))) == NULL) {
    cprintf(inmem);
    exit(0);
  }

  if((fvertbuf = (float *) malloc(shape.numverts * sizeof(dot3d))) == NULL) {
    cprintf(inmem);
    exit(0);
  }

  if((facebuf = (WORD *) malloc(shape.numfaces * 14)) == NULL) {
    cprintf(inmem);
    exit(0);
  }

  if((nbuf = (float *) malloc(shape.numfaces * sizeof(dot3d))) == NULL) {
    cprintf(inmem);
    exit(0);
  }

  if((list = (WORD *) malloc(shape.numfaces * 2)) == NULL) {
    cprintf(inmem);
    exit(0);
  }

/* Proceso de extracci¢n de v‚rtices */
  cprintf("\n\r  Converting Vertices.");
  pos = finddata(filebuf, data_table[5]);

  if(pos == -1) {
    cprintf(errord, data_table[5]);
    exit(-1);
  }

  for(i = 0; i < shape.numverts; i++) {
    if(error > MAX_ERRORS) {
      cprintf(abort);
      exit(-1);
    }

    if((i % 32) == 0) cprintf(".");
    do {
      getns(filebuf, strtemp);
    } while((strcmp(strtemp, data_table[13])) != NULL);


    getns(filebuf, strtemp);

    getns(filebuf, strtemp);
    if((strtemp[0] == 'X')) { 
      getns(filebuf, strtemp);
      scalar = atof(strtemp);
      fvertbuf[k++] = scalar * SCALE;
      vertbuf[j++] = (long)(scalar * 65536 * SCALE);
    } else {
      error++;
      cprintf(errorv, i, 'X');
    }

    getns(filebuf, strtemp);
    if((strtemp[0] == 'Y')) { 
      getns(filebuf, strtemp);
      scalar = atof(strtemp);
      fvertbuf[k++] = scalar * SCALE;
      vertbuf[j++] = (long)(scalar * 65536 * SCALE);
    } else {
      error++;
      cprintf(errorv, i, 'Y');
    }

    getns(filebuf, strtemp);
    if((strtemp[0] == 'Z')) { 
      getns(filebuf, strtemp);
      scalar = atof(strtemp);
      fvertbuf[k++] = scalar * SCALE;
      vertbuf[j++] = (long)(scalar * 65536 * SCALE);
    } else {
      error++;
      cprintf(errorv, i, 'Z');
    }


/* Xchg order of coordinates */
    ltemp        = -vertbuf[j-2];
    vertbuf[j-2] = -vertbuf[j-1];
    vertbuf[j-1] = ltemp;

    ftemp         = -fvertbuf[k-2];
    fvertbuf[k-2] = -fvertbuf[k-1];
    fvertbuf[k-1] = ftemp;

/* Take space for the normal's calculation */
    j += 3;

/* Read texture-map coordinates, if exists... */
    if((shape.atrib & 1) != 0) {
      getns(filebuf, strtemp);
      if((strtemp[0] == 'U')) { 
        getns(filebuf, strtemp);
        scalar = atof(strtemp);
        vertbuf[j++] = (long)(scalar * 65536 * U_TEXT);
      } else {
        error++;
        cprintf(errorv, i, 'U');
      }
    
      getns(filebuf, strtemp);
      if((strtemp[0] == 'V')) { 
        getns(filebuf, strtemp);
        scalar = atof(strtemp);
        vertbuf[j++] = (long)(scalar * 65536 * V_TEXT);
      } else {
        error++;
        cprintf(errorv, i, 'V');
      }

    ltemp = -vertbuf[j-1];
    vertbuf[j-1] = -vertbuf[j-2];
    vertbuf[j-2] = ltemp;

    }


/*
  In total, every [mapped] vertex is :

  3 ³ Dwords for the point
  3 ³ Dwords for the VERTEX normal
 [2 ³ Dwords for the mapping coordinates]
 ÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
  8 ³ DWORDS (32 bytes) [No map = 24]
*/

  }

// Here we start with the polys...
  cprintf("\n\r  Extracting Faces.");
  pos = finddata(filebuf, data_table[6]);

  if(pos == -1) {
    cprintf(errord, data_table[6]);
    exit(-1);
  }


  for(i = 0, np=0; i < shape.numfaces; i++) {

    if(error > MAX_ERRORS) {
      cprintf(abort);
      exit(-1);
    }

    j = i * 4;
    if((i % 32) == 0) cprintf(".");
    do {
      getns(filebuf, strtemp);
    } while((strcmp(strtemp, data_table[11])) != NULL);

    getns(filebuf, strtemp);

    getns(filebuf, strtemp);
    if(strtemp[0] == 'A') {
      getns(filebuf, strtemp);
      facebuf[j++] = atoi(strtemp);
    } else {
      error++;
      cprintf(errorf, i, 'A', strtemp);
    }

    getns(filebuf, strtemp);
    if(strtemp[0] == 'B') {
      getns(filebuf, strtemp);
      facebuf[j++] = atoi(strtemp);
    } else {
      error++;
      cprintf(errorf, i, 'B', strtemp);
    }

    getns(filebuf, strtemp);
    if(strtemp[0] == 'C') {
      getns(filebuf, strtemp);
      facebuf[j++] = atoi(strtemp);
    } else {
      error++;
      cprintf(errorf, i, 'C', strtemp);
    }

    itemp = facebuf[j-1];
    facebuf[j-1] = facebuf[j-3];
    facebuf[j-3] = itemp;


    GetNormal(facebuf[j-3], facebuf[j-2], facebuf[j-1], fvertbuf, &nbuf[np]);
    np += 3;

 /*
    do {
     getns(filebuf, strtemp);
    } while((strcmp(strtemp, data_table[17])) != NULL);

    getns(filebuf, strtemp);
    for(col=0;strtemp[col]!= NULL;col++);
    strtemp[col-1] = NULL;


    for(col=0;col<=10;col++) {
       if((strcmp(&strtemp[1], mat_table[col])) == NULL) break;
    }

    facebuf[j++] = col;
    cprintf("\n\r Material: %d:: %s ; %d", i, mat_table[col], col);
    if(col > 7) { 
       printf("MIERDAAAAAAA!!!"); 
       exit(0);
    }
*/

  facebuf[j++] = 1;

  }	    

// Average the normal dots that converge
  cprintf("\n\r  Averaging Normals.");
  for(i = 0; i < shape.numverts; i++) {
    if((i % 32) == 0) cprintf(".");
    Average_Dot(facebuf, i, vertbuf, nbuf, list);
  }


// Save the results:
  cprintf("\n\r  Written to disk...");
  fwrite((void *)&shape, 1, sizeof(SHPfile), D_out);

  fwrite(vertbuf, 1, shape.numverts*(SizeVertex*4), D_out);
  fwrite(facebuf, 1, shape.numfaces*4*2, D_out);
  cprintf("\n\rConversion finished.\n");
}

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//             ÄÄÄÄÄ>> Normal Calculating Funtions  <<ÄÄÄÄÄÄ
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
void GetNormal(WORD v0, WORD v1, WORD v2, float *fvertbuf, float *nbuf)
{
  dot3d w, n, normal;

/* Get the Normal factors in order  0-1 2-1 */
  w.x = fvertbuf[v0*3] - fvertbuf[v1*3];
  w.y = fvertbuf[(v0*3)+1] - fvertbuf[(v1*3)+1];
  w.z = fvertbuf[(v0*3)+2] - fvertbuf[(v1*3)+2]; 

  n.x = fvertbuf[v2*3] - fvertbuf[v1*3];
  n.y = fvertbuf[(v2*3)+1] - fvertbuf[(v1*3)+1];
  n.z = fvertbuf[(v2*3)+2] - fvertbuf[(v1*3)+2]; 

/* Extract normal */
  normal = CrossProd(&w, &n);

  nbuf[0] = normal.x;
  nbuf[1] = normal.y;
  nbuf[2] = normal.z;

}


void Average_Dot(WORD *facebuf, long index, long *vertbuf, float *nbuf, WORD *list)
{
  WORD i, j;
  dot3d media;

  for(i = 0, j = 0; i < shape.numfaces; i++) {
    if(index == facebuf[i*4] ||	index == facebuf[(i*4)+1] || index == facebuf[(i*4)+2])
      list[j++] = i;
  }

  media.x = media.y = media.z = 0;

  for(i = 0; i < j; i++) {
    media.x += nbuf[list[i]*3];
    media.y += nbuf[(list[i]*3)+1];
    media.z += nbuf[(list[i]*3)+2];
  }

  media.x /= j;
  media.y /= j;
  media.z /= j;
  
  vertbuf[(index*SizeVertex)+3] = (long)(media.x*65536*SCALE);
  vertbuf[(index*SizeVertex)+3+1] = (long)(media.y*65536*SCALE);
  vertbuf[(index*SizeVertex)+3+2] = (long)(media.z*65536*SCALE);

}


//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//   TEXT FUNCTIONS
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
void clnumb(char *strtemp, char *strnumb)
{
  long i, j;

  for(i = 0, j = 0; strtemp[i] != NULL; i++) {
   if((strtemp[i] < 58 && strtemp[i] > 47) || strtemp[i] == '.')
     strnumb[j++] = strtemp[i];
  }
  strnumb[j] = NULL;
}

void getns(char *filebuf, char *strtemp)
{
  long i;

/* Encontramos el offset donde empieza la siguiente cadena (saltando espacios) */
  for(i = 0; filebuf[pos+i] == ' ' || filebuf[pos+i] == 13 || filebuf[pos+i] == 10 || filebuf[pos+i] == 9 || filebuf[pos+i] == ':'; i++);
  pos += i;

/* Ahora extraemos la cadena */
  for(i = 0; filebuf[pos+i] != ' ' && filebuf[pos+i] != 13 && filebuf[pos+i] != 10 && filebuf[pos+i] != 9 && filebuf[pos+i] != ':'; i++)
    strtemp[i] = filebuf[pos+i];
  strtemp[i] = NULL;
  pos += i+1;
}

long finddata(char *buffer, char *data)
{
  long i, len, offset, lenbuf;

  lenbuf = strlen(buffer);
  len = strlen(data);
  for(offset = 0; offset != (lenbuf-len); offset++) {
    for(i = 0; i < len; i++)
      strtemp[i] = buffer[offset+i];
    strtemp[i] = NULL;
    if((strcmp(strtemp, data)) == NULL)
      return offset+i+1;
  }
  return -1;
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



//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//             SOME OLD FUNCTIONS DEVELOPED HUNDRED YEARS AGO... :-)
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
float Magnitude(dot3d *v)
{
    return sqrt(v->x*v->x + v->y*v->y + v->z*v->z);
}

dot3d Normalize(dot3d *A)
{
    float temp = Magnitude(A);
    dot3d vtemp;

    vtemp.x = A->x / temp;
    vtemp.y = A->y / temp;
    vtemp.z = A->z / temp;
    return(vtemp);
}

dot3d CrossProd(dot3d *A, dot3d *B)
{
    dot3d temp;

    temp.x = (A->y * B->z) - (A->z * B->y);
    temp.y = (A->z * B->x) - (A->x * B->z);
    temp.z = (A->x * B->y) - (A->y * B->x);
    return(temp);
}
