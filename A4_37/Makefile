a.out : lex.yy.c A4_37.tab.c A4_37.c
	gcc A4_37.tab.c lex.yy.c A4_37.c -lm


lex.yy.c: A4_37.l
	flex A4_37.l

A4_37.tab.c: A4_37.y
	bison -dtv A4_37.y

clean:
	rm A4_37.tab.h A4_37.tab.c lex.yy.c a.out A4_37.output output.txt

test:
	./a.out < A4_37.nc > output.txt 2>&1
