#ifndef YACC_FUNCTIONS_H
#define YACC_FUNCTIONS_H

#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <stdio.h>
#include <stdarg.h> 

typedef struct {
    int numerator;
    int denominator;
} Valuef;

typedef struct id_table {
    Valuef *value;
    char identifier[12];
    struct id_table* next;
} id_table;


typedef struct Param {
    char name[12];
    struct Param* next;
} Param;

typedef struct {
    char name[12];
    Param* params;
    int numParams;
    Valuef* expression;
} Function;


Function* create_function_1(char* name, Valuef* expression);

Function* create_function_2(char* name, char* param1, Valuef* expression);

Function* create_function_3(char* name, char* param1, char* param2, Valuef* expression);

Valuef* create_valuef(int numerator, int denominator);

Valuef* add_valuef(Valuef* f1, Valuef* f2);

Valuef* sub_valuef(Valuef* f1, Valuef* f2);

Valuef* mul_valuef(Valuef* f1, Valuef* f2);

Valuef* div_valuef(Valuef* f1, Valuef* f2);

void print_valuef(Valuef* f1);

void print_table(id_table* temp);

void set_element( char* name, Valuef *value );

Valuef *get_identifier(char* name);

#endif // YACC_FUNCTIONS_H