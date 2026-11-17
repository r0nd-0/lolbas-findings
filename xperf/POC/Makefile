CC = cl
CFLAGS = /nologo /W4
LDFLAGS = /link user32.lib /SUBSYSTEM:WINDOWS /OUT:test.exe

all: test.exe

test.exe: test.c
	$(CC) $(CFLAGS) test.c $(LDFLAGS)

clean:
	-del /Q test.exe test.obj 2>NUL
