check:
	bash checkenv.sh && bash checktypes.sh

admitted:
	coqc verification.v
	coqchk -silent -o -norec verification

clean:
	rm -f *.vo *.glob
