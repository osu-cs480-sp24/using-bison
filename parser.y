%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hash.h"

struct hash* symbols;

void yyerror(const char* err);

extern int yylex();
%}

%locations
%define parse.error verbose

/* %define api.value.type { char* } */
%union {
  char* str;
  float num;
}

%token <str> IDENTIFIER
%token <num> NUMBER
%token <str> EQUALS PLUS MINUS TIMES DIVIDEDBY
%token <str> SEMICOLON LPAREN RPAREN
%token <str> IF ELSE COLON

%type <num> expression

%left PLUS MINUS
%left TIMES DIVIDEDBY
/* %right */
/* %nonassoc */

%start program

%%

program
  : program statement
  | statement
  ;

statement
  : assignmentStatement
  | ifStatement
  ;

assignmentStatement
  : IDENTIFIER EQUALS expression SEMICOLON {
    hash_insert(symbols, $1, $3);
    free($1);
  }
  | error SEMICOLON {
    fprintf(stderr, "Error: bad statement on line %d\n", @1.first_line);
  }
  ;

ifStatement
  : IF expression COLON statement
  | IF expression COLON closedStatement ELSE COLON statement
  ;

closedStatement
  : assignmentStatement
  | IF expression COLON closedStatement ELSE COLON closedStatement
  ;

expression
  : LPAREN expression RPAREN { $$ = $2; }
  | expression PLUS expression { $$ = $1 + $3; }
  | expression MINUS expression { $$ = $1 - $3; }
  | expression TIMES expression { $$ = $1 * $3; }
  | expression DIVIDEDBY expression { $$ = $1 / $3; }
  | NUMBER { $$ = $1; }
  | IDENTIFIER {
    // printf("identifier encountered on line %d\n", @1.first_line);
    if (hash_contains(symbols, $1)) {
      $$ = hash_get(symbols, $1);
    } else {
      fprintf(stderr, "Error: unrecognized symbol (%s) on line %d\n",
        $1, @1.first_line);
      YYERROR;
    }
    free($1);
  }
  ;

%%

void yyerror(const char* err) {
  fprintf(stderr, "Error: %s\n", err);
}

int main() {
  symbols = hash_create();
  if(!yyparse()) {
    printf("Symbol values:\n");
    struct hash_iter* iter = hash_iter_create(symbols);
    while (hash_iter_has_next(iter)) {
      char* key;
      float val = hash_iter_next(iter, &key);
      printf("  -- %s = %f\n", key, val);
    }
    return 0;
  } else {
    return 1;
  }
}
