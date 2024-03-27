NBC = nbc
OPTIMIZE = -Z2
FIRMWARE =
PYTHON = python3
# or PYTHON = poetry -C path/to/nxt-python run python

TESTS = float

tests: $(TESTS:%=%.diff)

build: $(TESTS:%=%.rxe)

%.rxe: %.nxc
	$(NBC) $(OPTIMIZE) $(FIRMWARE) -O=$@ $<

%.load: %.rxe
	$(NBC) $(OPTIMIZE) $(FIRMWARE) -d -b $<

%.out: %.load
	$(PYTHON) term.py -qos $* > $@

%.diff: %.out %.expect
	diff $^ > $@

%.S: %.nxc
	$(NBC) $(OPTIMIZE) $(FIRMWARE) -nbc=$@ $<

clean-out:
	rm -f $(TESTS:%=%.out) $(TESTS:%=%.diff)

clean: clean-out
	rm -f $(TESTS:%=%.rxe)

.SECONDARY:

.DELETE_ON_ERROR:
