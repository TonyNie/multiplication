CC=gcc

multiplication: main.o
	$(CC)  -o multiplication main.o


clean:
	rm -f *.o multiplication
