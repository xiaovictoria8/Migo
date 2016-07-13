import sys
import csv
import heapq
from functions import get_jaccard_dist

"""
Creates a CSV file that will be used as input for alignment.
Outputs the top 1000 sentence pairs from the input, as sorted by Jaccard distance.
arg 1: data (ie. all.tsv)
arg 2: CSV output file
arg 4: 1 to print the jaccard distance of each pair to stdout, any other number otherwise
"""

# returns a list of the top n sentence pairs in ldc, as sorted by jaccard distance
# each sentence pair is represented by a tuple
# pair[0] = jaccard distance, pair[1] = source sentence, pair[2] = target sentence
def top_pairs_dict(n, ldc):
    pairs_heap = []
    
    for row in ldc:
        try:
            print("")
            if (row[7] == "1" or row[5] == "hl"):
                continue
            
            # scan through all possible sentence pairs in the row
            for i in range(8, len(row)):
                for j in range(i+1, len(row)):
                    print("SOURCE: " + str(i))
                    print("TARGET: " + str(j))
                    
                    # only select sentence that have between 5 and 30 words
                    if len(row[i].split()) <= 30 and len(row[i].split()) >= 5 and len(row[j].split()) <= 30 and len(row[j].split()) >= 5:
                        
                        # insert pair into heap, and discard min element
                        jd = get_jaccard_dist(row[i], row[j])
                        print("JACCARD DISTANCE: " + str(jd))
                        pair = (jd, row[i], row[j])
                        heapq.heappush(pairs_heap, pair)
                        print("inserted " + str(pair) + " into heap")
                        
                        if len(pairs_heap) > 1000:
                            p = heapq.heappop(pairs_heap)
                            print("removed " + str(p) + " from heap")
        except:
            pass

def main():
    # open data files
    ldc = csv.reader(open(sys.argv[1], 'rb'), delimiter = '\t')
    csv_writer = csv.writer(open(sys.argv[2], 'w'), delimiter = '\t')
    
    n = 1000
    
    # create dictionary of top n pairs, mapping a [source sentence, target sentence] tuple to the pair's jaccard distance
    jd_dict = top_pairs_dict(ldc, n)
    

if __name__ == "__main__":
    main()