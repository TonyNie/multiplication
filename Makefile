CC=gcc

multiplication: main.o
	$(CC) -o multiplication main.o

clean:
	rm -r *.o multiplication
