%{
	#include <stdio.h>
	#include <string.h>
	#include "yacc_functions.h"
	int yylex();
	void yyerror (char *s);
	extern FILE *yyin;
%}

/*keywords*/
%token KW_AND
%token KW_OR
%token KW_NOT
%token KW_EQUAL
%token KW_LESS
%token KW_NIL
%token KW_LIST
%token KW_APPEND
%token KW_CONCAT
%token KW_SET
%token KW_FOR
%token KW_IF
%token KW_EXIT
%token KW_LOAD
%token KW_DISPLAY
%token KW_TRUE
%token KW_DEF
%token KW_FALSE
%token ERROR

/*operators*/
%token OP_PLUS
%token OP_COMMA
%token OP_MINUS
%token OP_DIV
%token OP_MULT
%token OP_OP
%token OP_CP
%token OP_OC
%token OP_CC
%token OP_DBLMULT
%token COMMENT
/**/


%union {
    Valuef *valuef;
    char identifier[12];
	Function * function;
}

%token <valuef> VALUEF
%token <identifier> IDENTIFIER

%type <valuef> EXP
%type <function> FUNCTION

%start START
%%

START	: EXP {print_valuef($1);}
        | FUNCTION {printf("#function\n");}
        | START FUNCTION {printf("#function\n");}
		| START EXP {print_valuef($2); }
		| COMMENT {printf("COMMENT\n");}
		| START COMMENT {printf("COMMENT\n");}
		| OP_OP KW_EXIT OP_CP { exit(0);}
		| START OP_OP KW_EXIT OP_CP { exit(0); }
		;

EXP 	: OP_OP OP_PLUS EXP EXP OP_CP {$$ = add_valuef($3, $4);}
		| OP_OP OP_MINUS EXP EXP OP_CP {$$ = sub_valuef($3, $4);}
		| OP_OP OP_MULT EXP EXP OP_CP {$$ = mul_valuef($3, $4);}
		| OP_OP OP_DIV EXP EXP OP_CP {$$ = div_valuef($3, $4);}
		| IDENTIFIER {$$ = get_identifier($1);}
		| VALUEF {$$=$1;}
		| OP_OP KW_SET IDENTIFIER EXP OP_CP {$$ = $4; ;set_element($3, $4);}
    	| OP_OP KW_DISPLAY EXP OP_CP { $$ = $3; } 
		;

FUNCTION: OP_OP KW_DEF IDENTIFIER EXP OP_CP {$$ = create_function_1($3, $4);}
        | OP_OP KW_DEF IDENTIFIER IDENTIFIER EXP OP_CP {$$ = create_function_2($3, $4, $5);}
        | OP_OP KW_DEF IDENTIFIER IDENTIFIER IDENTIFIER EXP OP_CP {$$ = create_function_3($3, $4, $5, $6);}
        ;



%%

void yyerror(char *s) {
    printf( "AN ERROR OCCURED %s\n", s );
}
int main(int argc, char** argv){
	
	FILE* fp = NULL;
	if( argc > 1 ){
		fp = fopen(argv[1], "r");
		if( fp == NULL ){
			printf("Could not open %s file with this filename\n", argv[1]);
			return 1;
		}
		yyin = fp;
	}
	return yyparse();
}