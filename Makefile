asm_files := $(wildcard *.s)

unistd: 
	cat /usr/include/asm/unistd_64.h | tr '#' '%'  > unistd.S

%.o : %.s
	nasm -felf64 $< -o $@

bin: badcat.s cli_test.s new_cat.s unistd
	nasm -f elf64 badcat.s
	ld -o badcat badcat.o
	nasm -felf64 cli_test.s
	gcc -static cli_test.o -o clitest
	nasm -felf64 new_cat.s
	gcc -static new_cat.o -o cat


cat: new_cat.o
	ld -o cat $<
	./cat crass

test: bin
	./clitest arg1 arg2 arg3

run: bin
	./badcat

clean:
	rm *.o
