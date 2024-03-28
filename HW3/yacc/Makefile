CC = gcc
CFLAGS = -Wall -g

LEX = flex
YACC = yacc

all: gpp_interpreter

gpp_interpreter: lex.yy.c y.tab.c yacc_functions.c
	$(CC) $(CFLAGS) lex.yy.c y.tab.c yacc_functions.c -lfl -o gpp_interpreter

lex.yy.c: gpp_lexer.l
	$(LEX) gpp_lexer.l

y.tab.c: gpp_interpreter.y
	$(YACC) -d gpp_interpreter.y

clean:
	rm -f lex.yy.c y.tab.c y.tab.h gpp_interpreter

clean-generated:
	rm -f lex.yy.c y.tab.c y.tab.h
