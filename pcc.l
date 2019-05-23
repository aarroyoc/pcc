/**
 * @Author: Dušan Kolář, Adrián Arroyo Calle
 * @Year:   2003-2019
 * Copyright (c) 2019
 * Licence: GLP 3.0
 */

%{
#include "error.h"
#include "pcc.h"
#include "keywords.h"


int yywrap(void) { return 1; }
void lower(char *s);
static char *readStr(void);
%}

IDENT ([A-Za-z_][A-Za-z0-9_]*)

DIGIT ([0-9])
DIGITS ({DIGIT}*)
EXP ([eE][-+]?{DIGITS})
FLOAT1 ({DIGITS}"."{DIGITS})
FLOAT2 ({DIGITS}{EXP})
FLOAT3 ({DIGITS}"."{DIGITS}{EXP})
FLOAT ({FLOAT1}|{FLOAT2}|{FLOAT3}|{DIGITS})

STRSTART  (["])
CHAR (['].['])
SPECIAL_CHAR (['][\\].['])


OP1 ([-+*/=<>()}{,%^])
OP2 ("=="|"!="|"<="|">="|"&&"|"||")

COMSEP    ([\n])

INLINE_COMMENT ([/][/])

WSPC      ([ \t\f\r])
WSPCS     ({WSPC}+)

%x COMMENT

%%

{WSPC} ;

{INLINE_COMMENT}.* ;

"/*"          { BEGIN(COMMENT); }
<COMMENT>"*/" { BEGIN(INITIAL); }
<COMMENT>\n   { }
<COMMENT>.    { }


{IDENT}     {
                unsigned short i = 0;
                while(i<KWLEN){
                    if(strcmp(keywords[i],yytext) == 0) return keycodes[i];
                    i++;
                }
                yylval.s.u.text = strdup(yytext);
                yylval.s.type = IDENT;

                return IDENT;
            }

                    
{FLOAT}     {
                sscanf(yytext,"%lf",&( yylval.s.u.num ));
                yylval.s.type = FLOAT;
                        
                return FLOAT;
            }
{STRSTART}  {
                yylval.s.u.text = readStr();
                yylval.s.type = STR;

                return STR;
            }

{CHAR}      {
                yylval.s.u.text = (char*)malloc(sizeof(char));
                yylval.s.u.text[0] = yytext[1];
                yylval.s.type = STR;

                return STR;
            }

{SPECIAL_CHAR} {
                yylval.s.u.text = (char*)malloc(sizeof(char));
                if(yytext[2] == 'n'){
                    yylval.s.u.text[0] = '\n';
                }
                yylval.s.type = STR;

                return STR;

            }

{OP1}           return yytext[0];

{OP2}       {
                switch (yytext[0]) {
                    case '=':
                        return EQ;
                    case '!':
                        return NE;
                    case '<':
                        return LE;
                    case '>':
                        return GE;
                    case '&':
                        return AND;
                    case '|':
                        return OR;
                }
            }    

{COMSEP}    {
                ++yylineno;
                return yytext[0];
            }
;           {
                return END_SENTENCE;
            }

.           {
                pccError(yylineno,"Unexpected character in input: %c [%d]\n",yytext[0],yytext[0],NULL);
            }
%%

void lower(char *s) {
    unsigned l = strlen(s);
    while (l>0) {
        --l;
        if (s[l]>='A' && s[l]<='Z') s[l] = s[l]+'a'-'A';
    }
}

static void addStr(char **s, unsigned long *len, char c) {
  char buf[2];
  buf[0] = c;
  buf[1] = '\0';

  if (strlen(*s) >= *len) {
    char *ss;
    ss=malloc(*len+1025);
    strcpy(ss,*s);
    free(*s);
    *s=ss;
    *len = *len+1024;
  }
  
  strcat(*s,buf);
}


static char *readStr(void) {
  int c;
  char *buff;
  unsigned long len = 256;

  buff=malloc(257);
  buff[0]='\0';

  do {
    c = input();

    if (c < ' ') pccError(yylineno,"Unexpected symbol in string literal [%d]\n",c,NULL);
    if (c == '"') break;

    if (c=='\\') {
      c = input();
      if(c == 'n'){
          c = '\n';
      }else if(c!='\\' && c !='"') {
        unput(c);
        c = '\\';
      }
    }

    addStr(&buff,&len,c);
    
  } while (1);

  return buff;
}