test: a.out
	
	@echo "TRANSLATING TEST FILE 1 \n"
	./a.out < A5_37_test1.nc > A5_37_quads1.out
	@echo "Test File 1 Successfully Translated !\n"

	@echo "TRANSLATING TEST FILE 2 \n"
	./a.out < A5_37_test2.nc > A5_37_quads2.out
	@echo "Test File 2 Successfully Translated !\n"

	@echo "TRANSLATING TEST FILE 3 \n"
	./a.out < A5_37_test3.nc > A5_37_quads3.out
	@echo "Test File 3 Successfully Translated !\n"

	@echo "TRANSLATING TEST FILE 4 \n"
	./a.out < A5_37_test4.nc > A5_37_quads4.out
	@echo "Test File 4 Successfully Translated !\n"

	@echo "TRANSLATING TEST FILE 5 \n"
	./a.out < A5_37_test5.nc > A5_37_quads5.out
	@echo "Test File 5 Successfully Translated !\n"

	@echo "TRANSLATING TEST FILE 6 \n"
	./a.out < A5_37_test6.nc > A5_37_quads6.out
	@echo "Test File 6 Successfully Translated !\n"

	@echo "TRANSLATING TEST FILE 7 \n"
	./a.out < A5_37_test7.nc > A5_37_quads7.out
	@echo "Test File 7 Successfully Translated !\n"


	@echo "TRANSLATING TEST FILE 8 \n"
	./a.out < A5_37_test8.nc > A5_37_quads8.out
	@echo "Test File 8 Successfully Translated !\n"

	@echo "TRANSLATING TEST FILE 9 \n"
	./a.out < A5_37_test9.nc > A5_37_quads9.out
	@echo "Test File 9 Successfully Translated !\n"

	@echo "TRANSLATING TEST FILE 10 \n"
	./a.out < A5_37_test10.nc > A5_37_quads10.out
	@echo "Test File 10 Successfully Translated !\n"


a.out: lex.yy.o A5_37.tab.o A5_37_translator.o
	g++ lex.yy.o A5_37.tab.o A5_37_translator.o -lfl

A5_37_translator.o: A5_37_translator.cxx A5_37_translator.h
	g++ -c A5_37_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

A5_37.tab.o: A5_37.tab.c
	g++ -c A5_37.tab.c

lex.yy.c: A5_37.l A5_37.tab.h A5_37_translator.h
	flex A5_37.l

A5_37.tab.c: A5_37.y
	bison -dtv A5_37.y -W

A5_37.tab.h: A5_37.y
	bison -dtv A5_37.y -W

clean:
	rm lex.yy.c\
	   lex.yy.o\
	   a.out\
	   A5_37.tab.c\
	   A5_37.tab.h\
	   A5_37.tab.o\
	   A5_37_translator.o\
	   A5_37.output\
	   *.out