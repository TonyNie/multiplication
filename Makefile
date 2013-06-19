CC=gcc
CFLAGS += -g

multiplication: main.o
	$(CC) -o multiplication main.o

main.o: main.S
	$(CC) -c -g -o main.o main.S

clean:
	rm -f *.o multiplication
