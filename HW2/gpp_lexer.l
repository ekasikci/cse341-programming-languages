%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*keywords*/
#define KW_AND 10
#define KW_OR 11
#define KW_NOT 12
#define KW_EQUAL 13
#define KW_LESS 14
#define KW_NIL 15
#define KW_LIST 16
#define KW_APPEND 17
#define KW_CONCAT 18
#define KW_SET 19
#define KW_DEF 20
#define KW_FOR 21
#define KW_IF 22
#define KW_EXIT 23
#define KW_LOAD 24
#define KW_DISPLAY 25
#define KW_TRUE 26
#define KW_FALSE 27
/*operators*/
#define OP_PLUS 28
#define OP_MINUS 29
#define OP_DIV 30
#define OP_MULT 31
#define OP_OP 32
#define OP_CP 33
#define OP_COMMA 34
/*comment*/
#define COMMENT 35
/*valuef*/
#define VALUEF 36
/*identifier*/
#define IDENTIFIER 37

/*error*/
#define ERROR 101

int token = -1;
int quotes_flag = 0;
int comment_flag = 0;
%}

%%
[\n \t] { /* skip whitespaces */}
and { printf("KW_AND\n"); }
or { printf("KW_OR\n"); }
not { printf("KW_NOT\n"); }
equal { printf("KW_EQUAL\n"); }
less { printf("KW_LESS\n"); }
nil { printf("KW_NIL\n"); }
list { printf("KW_LIST\n"); }
append { printf("KW_APPEND\n"); }
concat { printf("KW_CONCAT\n"); }
set { printf("KW_SET\n"); }
def { printf("KW_DEF\n"); }
for { printf("KW_FOR\n"); }
if { printf("KW_IF\n"); }
exit { printf("KW_EXIT\n"); }
load { printf("KW_LOAD\n"); }
display { printf("KW_DISPLAY\n"); }
true { printf("KW_TRUE\n"); }
false { printf("KW_FALSE\n"); }
"+" { printf("OP_PLUS\n"); }
"-" { printf("OP_MINUS\n"); }
"/" { printf("OP_DIV\n"); }
"*" { printf("OP_MULT\n"); }
"(" { printf("OP_OP\n"); }
")" { printf("OP_CP\n"); }
"," { printf("OP_COMMA\n"); }
;{2}.*\n { /* do nothing until see the new line */ printf("COMMENT\n"); }
[0-9]+b[1-9][0-9]* { printf("VALUEF\n"); }
[a-zA-Z][0-9a-zA-Z]* { printf("IDENTIFIER\n"); }
[0-9]+b0[0-9]* { printf("SYTANX ERROR %s cannot be tokenized. Division by zero is not allowed.\n\n", yytext); 
		  exit(1);}
[0-9]+[a-zA-Z]+. { printf("SYTANX ERROR %s cannot be tokenized. Invalid identifier name.\n\n", yytext); 
		  exit(1);}
. { printf("SYTANX_ERROR %s cannot be tokenized\n", yytext);
    exit(1); }
%%

int yywrap(){}

int main(int argc, char* argv[]){
	if(argc == 2)
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	yylex();

	fclose(yyin);
	return 0;
}