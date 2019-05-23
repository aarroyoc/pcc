/**
 * @Author: Dušan Kolář, Adrián Arroyo Calle
 * @Year:   2003-2019
 * Copyright (c) 2019
 * Licence: GLP 3.0
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "error.h"
#include "astree.h"

FILE *fIn;

int yylex(void);
extern int yylineno;

int yyerror(char *str);

static ast_t *astRoot = NULL;

%}

%union {
    struct sStackType {
        int type;
        union {
            double         num;
            char          *text;
            struct ast_s  *ast;
            }   u;
    }   s;
}

%left OR
%left AND

%nonassoc EQ NE
%nonassoc LE GE '<' '>'

%left '+' '-'
%left '*' '/' '%'

%right '^'

%right '!'

%token END_SENTENCE
%token <s> IDENT
%term WRITE READ SIN COS TAN ASIN ACOS ATAN LOG LOG10 EXP CEIL FLOOR WHILE IF ELSE FOR FOR1 FOR2
%token <s> FLOAT STR
%token AST

%type <s> sentence expr prog line body

%%

prog 
  : line 
  {
    astRoot = appR(';', astRoot, $1.u.ast);
  }
  | prog line
  {
    astRoot = appR(';', astRoot, $2.u.ast);
  };

line 
  : sentence 
  {
    $$ = $1;
  } 
  | sentence '\n'
  {
    $$ = $1;
  } 
  | '\n'
  {
    $$.type = AST;
    $$.u.ast = NULL;
  };

sentence
  : IDENT '=' expr END_SENTENCE
  {
    $$.type = AST;
    $$.u.ast = mkNd('=', mkSlf(IDENT,$1.u.text), $3.u.ast);
  }
  | WRITE '(' expr ')' END_SENTENCE
  {
    $$.type = AST;
    $$.u.ast = mkNd(WRITE,NULL,$3.u.ast);
  }
  | WRITE '(' STR ')' END_SENTENCE
  {
    $$.type = AST;
    $$.u.ast = mkNd(WRITE,mkSlf(IDENT,$3.u.text),NULL);
  }
  | WRITE '(' STR ',' expr ')' END_SENTENCE
  {
    $$.type = AST;
    $$.u.ast = mkNd(WRITE,mkSlf(IDENT,$3.u.text),$5.u.ast);
  }
  | READ '(' IDENT ')' END_SENTENCE
  {
    $$.type = AST;
    $$.u.ast = mkNd(READ,NULL,mkSlf(IDENT,$3.u.text));
  }
  | READ '(' STR ',' IDENT ')' END_SENTENCE
  {
    $$.type = AST;
    $$.u.ast = mkNd(READ,mkSlf(IDENT,$3.u.text),mkSlf(IDENT,$5.u.text));
  }
  | IF '(' expr ')' '{' body '}'
  {
    $$.type = AST;
    $$.u.ast = mkNd(IF,$3.u.ast,mkNd(ELSE,$6.u.ast,NULL));
  }
  | IF '(' expr ')' '{' body '}' ELSE '{' body '}'
  {
    $$.type = AST;
    $$.u.ast = mkNd(IF,$3.u.ast,mkNd(ELSE,$6.u.ast,$10.u.ast));
  }
  | FOR '(' IDENT '=' expr END_SENTENCE expr END_SENTENCE IDENT '=' expr ')' '{' body '}'
  {
    $$.type = AST;
    $$.u.ast = mkNd(FOR,mkNd(FOR1,$7.u.ast,mkNd('=',mkSlf(IDENT,$9.u.text),$11.u.ast)),mkNd(FOR2,mkNd('=',mkSlf(IDENT,$3.u.text),$5.u.ast),$14.u.ast));
  }
  | WHILE '(' expr ')' '{' body '}'
  {
    $$.type = AST;
    $$.u.ast = mkNd(WHILE,$3.u.ast,$6.u.ast);
  }
  | END_SENTENCE
  {

  };

body
  : line 
  {
    $$.type = AST;
    $$.u.ast = appR(';',NULL,$1.u.ast);
  }
  | body line
  {
    $$.type = AST;
    $$.u.ast = appR(';',$1.u.ast,$2.u.ast);
  };

expr 
  : IDENT
  {
    $$.type = AST;
    $$.u.ast = mkSlf(IDENT,$1.u.text);
  }
  | FLOAT
  {
    $$.type = AST;
    $$.u.ast = mkDlf(FLOAT,$1.u.num);
  }
  | expr '+' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('+',$1.u.ast,$3.u.ast);
  }
  | expr '-' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('-',$1.u.ast,$3.u.ast);
  }
  | expr '*' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('*',$1.u.ast,$3.u.ast);
  }
  | expr '/' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('/',$1.u.ast,$3.u.ast);
  }
  | expr '%' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('%',$1.u.ast,$3.u.ast);
  }
  | expr '^' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('^',$1.u.ast,$3.u.ast);
  }
  | '-' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('-',NULL,$2.u.ast);
  }
  | expr OR expr
  {
    $$.type = AST;
    $$.u.ast = mkNd(OR,$1.u.ast,$3.u.ast);
  }
  | expr AND expr
  {
    $$.type = AST;
    $$.u.ast = mkNd(AND,$1.u.ast,$3.u.ast);
  }
  | expr EQ expr
  {
    $$.type = AST;
    $$.u.ast = mkNd(EQ,$1.u.ast,$3.u.ast);
  }
  | expr NE expr
  {
    $$.type = AST;
    $$.u.ast = mkNd(NE,$1.u.ast,$3.u.ast);
  }
  | expr LE expr
  {
    $$.type = AST;
    $$.u.ast = mkNd(LE,$1.u.ast,$3.u.ast);
  }
  | expr GE expr
  {
    $$.type = AST;
    $$.u.ast = mkNd(GE,$1.u.ast,$3.u.ast);
  }
  | expr '<' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('<',$1.u.ast,$3.u.ast);
  }
  | expr '>' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('>',$1.u.ast,$3.u.ast);
  }
  | '!' expr
  {
    $$.type = AST;
    $$.u.ast = mkNd('!',NULL,$2.u.ast);
  }
  | '(' expr ')'
  {
    $$ = $2;
  }
  | SIN '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(SIN,$3.u.ast,NULL);
  }
  | COS '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(COS,$3.u.ast,NULL);
  }
  | TAN '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(TAN,$3.u.ast,NULL);
  }
  | ASIN '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(ASIN,$3.u.ast,NULL);
  }
  | ACOS '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(ACOS,$3.u.ast,NULL);
  }
  | ATAN '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(ATAN,$3.u.ast,NULL);
  }
  | LOG '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(LOG,$3.u.ast,NULL);
  }
  | LOG10 '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(LOG10,$3.u.ast,NULL);
  }
  | EXP '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(EXP,$3.u.ast,NULL);
  }
  | CEIL '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(CEIL,$3.u.ast,NULL);
  }
  | FLOOR '(' expr ')'
  {
    $$.type = AST;
    $$.u.ast = mkNd(FLOOR,$3.u.ast,NULL);
  };

%%

int yyerror(char *str) {
  pccError(yylineno,"%s\n",str,NULL);
  return 1;
}

extern FILE *yyin;

int main(int argc, char *argv[]) {
  //exitOnError();

  if (argc!=2) {
    puts("\nUsage: demo <filename>\n");
    fflush(stdout);
    return 1;
  }

  if ((fIn=fopen(argv[1],"rb"))==NULL) {
    fprintf(stderr,"\nCannot open file: %s\n\n",argv[1]);
    fflush(stderr);
    return 1;
  }

  yyin = fIn;

  setFilename( argv[1] );

  if (yyparse() != 0) {
    fclose(fIn);
    pccError(yylineno,"Parsing aborted due to errors in input\n",NULL);
  }

  fclose(fIn);

  if (astRoot != NULL) {
    evaluate(astRoot);
  } else {
    pccError(yylineno,"No parse output provided, aborting evaluation\n",NULL);
  }

  return 0;
}