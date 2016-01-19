all: faint test testcpp

faint: faint.o map.c fault_inject 
	gcc -Wall -g -c map.c -o map_c.o
	gcc faint.o map_c.o -Wall -g -Wl,--format=binary -Wl,fault_inject.so -Wl,--format=binary -Wl,fault_inject32.so -Wl,--format=default -o faint

faint.o: faint.c
	gcc -c faint.c -Wall -g -fno-builtin-log -o faint.o

# faint can compile a 32bit version but this is not recommended, as the 64 bit version can also profile 32 bit binaries 
#faint32: faint32.o map.c fault_inject 
#	gcc -Wall -m32 -g -c map.c -o map_c32.o
#	gcc faint32.o map_c32.o -m32 -Wall -g -Wl,--format=binary -Wl,fault_inject.so -Wl,--format=binary -Wl,fault_inject32.so -Wl,--format=default -o faint32

#faint32.o: faint.c
#	gcc -c -m32 faint.c -Wall -g -fno-builtin-log -o faint32.o

fault_inject: fault_inject.cpp map.o map32.o
	g++ -Wall -fPIC -DPIC -c -g -fno-stack-protector -funwind-tables -fpermissive fault_inject.cpp
	g++ -shared -g -o fault_inject.so map.o fault_inject.o -ldl

	g++ -Wall -fPIC -DPIC -c -g -fno-stack-protector -funwind-tables -fpermissive -m32 fault_inject.cpp -o fault_inject32.o
	g++ -shared -g -m32 -o fault_inject32.so map32.o fault_inject32.o -ldl
	
map.o: map.c
	g++ map.c -fPIC -DPIC -Wall -c -g -o map.o

map32.o: map.c
	g++ map.c -fPIC -DPIC -Wall -c -g -m32 -o map32.o
		
test: test.c
	gcc test.c -Wall -g -o test
	
test32: test.c
	gcc test.c -Wall -g -m32 -o test32
	
testcpp: test.cpp
	g++ test.cpp -Wall -g -o testcpp
	
clean:
	-rm -f *.so *.o faint test mallocs profile settings testcpp
	
run: faint test
	./faint test
	
runcpp: faint testcpp
	./faint testcpp
	
run32: faint test32
	./faint test32
	
run-io: faint test
	./faint --no-memory --file-io test
	
install: faint
	cp faint /usr/bin/faint
	
uninstall: 
	rm /usr/bin/faint
	