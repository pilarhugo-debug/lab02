# Makefile para compilar lab02.pgc con SQL embebido (ECPG)
# Requiere tener instalado postgresql-server-dev-XX (incluye ecpg)
#
# Uso:
#   make        -> genera el ejecutable "lab02"
#   make clean  -> elimina los archivos generados

PG_INCLUDE := $(shell pg_config --includedir)
PG_LIB     := $(shell pg_config --libdir)

CC = gcc
CFLAGS = -I$(PG_INCLUDE)
LDFLAGS = -L$(PG_LIB) -lecpg -lpq

all: lab02

lab02.c: lab02.pgc
	ecpg lab02.pgc

lab02.o: lab02.c
	$(CC) $(CFLAGS) -c lab02.c -o lab02.o

lab02: lab02.o
	$(CC) -o lab02 lab02.o $(LDFLAGS)

clean:
	rm -f lab02.c lab02.o lab02
