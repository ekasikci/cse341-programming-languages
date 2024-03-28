%{
#include "yacc_functions.h"
#include "y.tab.h"
extern YYSTYPE yylval;
%}

%%
[\n\f\r\t ] { /* skip whitespaces */}
and { return KW_AND; }
or { return KW_OR; }
not { return KW_NOT; }
equal { return KW_EQUAL; }
less { return KW_LESS; }
nil { return KW_NIL; }
list { return KW_LIST; }
append { return KW_APPEND; }
concat { return KW_CONCAT; }
set { return KW_SET; }
def { return KW_DEF; }
for { return KW_FOR; }
if { return KW_IF; }
exit { return KW_EXIT; return 0;}
load { return KW_LOAD; }
display { return KW_DISPLAY; }
true { return KW_TRUE; }
false { return KW_FALSE; }
"+" { return OP_PLUS; }
"-" { return OP_MINUS; }
"/" { return OP_DIV; }
"*" { return OP_MULT; }
"(" { return OP_OP; }
")" { return OP_CP; }
"," { return OP_COMMA; }
;{2}.*\n { /* do nothing until see the new line */ return COMMENT; }
[0-9]+b[1-9][0-9]* { 
    char *numerator_str = strtok(yytext, "b");
    char *denominator_str = strtok(NULL, "b");

    if (numerator_str != NULL && denominator_str != NULL) {
        yylval.valuef = create_valuef(atoi(numerator_str), atoi(denominator_str));
        return VALUEF;
    } else {
        fprintf(stderr, "Error parsing Valuef: %s\n", yytext);
        return ERROR;
    }
}

[a-zA-Z][0-9a-zA-Z]* { strcpy(yylval.identifier, yytext); return IDENTIFIER; }
[0-9]+b0[0-9]* { printf("SYTANX ERROR %s cannot be tokenized. Division by zero is not allowed.\n\n", yytext);}
[0-9]+[a-zA-Z]+. { printf("SYTANX ERROR %s cannot be tokenized. Invalid identifier name.\n\n", yytext);}
. { printf("SYTANX_ERROR %s cannot be tokenized\n", yytext);}
%%

int yywrap(){}