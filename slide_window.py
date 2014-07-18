"""Read a fasta file and generate a sliding window of sequence to map with
"""
from __future__ import print_function

import argparse

def main(cmdline=None):
    parser = make_parser()
    args = parser.parse_args(cmdline)

    for filename in args.filenames:
        with open(filename, 'r') as instream:
            generate_fasta_windows(instream, args.window)

def make_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('filenames', nargs='+', help='list fasta files to generate reads from')
    parser.add_argument('-w', '--window', default=100, type=int,
                        help='Set sliding window length')
    return parser

def read_fasta(stream):
    """Read a fasta file returning a sequence of name and sequence.
    
    the sequence field will have all whitespace removed.
    """
    name = None
    seq = []
    for line in stream:
        if line[0] == '>':
            # if we've seen a complete sequence yield it
            if name is not None:
                yield (name, ''.join(seq))
                seq = []
            # save the next name
            name = line[1:].rstrip()
        else:
            seq.append(line.strip())

    # yield the last sequence assuming there was at least one
    if name is not None:
        yield (name, ''.join(seq))

def generate_fasta_windows(stream, read_length):
    for name, sequence in read_fasta(stream):
        for i in xrange(len(sequence)-read_length+1):
            print('>{}_[{}:{})'.format(name.replace(' ', '_'), i, i+read_length ))
            print(sequence[i:i+read_length])


if __name__ == '__main__':
    main()