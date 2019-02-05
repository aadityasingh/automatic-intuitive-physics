import argparse
import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf

from fileFuncs import ff
from BlenderStimuli import ramp_shape as shape
from psiturk.analysis import turktable

def from_table(table, x_0, x_1):
	key = "{0!s}-{1!s}".format(x_0, x_1)
	t_0 = lambda x : "{0!s}_{1:07.4f}".format(x_0, x)
	t_1 = lambda x : "{0!s}_{1:07.4f}".format(x_1, x)
	raw = table[key]
	t = []

	for subject in raw:
		subj_data = raw[subject]
		x_0_subs = np.asarray(list(map(t_0, subj_data[:, 0])))
		x_1_subs = np.asarray(list(map(t_1, subj_data[:, 1])))
		labels = np.repeat(np.array([subject]), len(subj_data))
		rows = np.vstack([labels, x_0_subs, x_1_subs, subj_data[:, 2]]).T
		df = pd.DataFrame(	data = rows,
							columns = ["Subject", "MatRamp", "MatGround", "Rating"])
		df = df.astype({"Subject" : str, "MatRamp" : str, "MatGround" : str, "Rating" : np.float64})

		t.append(df)

	return pd.concat(t)

def cat_data(cat_data):
	datas = []
	for subject in cat_data:
		data = cat_data[subject]
		ratings = data[:, 2]

		datas.append(data)
	return np.vstack(datas)

# Performs ND histogram 
def to_grid(data, bins):
	mins = np.min(data[:, :-1], axis=0)
	maxes = np.max(data[:, :-1], axis=0)
	xs = np.linspace(mins[0], maxes[0], num = bins)
	ys = np.linspace(mins[1], maxes[1], num = bins)

	grid = [[ [] for _ in range(bins) ] for _ in range(bins)]# np.zeros((bins, bins, depth))

	for x, y, rating in data:
		g_x = np.where(np.isclose(x, xs))[0][0] 
		g_y = np.where(np.isclose(y, ys))[0][0]
		grid[g_x][g_y].append(rating)

	return np.asarray(grid)


def main():

	parser = argparse.ArgumentParser(
		description = "Plots a collection of trial data")

	parser.add_argument("subjects", type = str,
		help = "Directory containing subject data")

	parser.add_argument("source", type = str,
		help = "Directory containing trial data")

	parser.add_argument("--out", '-o', type = str)

	args = parser.parse_args()

	if not args.out is None:
		out = args.out
	else:
		out = args.subjects

	ff.ensureDir(out)

	subject_files = ff.find(args.subjects, "*.txt")
	num_subjects = len(subject_files)

	table = turktable.populate_categories(args.source, subject_files)



	# Perform (x,y) -> (y, x) test
	mats = np.array(shape.materials)
	for dim in turktable.Bs:

		categories = table[dim]
		lines = []

		for c_0 in mats:

			# others = mats[np.where(c_0 != mats)]
			for c_1 in mats:

				sub_lines = from_table(categories, c_0, c_1)
				lines.append(sub_lines)

		df = pd.concat(lines)

		mod = smf.ols(formula=' Rating ~ C(MatRamp, Sum) + C(MatGround, Sum) ', data=df)
		res = mod.fit()
		print("\nResults for {0!s}:".format(dim))
		print(res.summary())

	# # Perform (x,y) -> (y, x) test
	# mats = np.array(shape.materials)
	# for dim in turktable.Bs:

	# 	categories = table[dim]
	# 	ramp_flags = [ [] for _ in range(5)]
	# 	floor_flags = [ [] for _ in range(5)]
	# 	dependents = [ [] for _ in range(5)]

	# 	for c_0 in mats:

	# 		others = mats[np.where(c_0 != mats)]
	# 		for c_1 in others:
	# 			# mat on ramp
	# 			ramp_key = "{0!s}-{1!s}".format(c_0, c_1)
	# 			ramp_grid = to_grid(cat_data(categories[ramp_key]), 5)
	
	# 			# mat on floor
	# 			floor_key = "{0!s}-{1!s}".format(c_1, c_0)
	# 			floor_grid = to_grid(cat_data(categories[floor_key]), 5)
				
	# 			for b in range(5):
				
	# 				ramp_d = np.hstack(ramp_grid[b, :]).flatten()
	# 				num_ramp = len(ramp_d)
				
	# 				dependents[b].append(ramp_d)
	# 				ramp_flags[b].append(np.ones(num_ramp))
	# 				floor_flags[b].append(np.zeros(num_ramp))

	# 				floor_d = np.hstack(floor_grid[:, b ]).flatten()
	# 				num_floor = len(floor_d)
	# 				dependents[b].append(floor_d)
	# 				ramp_flags[b].append(np.zeros(num_floor))
	# 				floor_flags[b].append(np.ones(num_floor))

	# 	for b in range(5):
	# 		x_0 = np.hstack(ramp_flags[b])
	# 		x_1 = np.hstack(floor_flags[b])
	# 		x = np.vstack((x_0, x_1)).T
	# 		ratings = np.hstack(dependents[b])
	# 		X = sm.add_constant(x)
	# 		results = sm.OLS(ratings, X).fit()
				
	# 		print("\nResults for {0!s} : {1!s}\n".format(dim, b))
	# 		print(results.summary())




if __name__ == '__main__':
	main()