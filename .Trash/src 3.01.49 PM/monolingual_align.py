#!/user/bin/python
from aligner import *
import csv
import sys
import time

"""
Generates alignments for all sentence pairs in the input file using Arafat Sultan et al.'s
contextual-based monolingual aligner (https://github.com/ma-sultan/monolingual-word-aligner) ???
Input is a tab-separated file, where each row contains two sentences (separated by tab-stop) 
Output contains alignments in the Pharaoh format. Each row in the file contains alignments 
corresponding to the sentence pair in the corresponding row of the input.
arg 1: input file
arg 2: output file
arg 3: 1 to print aligned words to stdout
"""

def main():
    
    start = time.clock()
    
    # open data files
    reader = csv.reader(open(sys.argv[1], 'rb'), delimiter = '\t')
    writer = csv.writer(open(sys.argv[2], 'w'), delimiter = "\t")
    
    # loop through every row in the input and align
    n = 1
    for row in reader:
        try:
            print(n)
            n = n + 1
            alignments = align(row[1], row[2])
            
            # convert alignments to Pharaoh format and print
            align_string = ""
            for align_pair in alignments[0]:
                align_string += str((align_pair[0] - 1)) + "-" + str((align_pair[1] - 1)) + " "
            writer.writerow([row[0], align_string + "\n"])
            
            # print alignment pairs if requested
            if sys.argv[3] == "1":
                print(align_string)
                print(str(alignments[1]) + "\n")
                
        except:
            pass
    
    end = time.clock()
    
    # print the amount of time the task took
    print("TOTAL TIME ELAPSED: " + str(end - start))
    
    writer.close()
if __name__ == "__main__":
    main()


