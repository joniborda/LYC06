#include "../archivos_punto_H/comparador.h"

/**
 * Recibe el nombre de un archivo (por ejemplo "prueba.txt") y
 * Compara el resultado del arbol sintactico que genera en instrucciones.txt 
 * con el archivo pasado agregnado ".test"
 * ("prueba.txt.test") 
 */
void compararArchivo(char *archivo) {

   FILE *fp1, *fp2;     /* File Pointer's Definitions */
   int   ch1,  ch2;     /* Vars to Read from files    */   

   char *archivo2;
   archivo2 = malloc(sizeof(archivo) + 6);

   strcpy(archivo2, archivo);
   strcat(archivo2, ".test");

   fp1 = fopen(ARCHIVO_INSTRUCCIONES, "r");
   fp2 = fopen(archivo2, "r");
 
   if (fp1 == NULL) {
      printf("\n Cannot open [%s] ", ARCHIVO_INSTRUCCIONES);
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