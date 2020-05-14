#include "../archivos_punto_H/comparador.h"

void compararArchivo(char *argumento) {

   FILE *fp1, *fp2;     /* File Pointer's Definitions */
   int   ch1,  ch2;     /* Vars to Read from files    */   

   char *archivo1 = "instruccion.txt";
   char *archivo2;
   archivo2 = malloc(sizeof(argumento) + 7);
   strcpy(archivo2, argumento);
   strcat(archivo2, ".test");

   fp1 = fopen(archivo1, "r");
   fp2 = fopen(archivo2, "r");
 
   if (fp1 == NULL) {
      printf("\n Cannot open [%s] ", archivo1);
      exit(1);
   } else if (fp2 == NULL) {
      printf("\n Cannot open [%s] ", archivo2);
      exit(1);
   } else {
      ch1 = getc(fp1); /* Get the first charter from First  file */
      ch2 = getc(fp2); /* Get the first charter from Second file */
 
      while ((ch1 != EOF) && (ch2 != EOF) && (ch1 == ch2)) {
         ch1 = getc(fp1);
         ch2 = getc(fp2);
      }
 
      fclose(fp1); /* Close File Pointer */
      fclose(fp2); /* Close File Pointer */

      if (ch1 != ch2 || ch1 != EOF || ch2 != EOF) {
         printf("\n Has some different \n");
         exit(1);
      }
    }
}