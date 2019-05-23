/**
 * @Author: Dušan Kolář, Adrián Arroyo Calle
 * @Year:   2003-2019
 * Copyright (c) 2019
 * Licence: GLP 3.0
 */

#include "astree.h"
#include "pcc.h"
#include "error.h"
#include "keywords.h"

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern int yylineno;

int reserved_keyword(char* str);

typedef struct symtab {
    char   *name;
    double  value;
    struct symtab *left, *right;
} symtab_t;

static symtab_t *root = NULL;

static char *wName;
static double wValue;

// ----------------------------------------------------------------------------

static void inmod(symtab_t *nd) {
    int res = strcmp(wName,nd->name);
    if (res == 0) { // the same string
        nd->value = wValue;
        return;
    }
    if (res < 0) {
        if (nd->left != NULL) {
            inmod(nd->left);
        } else {
            symtab_t *newr = malloc(sizeof(symtab_t));
            newr->value = wValue;
            newr->name  = strdup(wName);
            newr->left  = NULL;
            newr->right = NULL;
            nd->left    = newr;
        }
    } else {
        if (nd->right != NULL) {
            inmod(nd->right);
        } else {
            symtab_t *newr = malloc(sizeof(symtab_t));
            newr->value = wValue;
            newr->name  = strdup(wName);
            newr->left  = NULL;
            newr->right = NULL;
            nd->right   = newr;
        }
    }
}

// ----------------------------------------------------------------------------

void insertModify(char *s, double val) {
    if (root == NULL) {
        root = malloc(sizeof(symtab_t));
        root->value = val;
        root->name  = strdup(s);
        root->left = NULL;
        root->right = NULL;
        return;
    }
    wName = s;
    wValue = val;
    inmod(root);
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

static double get(symtab_t *nd) {
    if (nd == NULL) {
        pccError(yylineno,"Undefined variable %s!\n",wName);
    }
    
    int res = strcmp(wName,nd->name);
    if (res == 0) { // the same string
        return nd->value;
    }
    
    if (res < 0) {
        return get(nd->left);
    } else {
        return get(nd->right);
    }
}

// ----------------------------------------------------------------------------

double read(char *s) {
    wName = s;
    return get(root);
}


ast_t *mkSlf(unsigned tag, char *str) {
    ast_t *res = malloc(sizeof(ast_t));
    lnum(res) = (unsigned)yylineno;
    tag(res) = tag;
    sv(res) = str;
    return res;
}

ast_t *mkDlf(unsigned tag, double dval) {
    ast_t *res = malloc(sizeof(ast_t));
    lnum(res) = (unsigned)yylineno;
    tag(res) = tag;
    dv(res) = dval;
    return res;
}

ast_t *mkNd(unsigned tag, ast_t *l, ast_t *r) {
    ast_t *res = malloc(sizeof(ast_t));
    lnum(res) = (unsigned)yylineno;
    tag(res) = tag;
    left(res) = l;
    right(res) = r;
    return res;
}


ast_t *appR(unsigned tag, ast_t *lst, ast_t *nd) {
    if (lst == NULL) {
        if (nd == NULL) {
            return NULL;
        }
        return mkNd(tag,nd,NULL);
    }
    if (nd == NULL) {
        return lst;
    }

    ast_t *tmp = lst;
    while (right(tmp) != NULL) {
        tmp = right(tmp);
    }
    right(tmp) = mkNd(tag,nd,NULL);

    return lst;
}

// ----------------------------------------------------------------------------

static double expr(ast_t *root) {
    switch (tag(root)) {
        case OR:
            if (expr(left(root)) != 0.0 || expr(right(root)) != 0.0) {
                return 1.0;
            } else {
                return 0.0;
            }
        case AND:
            if (expr(left(root)) != 0.0 && expr(right(root)) != 0.0) {
                return 1.0;
            } else {
                return 0.0;
            }
        case EQ:
            if (expr(left(root)) == expr(right(root))) {
                return 1.0;
            } else {
                return 0.0;
            }
        case NE:
            if (expr(left(root)) != expr(right(root))) {
                return 1.0;
            } else {
                return 0.0;
            }
        case LE:
            if (expr(left(root)) <= expr(right(root))) {
                return 1.0;
            } else {
                return 0.0;
            }
        case GE:
            if (expr(left(root)) >= expr(right(root))) {
                return 1.0;
            } else {
                return 0.0;
            }
        case '<':
            if (expr(left(root)) < expr(right(root))) {
                return 1.0;
            } else {
                return 0.0;
            }
        case '>':
            if (expr(left(root)) > expr(right(root))) {
                return 1.0;
            } else {
                return 0.0;
            }
        case '+':
            return expr(left(root)) + expr(right(root));
        case '-':
            if (left(root) == NULL) {
                return - expr(right(root));
            } else {
                return expr(left(root)) - expr(right(root));
            }
        case '*':
            return expr(left(root)) * expr(right(root));
        case '/':
            return expr(left(root)) / expr(right(root));
        case '%':
            return (long)expr(left(root)) % (long)expr(right(root));
        case '^':
            return pow( expr(left(root)), expr(right(root)) );
        case '!':
            if (expr( right(root) ) == 0.0) {
                return 1.0;
            } else {
                return 0.0;
            }
        case FLOAT:
            return dv(root);
        case IDENT:
            return read( sv(root) );
        case SIN:
            return sin( expr(left(root)) );
        case COS:
            return cos( expr(left(root)) );
        case TAN:
            return tan( expr(left(root)) );
        case ASIN:
            return asin( expr(left(root)));
        case ACOS:
            return acos( expr(left(root)));
        case ATAN:
            return atan( expr(left(root)));
        case LOG:
            return log( expr(left(root)));
        case LOG10:
            return log10( expr(left(root)));
        case EXP:
            return exp( expr(left(root)));
        case CEIL:
            return ceil( expr(left(root)));
        case FLOOR:
            return floor( expr(left(root)));
        default:
            pccError((unsigned short)lnum(root),"Unknown tag in expr AST %u\n",tag(root),NULL);
            break;
    }
}


static void proc(ast_t *root) {
    switch (tag(root)) {
        case '=':
            if(reserved_keyword(sv(left(root))) != 0){
                insertModify( sv(left(root)), expr(right(root)) );
            }else{
                pccError((unsigned short)lnum(root),"Cannot use reserved keyword as identifier",NULL);
            }
            
            break;
        case WRITE:
            if (left(root) == NULL) {
                printf("%g", expr(right(root)) );
            } else if (right(root) == NULL) {
                printf("%s",sv(left(root)) );
            } else {
                printf("%s%g", sv(left(root)), expr(right(root)) );
            }
            break;
        case READ:
            if (left(root) == NULL) {
                double rval;
                scanf("%lf",&rval);
                insertModify(sv(right(root)), rval);
            } else {
                double rval;
                printf("%s", sv(left(root)));
                scanf("%lf", &rval);
                insertModify( sv(right(root)), rval);
            }
            break;
        case WHILE:
            {
                double ctrl = expr(left(root));
                while(ctrl){
                    if(right(root) != NULL){
                        evaluate(right(root));
                    }
                    ctrl = expr(left(root));
                }
                
            }
            break;
        case IF:{
            double ctrl = expr(left(root));
            if(ctrl){
                evaluate(left(right(root)));
            }else{
                if(right(right(root)) != NULL){
                    evaluate(right(right(root)));
                }
            }
        }break;
        case FOR:{
            insertModify( sv(left(left(right(root)))), expr(right(left(right(root)))) );
            double ctrl = expr(left(left(root)));
            while(ctrl){
                evaluate(right(right(root)));
                insertModify( sv(left(right(left(root)))), expr(right(right(left(root)))) );
                ctrl = expr(left(left(root)));
            }
        }break;
        default:
            pccError((unsigned short)lnum(root),"Unknown tag in statement AST %u\n",tag(root),NULL);
            break;
    }
}

void evaluate(ast_t *root) {
    while (root != NULL) {
        proc(left(root));
        root = right(root);
    }
}

int reserved_keyword(char* str){
    unsigned short i = 0;
    while(i<KWLEN){
        if(strcmp(keywords[i],str) == 0) return 0;
        i++;
    }
    return -1;
}


// ----- EOF ------
