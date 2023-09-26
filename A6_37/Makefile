assembly: nanoC liba2.a
	@echo "\n------------------- Generating Quads for the test files ---------------\n"

	./nanoC 1 > A6_37_quads1.out
	./nanoC 2 > A6_37_quads2.out
	./nanoC 3 > A6_37_quads3.out
	./nanoC 4 > A6_37_quads4.out
	./nanoC 5 > A6_37_quads5.out
	./nanoC 6 > A6_37_quads6.out
	./nanoC 7 > A6_37_quads7.out
	./nanoC 8 > A6_37_quads8.out
	./nanoC 9 > A6_37_quads9.out
	./nanoC 10 > A6_37_quads10.out

	@echo "\n-------------    Generating the object files from assembly code   ---------------\n"

	gcc -c A6_37_quads1.s
	gcc -c A6_37_quads2.s
	gcc -c A6_37_quads3.s
	gcc -c A6_37_quads4.s
	gcc -c A6_37_quads5.s
	gcc -c A6_37_quads6.s
	gcc -c A6_37_quads7.s
	gcc -c A6_37_quads8.s
	gcc -c A6_37_quads9.s
	gcc -c A6_37_quads10.s

	@echo "\n-------------    Compiling the test files   ---------------\n"

	gcc A6_37_quads1.o -o A6_37_quads1 -L. -la2 -no-pie
	gcc A6_37_quads2.o -o A6_37_quads2 -L. -la2 -no-pie
	gcc A6_37_quads3.o -o A6_37_quads3 -L. -la2 -no-pie
	gcc A6_37_quads4.o -o A6_37_quads4 -L. -la2 -no-pie
	gcc A6_37_quads5.o -o A6_37_quads5 -L. -la2 -no-pie
	gcc A6_37_quads6.o -o A6_37_quads6 -L. -la2 -no-pie
	gcc A6_37_quads7.o -o A6_37_quads7 -L. -la2 -no-pie
	gcc A6_37_quads8.o -o A6_37_quads8 -L. -la2 -no-pie
	gcc A6_37_quads9.o -o A6_37_quads9 -L. -la2 -no-pie
	gcc A6_37_quads10.o -o A6_37_quads10 -L. -la2 -no-pie

	@echo "\n###########  Use ./test<i> for testing the ith file  ##########\n"

liba2.a: a2.c
	gcc -c a2.c
	ar -rcs liba2.a a2.o

nanoC: lex.yy.o A6_37.tab.o A6_37_translator.o A6_37_target_translator.o
	g++ lex.yy.o A6_37.tab.o A6_37_translator.o A6_37_target_translator.o -lfl -o nanoC

A6_37_target_translator.o: A6_37_target_translator.cxx
	g++ -c A6_37_target_translator.cxx

A6_37_translator.o: A6_37_translator.cxx A6_37_translator.h
	g++ -c A6_37_translator.h
	g++ -c A6_37_translator.cxx

A6_37.tab.o: A6_37.tab.c
	g++ -c A6_37.tab.c

lex.yy.c: A6_37.l A6_37.tab.h A6_37_translator.h
	flex A6_37.l

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

A6_37.tab.c: A6_37.y
	bison -dtv A6_37.y -W

A6_37.tab.h: A6_37.y
	bison -dtv A6_37.y -W


	
clean:
	rm lex.yy.c\
	   A6_37.tab.c\
	   A6_37.tab.h\
	   lex.yy.o\
	   A6_37.tab.o\
	   A6_37_translator.o\
	   A6_37_quads1\
	   A6_37_quads2\
	   A6_37_quads3\
	   A6_37_quads4\
	   A6_37_quads5\
	   A6_37_quads6\
	   A6_37_quads7\
	   A6_37_quads8\
	   A6_37_quads9\
	   A6_37_quads10\
	   nanoC\
	   A6_37_target_translator.o\
	   A6_37_translator.h.gch\
	   A6_37_quads1.out\
	   A6_37_quads2.out\
	   A6_37_quads3.out\
	   A6_37_quads4.out\
	   A6_37_quads5.out\
	   A6_37_quads6.out\
	   A6_37_quads7.out\
	   A6_37_quads8.out\
	   A6_37_quads9.out\
	   A6_37_quads10.out\
	   liba2.a\
	   a2.o\
	   A6_37_quads1.o\
	   A6_37_quads2.o\
	   A6_37_quads3.o\
	   A6_37_quads4.o\
	   A6_37_quads5.o\
	   A6_37_quads6.o\
	   A6_37_quads7.o\
	   A6_37_quads8.o\
	   A6_37_quads9.o\
	   A6_37_quads10.o\
	   A6_37_quads1.s\
	   A6_37_quads2.s\
	   A6_37_quads3.s\
	   A6_37_quads4.s\
	   A6_37_quads5.s\
	   A6_37_quads6.s\
	   A6_37_quads7.s\
	   A6_37_quads8.s\
	   A6_37_quads9.s\
	   A6_37_quads10.s
