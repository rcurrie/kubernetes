import time
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Magic genomic processing black box")
    parser.add_argument("fastq", nargs="?", help="FAST to process")
    parser.add_argument("-c", "--count", default=100, required=False,
                        help="Count")
    args = parser.parse_args()
    for i in range(int(args.count)):
        print("Performing magic on {} block {}".format(args.fastq, i))
        time.sleep(1)
