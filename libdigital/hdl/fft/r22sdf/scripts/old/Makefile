FLAGS = -g -Wall -Wextra -Wshadow -Wstrict-aliasing -ansi -pedantic -Werror -std=gnu11

exec: hex_to_init
	./hex_to_init

hex_to_init: hex_to_init.c
	gcc $(FLAGS) hex_to_init.c -o hex_to_init
