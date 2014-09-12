SPIKE_FILES := ENCFF001RTO.fasta ENCFF001RTP.fasta
EDW := http://encodedcc.sdsc.edu/warehouse

BOWTIE1_DIR := /woldlab/castor/data00/proj/genome/programs/bowtie-0.12.9
BOWTIE2_DIR := /woldlab/castor/data00/proj/genome/programs/bowtie2-2.1.0
TOPHAT_DIR := /woldlab/castor/data00/proj/genome/programs/tophat-2.0.8.Linux_x86_64

BOWTIE1 := ${BOWTIE1_DIR}/bowtie
BOWTIE2 := ${BOWTIE2_DIR}/bowtie2

BOWTIE1_BUILD := ${BOWTIE1_DIR}/bowtie-build
BOWTIE2_BUILD  := ${BOWTIE2_DIR}/bowtie2-build

# part of a magic trick to convert a space seperated list into a comma seperated list
NULL :=
SPACE := $(null) #
COMMA := ,

all: spikes indexes indexes2
	
spikes: spikes-10.fa spikes-36.fa spikes-75.fa spikes-100.fa

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
bowtie: indexes/spikes indexes/ENCFF001RGS+spikes indexes/ENCFF001RGR+spikes

indexes/spikes.1.ebwt: $(SPIKE_FILES)
	$(BOWTIE1_BUILD) $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

indexes/ENCFF001RGS+spikes.1.ebwt: ENCFF001RGS.hg19.fa $(SPIKE_FILES)
	$(BOWTIE1_BUILD) $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

indexes/ENCFF001RGR+spikes.1.ebwt: ENCFF001RGR.hg19.fa $(SPIKE_FILES)
	$(BOWTIE1_BUILD) $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

# build bowtie2 indexes
bowtie2: indexes2/spikes indexes2/ENCFF001RGS+spikes indexes2/ENCFF001RGR+spikes

indexes/spikes.1.bt2: $(SPIKE_FILES)
	$(BOWTIE2_BUILD) $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

indexes/ENCFF001RGS+spikes.1.bt2: ENCFF001RGS.hg19.fa $(SPIKE_FILES)
	$(BOWTIE2_BUILD) $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

indexes/ENCFF001RGR+spikes.1.bt2: ENCFF001RGR.hg19.fa $(SPIKE_FILES)
	$(BOWTIE2_BUILD) $(subst $(SPACE),$(COMMA),$^) $@  && touch $@

gencode.v19.annotation.gtf:
	curl -O ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz
	gunzip gencode.v19.annotation.gtf.gz

tophat: gencode.v19/ENCFF001RGR+spikes.1.ebwt gencode.v19/ENCFF001RGS+spikes.1.ebwt \
        gencode.v19.bt2/ENCFF001RGR+spikes.1.bt2 gencode.v19.bt2/ENCFF001RGS+spikes.1.bt2

gencode.v19/ENCFF001RGR+spikes.1.ebwt: gencode.v19.annotation.gtf
	PATH=${BOWTIE1_DIR}:${PATH} \
	    ${TOPHAT_DIR}/tophat \
	    --GTF gencode.v19.annotation.gtf \
	    --bowtie1 \
	    --transcriptome-index gencode.v19/ENCFF001RGR+spikes \
	    indexes/ENCFF001RGR+spikes read.fq

gencode.v19/ENCFF001RGS+spikes.1.ebwt: gencode.v19.annotation.gtf
	PATH=${BOWTIE1_DIR}:${PATH} \
	    ${TOPHAT_DIR}/tophat \
	    --GTF gencode.v19.annotation.gtf \
	    --bowtie1 \
	    --transcriptome-index gencode.v19/ENCFF001RGS+spikes \
	    indexes/ENCFF001RGS+spikes read.fq

gencode.v19.bt2/ENCFF001RGR+spikes.1.bt2: gencode.v19.annotation.gtf
	PATH=${BOWTIE2_DIR}:${PATH} \
	    ${TOPHAT_DIR}/tophat \
	    --GTF gencode.v19.annotation.gtf \
	    --transcriptome-index gencode.v19.bt2/ENCFF001RGR+spikes \
	    indexes2/ENCFF001RGR+spikes read.fq

gencode.v19.bt2/ENCFF001RGS+spikes.1.bt2: gencode.v19.annotation.gtf
	PATH=${BOWTIE2_DIR}:${PATH} \
	    ${TOPHAT_DIR}/tophat \
	    --GTF gencode.v19.annotation.gtf \
	    --transcriptome-index gencode.v19.bt2/ENCFF001RGS+spikes \
	    indexes2/ENCFF001RGS+spikes read.fq
