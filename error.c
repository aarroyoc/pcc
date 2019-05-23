/**
 * @Author: Dušan Kolář, Adrián Arroyo Calle
 * @Year:   2003-2019
 * Copyright (c) 2019
 * Licence: GLP 3.0
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "error.h"

static unsigned char wasE = 0;
static unsigned char exitOnE = 0;
static char fName[10240] = "";

void pccError(unsigned short lineno, char* format,...){
    va_list ap;
    char *arg;

    wasE = 1;

    va_start(ap,format);
    fprintf(stderr,"%s (%u): ",fName,lineno);
    vfprintf(stderr,format,ap);
    fflush(stderr);
    va_end(ap);

    if (exitOnE) exit(1);
}

void setFilename(const char *str) {
  strcpy(fName,str);
}