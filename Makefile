SPIKE_FILES := ENCFF001RTO.fasta ENCFF001RTP.fasta
EDW := http://encodedcc.sdsc.edu/warehouse

# part of a magic trick to convert a space seperated list into a comma seperated list
NULL :=
SPACE := $(null) #
COMMA := ,

all: spikes-10.fa spikes-36.fa spikes-100.fa

spikes-10.fa: $(SPIKE_FILES)
	python slide_window.py -w 10 $^ > $@

spikes-36.fa: $(SPIKE_FILES)
	python slide_window.py -w 36 $^ > $@

spikes-100.fa: $(SPIKE_FILES)
	python slide_window.py -w 100 $^ > $@

ENCFF001RTO.fasta:
	curl -O $(EDW)/2013/7/26/$@

ENCFF001RTP.fasta:
	curl -O $(EDW)/2013/7/26/$@

# make index files, the touch is to create empty flag file if successful
indexes/spikes: $(SPIKE_FILES)
	bowtie-build $(subst $(SPACE),$(COMMA),$^) $@  && touch $@
