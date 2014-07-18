SPIKE_FILES := ENCFF001RTO.fasta ENCFF001RTP.fasta
EDW := http://encodedcc.sdsc.edu/warehouse

# part of a magic trick to convert a space seperated list into a comma seperated list
NULL :=
SPACE := $(null) #
COMMA := ,

all: spikes-10.fa spikes-36.fa spikes-75.fa spikes-100.fa

spikes-10.fa: $(SPIKE_FILES)
	python slide_window.py -w 10 $^ > $@

spikes-36.fa: $(SPIKE_FILES)
	python slide_window.py -w 36 $^ > $@

spikes-75.fa: $(SPIKE_FILES)
	python slide_window.py -w 75 $^ > $@

spikes-100.fa: $(SPIKE_FILES)
	python slide_window.py -w 100 $^ > $@

ENCFF001RTO.fasta:
	curl -O $(EDW)/2013/7/26/$@

ENCFF001RTP.fasta:
	curl -O $(EDW)/2013/7/26/$@

#hg19-Female
ENCFF001RGS.hg19.2bit:
	curl -O http://encodedcc.sdsc.edu/warehouse/2013/7/8/$@

#hg19-Male
ENCFF001RGR.hg19.2bit:
	curl -O http://encodedcc.sdsc.edu/warehouse/2013/7/8/$@

%.fa: %.2bit
	twoBitToFa $^ $@

# make index files, the touch is to create empty flag file if successful
# build bowtie 1 indexes
bowtie: index/spikes indexes/ENCFF001RGS+spikes indexes/ENCFF001RGR+spikes

indexes/spikes: $(SPIKE_FILES)
	bowtie-build $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

indexes/ENCFF001RGS+spikes: ENCFF001RGS.hg19.fa $(SPIKE_FILES)
	bowtie-build $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

indexes/ENCFF001RGR+spikes: ENCFF001RGR.hg19.fa $(SPIKE_FILES)
	bowtie-build $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

# build bowtie2 indexes
bowtie2: indexes2/spikes indexes2/ENCFF001RGS+spikes indexes2/ENCFF001RGR+spikes

indexes2/spikes: $(SPIKE_FILES)
	bowtie2-build $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

indexes2/ENCFF001RGS+spikes: ENCFF001RGS.hg19.fa $(SPIKE_FILES)
	bowtie2-build $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

indexes2/ENCFF001RGR+spikes: ENCFF001RGR.hg19.fa $(SPIKE_FILES)
	bowtie2-build $(subst $(SPACE),$(COMMA),$^) $@  && touch $@
