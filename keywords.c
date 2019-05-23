/**
 * @Author: Dušan Kolář, Adrián Arroyo Calle
 * @Year:   2003-2019
 * Copyright (c) 2019
 * Licence: GLP 3.0
 */

#include "pcc.h"

#define KWLEN 17

char* keywords[KWLEN] = {
    "write",
    "read",
    "sin",
    "cos",
    "tan",
    "asin",
    "acos",
    "atan",
    "log",
    "log10",
    "exp",
    "ceil",
    "floor",
    "while",
    "if",
    "else",
    "for"
};

unsigned keycodes[KWLEN] = {
    WRITE,
    READ,
    SIN,
    COS,
    TAN,
    ASIN,
    ACOS,
    ATAN,
    LOG,
    LOG10,
    EXP,
    CEIL,
    FLOOR,
    WHILE,
    IF,
    ELSE,
    FOR
};