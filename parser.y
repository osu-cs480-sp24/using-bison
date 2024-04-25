%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hash.h"

struct hash* symbols = hash_create();

void yyerror(const char* err);

extern int yylex();
%}

/* %define api.value.type { char* } */
%union {
  char* str;
  float num;
}

%token <str> IDENTIFIER
%token <num> NUMBER
%token <str> EQUALS PLUS MINUS TIMES DIVIDEDBY
%token <str> SEMICOLON LPAREN RPAREN

%type <num> expression

%start program

%%



%%
