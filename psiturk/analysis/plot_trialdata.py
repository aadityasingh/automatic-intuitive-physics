import argparse
import json
import numpy as np
import pandas as pd
from scipy.stats import zscore
from math import sqrt, floor

from fileFuncs import ff
from BlenderStimuli import ramp_shape as shape
from psiturk.analysis import turktable

from mpl_toolkits.mplot3d import Axes3D
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import matplotlib.gridspec as gridspec
import matplotlib.colors as cc



# Performs 2D histogram 
def histogram(data, bins):
	mins = np.min(data[:, :-1], axis=0)
	maxes = np.max(data[:, :-1], axis=0)
	xs = np.linspace(mins[0], maxes[0], num = bins)
	ys = np.linspace(mins[1], maxes[1], num = bins)

	grid = np.zeros((bins, bins))
	counts = np.zeros((bins, bins))

	for x, y, rating in data:
		g_x = np.where(np.isclose(x, xs))[0][0] 
		g_y = np.where(np.isclose(y, ys))[0][0]
		grid[g_x, g_y] +=  rating
		counts[g_x, g_y] += 1

	grid = grid / counts

	return grid, [mins[0], maxes[0], mins[1], maxes[1]]


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

	# cm = plt.get_cmap('gist_rainbow')

	for dim in turktable.Bs:

		table_fig = plt.figure(figsize=(12, 12))
		outer = gridspec.GridSpec(3, 3, wspace=0.2, hspace=0.2)

		categories = table[dim]
		num_cats = len(categories)

		print(dim)
		
		for c_i, cat in enumerate(turktable.Categories):

			print(cat)

			cat_data = categories[cat]
			inner = gridspec.GridSpecFromSubplotSpec(1, 1,
            	subplot_spec=outer[c_i], wspace=0.6, hspace=0.4)

			cat_plot = plt.Subplot(table_fig, inner[0])
			cat_plot.set_title(cat)
			
			datas = []
			for subject in cat_data:
				data = cat_data[subject]
				datas.append(data)

			all_data = np.vstack(datas)
			hm, extent = histogram(all_data, 5)
			cat_plot.set_aspect('equal')
			# cat_plot.imshow(hm, norm = cc.NoNorm(), extent = extent, cmap=cm.coolwarm, origin = 'lower', aspect='auto')
			cat_plot.imshow(hm, extent = extent, cmap=cm.coolwarm, origin = 'lower', aspect='auto')

			
			table_fig.add_subplot(cat_plot)

		outer.tight_layout(table_fig)
		table_fig.savefig(ff.join(out, "{0!s}_summary.png".format(dim)),bbox_inches='tight')



if __name__ == '__main__':
	main()