CC=gcc -g

all: pcc

pcc: pcc.o pcc.lex.o error.o astree.o keywords.o
	$(CC) -o pcc error.o keywords.o astree.o pcc.lex.o pcc.o -lm

pcc.lex.o: pcc.l
	flex -o pcc.lex.c pcc.l
	$(CC) -o pcc.lex.o -c pcc.lex.c

pcc.o: pcc.y
	bison --defines -v pcc.y -o pcc.c
	$(CC) -o pcc.o -c pcc.c

error.o: error.c
	$(CC) -o error.o -c error.c

astree.o: astree.c
	$(CC) -o astree.o -c astree.c

keywords.o: keywords.c
	$(CC) -o keywords.o -c keywords.c
