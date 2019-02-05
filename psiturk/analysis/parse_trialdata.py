import pandas as pd
import json
import argparse
import numpy as np

from fileFuncs import ff



def main():


	parser = argparse.ArgumentParser(
		description = "Parses a trialdata.csv")

	parser.add_argument("source", type = str,
		help = "Path to trail data")

	parser.add_argument("out", type = str,
		help = "Path to save parsed output")

	args = parser.parse_args()

	ff.ensureDir(args.out)
	out_s = ff.join(args.out, "parsed_{0!s}.txt")

	raw_dat = pd.read_csv(args.source, names=["WID","Index","TimeStamp","Data"])

	subjs = np.unique(raw_dat.WID)

	for subj in subjs:

		out = out_s.format(subj)
		data = raw_dat.Data[np.where(subj == raw_dat.WID)[0]]

		with open(out,'w') as ofl:
		    ofl.write("WID,Stimulus,NatRating,RT\n")
		    for datum in data:
		        pdat = json.loads(datum)
		        if type(pdat) != dict:
		            ofl.write(subj+','+pdat[0]+','+str(pdat[1])+','+str(pdat[2])+'\n')
		


	


if __name__ == '__main__':
	main()
    
