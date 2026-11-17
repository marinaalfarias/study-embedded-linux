CC = $(TARGET_CC)
CFLAGS = $(TARGET_CFLAGS) -g -O0
LDFLAGS = $(TARGET_LDFLAGS)

all: contador

contador: main.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -rf contador