/**
 * @Author: Dušan Kolář, Adrián Arroyo Calle
 * @Year:   2003-2019
 * Copyright (c) 2019
 * Licence: GLP 3.0
 */

#ifndef ___ASTREE_H___
#define ___ASTREE_H___

typedef struct ast_s {
    unsigned tag;
    unsigned lineno;
    union {
        struct {
            struct ast_s *lft, *rgt;
        } ptr;
        char   *sVal;
        double  dVal;
    } u;
} ast_t;

#define tag(x) (x->tag)
#define lnum(x) (x->lineno)
#define left(x) (x->u.ptr.lft)
#define right(x) (x->u.ptr.rgt)
#define sv(x) (x->u.sVal)
#define dv(x) (x->u.dVal)

ast_t *mkSlf(unsigned tag, char *str);
ast_t *mkDlf(unsigned tag, double dval);
ast_t *mkNd(unsigned tag, ast_t *l, ast_t *r);
ast_t *appR(unsigned tag, ast_t *lst, ast_t *nd);

void evaluate(ast_t *root);

#endif
