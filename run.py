import time
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Magic genomic processing black box")
    parser.add_argument("file", nargs="?", help="File to process")
    parser.add_argument("-c", "--count", default=100, required=False,
                        help="Count")
    args = parser.parse_args()
    for i in range(int(args.count)):
        print("Performing magic block {} from {}".format(i, args.file), flush=True)
        time.sleep(1)
