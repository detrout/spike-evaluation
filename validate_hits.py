from __future__ import print_function
import argparse

def main(cmdline=None):
    parser = make_parser()
    args = parser.parse_args(cmdline)

    for filename in args.filenames:
        with open(filename, 'r') as instream:
            validate_hits(instream)

def make_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('filenames', nargs='*')
    return parser

class ValidationError(RuntimeError):
    pass

def validate_hits(stream):
    lines = 0
    count = 0
    for line in stream:
        lines += 1
        try:
            records = line.split('\t')
            encoded_name, location = records[0].split('[')
            encoded_name = encoded_name[:-1]
            start, stop = location[:-1].split(':')
            name = records[2]
            hit = records[3]
            #print(encoded_name, start, stop)
            if encoded_name != name:
                raise ValidationError("{} != {}".format(encoded_name, name))
            if start != hit:
                raise ValidationError("{} != {}".format(start, hit))
            count += 1
        except ValueError as e:
            print(e)
            print(line)
            break
        except ValidationError as e:
            print(encoded_name, start, stop, name, hit)
            pass
    print('{}/{} passed checks'.format(count, lines))
    
if __name__ == '__main__':
    main()
    