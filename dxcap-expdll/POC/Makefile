CC = cl
CFLAGS = /nologo /W4 /LD
LDFLAGS = /link user32.lib /OUT:test.dll

all: test.dll

test.dll: test.c
	$(CC) $(CFLAGS) test.c $(LDFLAGS)

clean:
	-del /Q test.dll test.obj test.exp test.lib 2>NUL
