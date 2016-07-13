import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import sys
 
def main():
    
    # read file
    averages_data = pd.read_csv(sys.argv[1])
    
    qual_types = averages_data["qual_type"]
    print qual_types
     
     
if __name__ == "__main__":
    main()