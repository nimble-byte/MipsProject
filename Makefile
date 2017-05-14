CC=g++
BINARY=trigonometry.exe
SRC=CSrc
BUILDDIR=build

all:
		$(CC) $(SRC)/main.cpp -o $(BINARY)

clean:
			rm -rf $(BUILDDIR)/*

dirs:
			mkdir $(BUILDDIR)
