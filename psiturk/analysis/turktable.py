import json
import numpy as np
import pandas as pd
from scipy.stats import zscore, pearsonr

from fileFuncs import ff
from BlenderStimuli import ramp_shape as shape




As = ["Shape", "Material"]
Bs = ["Density", "Friction"]

Categories = ["{0!s}-{1!s}".format(a,b) for b in shape.materials 
	for a in shape.materials]

# These serve as the keys for the dataset
# Each category will contain the responses of each subject for that category

def create_categories(t):
	ds = {k : {sub : t() for sub in Categories} for k in Bs}
	return ds

# For each subject, parse their responses into each category
# source 	: 	Path to stimuli jsons
# subject_responses : List of subject response files

def populate_categories(source, subject_responses):
	table = create_categories(dict)
	sources = create_sources(source)

	for i, subject in enumerate(subject_responses):
		subj_cats = create_subject(sources, subject)

		# category
		for cat in subj_cats:
			# sub category
			for sub in subj_cats[cat]:
				# update subcategory in the table with subject response
				sub_key = "{0:d}".format(i)
				prev = table[cat][sub]
				new = prev.update({sub_key : subj_cats[cat][sub]})
				table[cat][sub] = prev

	return table

# For each possible stimulus, load its parameters
def create_sources(path):
	sources = ff.find(path, "*.json")
	d = {}
	for source in sources:
		name = ff.fileBase(source)
		parameters = extract(source)
		d.update({name : parameters})
	return d

# For each subject, load their ratings for each stimulus
# and use the extracted sources to obtain the parameter ratings pair
def create_subject(sources, file):
	
	subj_table = create_categories(lambda : np.array([])) #create_categories(list)  
	stims_ratings = load_trial(file)

	for index, stim, rating in stims_ratings:
		trial = sources[stim]
		
		for cat in Bs:
			# skip trials that are set to mean
			if not (cat == "Friction") and (index % 2 == 0):
				continue
			elif not (cat == "Density") and (index % 2 == 1):
				continue
			sub_cat, param = trial[cat]
			prev = subj_table[cat][sub_cat]
			if prev.size == 0:
				new = np.asarray([[*param, rating]])
			else:
				new = np.append(prev, [[*param, rating]], axis=0)
			
			subj_table[cat][sub_cat] = new
			
	return subj_table

def load_trial(file):

	src = pd.read_csv(file, names = ["WID","Stimulus","NatRating","RT"])
	stims = [ff.fileBase(s) for s in src.Stimulus[1:]]
	indeces = list(map( lambda x: int(x.split("_")[-1]) , stims))
	ratings = list(map(int, src.NatRating[1:]))
	zscored = list(zscore(ratings))
	return zip(indeces, stims, zscored)


def read_json(file):
	with open(file, 'rU') as f:
		content = json.loads(f.read())
	return content

def extract(file):

	params = read_json(file)["Objects"]
	f = lambda x, y : params[x][y]
	material = lambda x : shape.materials[f(x, "Material")]
	# shape = lambda x : shape.shapes[f(x, "Shape")]
	key = "{0!s}-{1!s}".format(material("A"), material("B"))

	d = {}

	for cat in Bs:
		data = (f("A", cat), f("B", cat))
		d.update({ cat : (key , data) })

	return d