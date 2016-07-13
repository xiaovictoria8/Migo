import json
import csv
import sys
import random
from functions import get_jaccard_dist

"""
Takes in a set of alignments from the Edinburgh corpus in JSON format.
Creates a CSV batch input for alignment hits on Mechanical Turk.

Also creates a CSV batch results file that contains results for all sentence pairs with two annotations.
The batch result displays the alignments of the annotator who was not chosen for the input HIT.
This batch results file should be used as an input to generate_worker_score_from_edinburgh.py to calculate the accuracy scores of the other annotator.


arg 1: Edinburgh JSON input file (ie. train.json)
arg 2: Alignment input file (ie. output.align) 
arg 3: output filename for the HITs batch input CSV file
arg 4: output filename for the annotator batch results file
"""

# takes in a csv_reader file and outputs a dictionary mapping docid to alignments
def make_alignment_dict(align_input):
    align_dict = {}
    for row in align_input:
        try:
            align_dict[row[0]] = row[1]
            
        except:
            pass
    
    return align_dict

# takes in an embedded list of alignments (see Edinburgh JSON documentation for formatting)
# outputs alignments in Pharoah format
def extract_alignments(align_list):
    if align_list == []:
        return "{}"
    
    align_str = ""
    for alignment in align_list:
        src = alignment[0]
        tgt_list = alignment[1]
        for tgt in tgt_list:
            align_str = align_str + str(src) + "-" + str(tgt) + " "
    
    return align_str 

# writes an entry to batch_results_writer with the appriopriate values for input and answer alignments
def print_batch_result(batch_results_writer, sure_sub, pos_sub, sure_ans, pos_ans):
    print("print_batch_result starting")
    batch_row = [None] * 49
    batch_row[15] = "Edinburgh annotator"
    batch_row[46] = sure_sub # sure submission
    batch_row[42] = pos_sub # possible submission
    batch_row[35] = sure_ans # sure answers
    batch_row[36] = pos_ans # target answers

    
    batch_results_writer.writerow(batch_row)

def main():
    #open input JSON and alignment files
    with open(sys.argv[1], 'rb') as reader:
        reader_string = reader.read()
    json_input = json.loads(reader_string)
    align_input = csv.reader(open(sys.argv[2], 'rb'), delimiter='\t')
    
    # open and set up output files
    hit_input_writer = csv.writer(open(sys.argv[3], 'wb'), delimiter = ",")
    hit_input_writer.writerow(["source", "target", "docID", "type", "sureAlignments", "possAlignments", "sourceHighlights", "targetHighlights", "answerSureAlignments1", "answerPossAlignments1", "answerSourceHighlights1", "answerTargetHighlights1"])
    batch_results_writer = csv.writer(open(sys.argv[4], 'wb'), delimiter = ",")
    batch_results_writer.writerow(["HITId","HITTypeId","Title","Description","Keywords","Reward","CreationTime","MaxAssignments","RequesterAnnotation","AssignmentDurationInSeconds","AutoApprovalDelayInSeconds","Expiration","NumberOfSimilarHITs","LifetimeInSeconds","AssignmentId","WorkerId","AssignmentStatus","AcceptTime","SubmitTime","AutoApprovalTime","ApprovalTime","RejectionTime","RequesterFeedback","WorkTimeInSeconds","LifetimeApprovalRate","Last30DaysApprovalRate","Last7DaysApprovalRate","Input.source","Input.target","Input.docID","Input.type","Input.sureAlignments","Input.possAlignments","Input.sourceHighlights","Input.targetHighlights","Input.answerSureAlignments1","Input.answerPossAlignments1","Input.answerSourceHighlights1","Input.answerTargetHighlights1","Answer.activeTime","Answer.comment","Answer.endTime","Answer.possAlignments","Answer.sourceHighlights","Answer.startTime","Answer.submit","Answer.sureAlignments","Answer.targetHighlights","Approve","Reject"])

    
    # for sentence pairs with two alignments, select which pairs should use A's alignments and which should use C's
    double_aligned_pairs = 19 # use 380 for the full set
    list_choose_a = random.sample(range(double_aligned_pairs), double_aligned_pairs / 2)
    seen_double_aligned_pairs = 0
    list_choose_a.sort()
     
    # create a dictionary of automated alignments, indexed by docID
    align_dict = make_alignment_dict(align_input)

    num_a = 0
    num_c = 0
    num_rows = 0
    # scan through each pair of paraphrases
    for pair in json_input["paraphrases"]:
        try:
            print("")
            print(num_rows)
            
            if num_rows == 30:
                break
            
            num_rows += 1
            
            # define values for each column
            source = pair["S"]["string"]
            target = pair["T"]["string"]
            docID = pair["id"]
            stype = "test"
            sure_alignments = align_dict[docID]
            poss_alignments = "{}"
            source_highlights = "{}"
            target_highlights = "{}"
            answer_source_highlights = "{}"
            answer_target_highlights = "{}"
            align_sub = None
            
            print(docID)
            print("seen_double_aligned_pairs: " + str(seen_double_aligned_pairs))
        
            # extract answer alignments
            if "A" in pair["annotations"] and "C" in pair["annotations"]:
                print("two alignments exist")
                if seen_double_aligned_pairs in list_choose_a:
                    print("randomly selected A")
                    num_a += 1
                    align_ans = pair["annotations"]["A"]
                    align_sub = pair["annotations"]["C"]
                    
                else:
                    print("randomly selected C")
                    num_c += 1
                    align_ans = pair["annotations"]["C"]
                    align_sub = pair["annotations"]["A"]
                seen_double_aligned_pairs += 1
            elif "A" in "A" in pair["annotations"]:
                print("only A exists, selected A")
                align_ans = pair["annotations"]["A"]
            else:
                print("only C exists, selected C")
                align_ans = pair["annotations"]["C"]
            
            answer_sure_alignments = extract_alignments(align_ans["S"])
            print("SURE ANSWER: " + str(answer_sure_alignments))
            answer_poss_alignments = extract_alignments(align_ans["P"])
            print("POSS ANSWER: " + str(answer_poss_alignments))
            
            # write row to CSV output
            print([source, target, docID, stype, sure_alignments, poss_alignments, source_highlights, target_highlights, answer_sure_alignments, answer_poss_alignments, answer_source_highlights, answer_target_highlights])
            hit_input_writer.writerow([source, target, docID, stype, sure_alignments, poss_alignments, source_highlights, target_highlights, answer_sure_alignments, answer_poss_alignments, answer_source_highlights, answer_target_highlights])
            
            
            # if two alignments exist, print the not chosen one to batch_results_writer
            if align_sub:
                print("two alignments existed")
                sub_sure_alignments = extract_alignments(align_sub["S"])
                print("SURE SUBMISS: " + sub_sure_alignments)
                sub_poss_alignments = extract_alignments(align_sub["P"])
                print("POSS SUBMISS: " + sub_poss_alignments)
                print_batch_result(batch_results_writer, sub_sure_alignments, sub_poss_alignments, answer_sure_alignments, answer_poss_alignments)
                
        except:
            pass

    print("num a: " + str(num_a))
    print("num c: " + str(num_c))
if __name__ == "__main__":
    main()