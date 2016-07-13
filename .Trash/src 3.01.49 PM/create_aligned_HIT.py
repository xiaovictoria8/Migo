"""
arg 1 : source file
arg 2 : target_file
arg 3 : alignment_file
arg 4 : original sentence file *.tsv
arg 5 : csv_output
"""

#!/usr/bin/python
import os
import sys
import csv
import re
import codecs
from nltk.tokenize import wordpunct_tokenize
from functions import get_jaccard_dist

#makes a dictionary keyed by sentence of doc id sentence id, and doc type
def make_doc_dict():
  ldc = csv.reader(open(sys.argv[4], 'rb'), delimiter='\t')
  sent_id_dict = {}
  for row in ldc:
    try:
      numSentences = int(row[7])
      for i in range (8,8+ numSentences) :
        key = (" ").join(re.findall("[\w]+|[.,!?;()-]|'[\w]+", row[i]))
        key = key.replace('"', '&quot;')
        key = key.replace("'", '&apos;')
        sent_id_dict[key.lower().strip()] = row[2] + '\t' + row[3] + '\t' + row[5]
    except:
      pass
  return sent_id_dict

def main():
    """    
    Creates a CSV file as input to the word-alignment HIT.
    """
    target_file = codecs.open(sys.argv[2], "rt", encoding='latin-1').readlines()
    source_file = codecs.open(sys.argv[1], "rt", encoding='latin-1').readlines()
    alignment_file = open(sys.argv[3], "r").readlines()
    csv_output = open(sys.argv[5], "w")
    csv_writer = csv.writer(csv_output)
    headers = ["source", "target", "sureAlignments", "possAlignments", "sourceHighlights", "targetHighlights", "docID", "sentID", "jaccard_dist", "docType"]
    csv_writer.writerow(headers)

    possAlignments = ""
    sourceHighlights = ""
    targetHighlights = ""
    docID = ""
    sentID = ""
    docType = ""

    doc_dict = make_doc_dict()

    for i in range(len(target_file)):
        target = target_file[i].strip()
        source = source_file[i].strip()
        alignment = alignment_file[i].strip()
        source = source.replace('"', '&quot;')
        target = target.replace('"', '&quot;')
        source = source.replace("'", '&apos;')
        target = target.replace("'", '&apos;')

        jaccardDist = get_jaccard_dist(target, source)

        source_length = len(source.split()) 
        target_length = len(target.split())
        if source in doc_dict:
            doc_sent_id = doc_dict[source]
            docID = doc_sent_id.split('\t')[0]
            sentID = doc_sent_id.split('\t')[1]
            docType = doc_sent_id.split('\t')[2]
        else:
            print i
            print source
            print target
            print "sentence not found"
            print ""
        if docType != "hl":
            sureAlignments = alignment
            try:
                csv_writer.writerow([source, target, sureAlignments, possAlignments, sourceHighlights, targetHighlights, docID, sentID, jaccardDist, docType])
            except:
                pass

if __name__ == "__main__":
    main()



