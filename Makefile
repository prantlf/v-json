all: check test

check:
	v fmt -w .
	v vet .

test:
	NO_COLOR=1 v test .

clean:
	rm -rf *_test *.dSYM
