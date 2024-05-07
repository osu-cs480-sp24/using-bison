%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser-push.h"

int num_ops = 0;
int num_nums = 0;

#define MAX_IDS 512
char* saved_ids[MAX_IDS];
int num_ids = 0;

void save_id(char*);

int have_err = 0;

static YYSTYPE yylval;
static YYLTYPE yylloc;
extern yypstate* pstate;

#define YY_USER_ACTION \
    yylloc.first_line = yylloc.last_line = yylineno;

#define PUSH_TOKEN(category) do {                               \
    int s = yypush_parse(pstate, category, &yylval, &yylloc);   \
    if (s != YYPUSH_MORE) {                                     \
        yypstate_delete(pstate);                                \
        return s;                                               \
    }                                                           \
} while (0)
%}

%option noyywrap
%option yylineno

%%

[ \t\n]*    /* Ignore whitespace. */

[a-z][0-9]? {
    // save_id(yytext);
    yylval.str = malloc((yyleng + 1) * sizeof(char));
    strncpy(yylval.str, yytext, yyleng + 1);
    PUSH_TOKEN(IDENTIFIER);
}

[0-9]+("."[0-9]+)? {
    // num_nums++;
    yylval.num = atof(yytext);
    PUSH_TOKEN(NUMBER);
}

"="     PUSH_TOKEN(EQUALS);
"+"     PUSH_TOKEN(PLUS);
"-"     PUSH_TOKEN(MINUS);
"*"     PUSH_TOKEN(TIMES);
"/"     PUSH_TOKEN(DIVIDEDBY);

";"     PUSH_TOKEN(SEMICOLON);
"("     PUSH_TOKEN(LPAREN);
")"     PUSH_TOKEN(RPAREN);

. {
    have_err = 1;
    fprintf(stderr, "Invalid symbol on line %d: %s\n", yylineno, yytext);
}

<<EOF>> {
    int s = yypush_parse(pstate, 0, NULL, NULL);
    yypstate_delete(pstate);
    return s;
}

%%

void save_id(char* id) {
    if (num_ids >= MAX_IDS) {
        fprintf(stderr, "Too many identifiers!!\n");
        return;
    }

    for (int i = 0; i < num_ids; i++) {
        if (strcmp(id, saved_ids[i]) == 0) {
            return;
        }
    }

    int l = strlen(id) + 1;
    saved_ids[num_ids] = malloc(l * sizeof(char));
    strncpy(saved_ids[num_ids], id, l);
    num_ids++;
}

/* int main() {
    if (!yylex()) {
        printf("Unique identifiers:\n");
        for (int i = 0; i < num_ids; i++) {
            printf("  %s\n", saved_ids[i]);
        }
        printf("Number of operations: %d\n", num_ops);
        printf("Number of numbers: %d\n", num_nums);
    }
} */
