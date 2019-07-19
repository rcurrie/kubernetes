import time
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Magic genomic processing black box")
    parser.add_argument("fastq", nargs="?", help="FAST to process")
    parser.add_argument("-v", "--verbose", required=False,
                        help="Verbose output")
    args = parser.parse_args()
    for i in range(100):
        print("Performing magic on {} block {}".format(args.fastq, i))
        time.sleep(1)
