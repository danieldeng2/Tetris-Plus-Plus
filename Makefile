CORE_SRC = $(wildcard src/core/*.c)
GENE_SRC = $(wildcard src/genetic-ai/*.c)
RL_SRC   = $(wildcard src/rl-ai/*.c)
PI_SRC   = $(wildcard src/pi/*.c)

CORE_OBJS = $(CORE_SRC:src/core/%.c=obj/core/%.o)
GENE_OBJS = $(GENE_SRC:src/genetic-ai/%.c=obj/genetic-ai/%.o)
RL_OBJS   = $(RL_SRC:src/rl-ai/%.c=obj/rl-ai/%.o)
PI_OBJS   = $(PI_SRC:src/pi/%.c=obj/pi/%.o)
CORE_NO_MAIN = $(filter-out obj/core/tetris.o, $(CORE_OBJS))
DEPS = $(CORE_OBJS:%.o=%.d) $(GENE_OBJS:%.o=%.d) $(RL_OBJS:%.o=%.d) $(PI_OBJS:%.o=%.d)

CC          = gcc
IncludePath = $(addprefix -I, $(wildcard src/*/include)) 
CFLAGS      = -MMD -Wall -g -D_DEFAULT_SOURCE -std=c99 -Werror -pedantic $(IncludePath)
LDLIBS      = -lncurses -lm
PILIBS      = -lwiringPi 

all: core genetic pi rl lib
core:     bin/tetris
genetic:  bin/gtrain
rl:       bin/rltrain
pi:       bin/tetrispi

bin/tetris: $(CORE_OBJS)
	$(CC) $^ $(LDLIBS) -o $@

bin/tetrispi: $(PI_OBJS) $(CORE_OBJS)
	$(CC) $^ $(LDLIBS) $(PILIBS) -o $@

bin/gtrain: $(GENE_OBJS) $(CORE_NO_MAIN)
	$(CC) $^ $(LDLIBS) -o $@

bin/rltrain: $(RL_OBJS) $(CORE_NO_MAIN)
	$(CC) $^ $(LDLIBS) -o $@

# Automatic header dependency inclusion by pre processor
-include $(DEPS)

obj/core/%.o: src/core/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

obj/genetic-ai/%.o: src/genetic-ai/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

obj/rl-ai/%.o: src/rl-ai/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

obj/pi/%.o: src/pi/%.c
	$(CC) $(CFLAGS) -c -o $@ $<


lib:
	cd lib; make

clean:
	rm -f $(DEPS)
	rm -f $(CORE_OBJS) $(GENE_OBJS) $(RL_OBJS) $(PI_OBJS)
	rm -f  bin/tetris bin/gtrain bin/rltrain bin/tetrispi
	cd lib; make clean

.PHONY: src clean lib core genetic pi rl