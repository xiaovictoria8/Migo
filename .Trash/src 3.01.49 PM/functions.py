from nltk.stem.wordnet import WordNetLemmatizer
import re

""" Returns Jaccard distance of two string inputs """
def get_jaccard_dist(target_sent, source_sent):
    
    #create list of words present in both strings
    target_words = re.findall("[\w]+|[.,!?;()-]|'[\w]+", target_sent)
    source_words = re.findall("[\w]+|[.,!?;()-]|'[\w]+", source_sent)
    
    #lemmatize all words in both sets
    lmtzr = WordNetLemmatizer()
    target_words = [lmtzr.lemmatize(word) for word in target_words]
    source_words = [lmtzr.lemmatize(word) for word in source_words]
    
    #convert to set and calculate jaccard dist
    target_set = set(target_words)
    source_set = set(source_words)
    
    intersection = len(target_set & source_set)
    union = len(target_set | source_set)
    if union != 0:
      return 1.0 - float(intersection)/union
    else:
      return 1


"""Takes in set of sure alignments a_sure and all control alignments b_all and returns the precision of a"""
def precision(a_sure, b_all):
    if len(a_sure) == 0:
        return 0
    intersect_len = len(a_sure & b_all)
    return float(intersect_len) / len(a_sure)
    
"""Takes in a set of all alignments a_all and sure control alignments b_sure and returns the recall of a"""
def recall(a_all, b_sure):
    intersect_len = len (a_all & b_sure)
    return float(intersect_len) / len(b_sure)

""" Takes in the recall and precision values, returns F1 calculation """
def f1(prec, rec):
    if prec == 0 or rec == 0:
        return 0
    return float(2 * prec * rec) / float(prec + rec)
    
"""NOTE: The following functions only consider "sure" alignments for their calculations."""
""" Takes in the set of submitted alignments (sub) and set of correct answers (ans), returns precision calculation """
def precision_sure_only(sub, ans):
    if len(sub) == 0:
        return 0
    intersect_len = len(sub & ans)
    return float(intersect_len) / len(sub)

""" Takes in the set of submitted alignments (sub) and set of correct answers (ans), returns recall calculation """
def recall_sure_only(sub, ans):
    intersect_len = len(sub & ans)
    return float(intersect_len) / len(ans)
