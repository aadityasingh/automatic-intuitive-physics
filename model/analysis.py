import matplotlib.pyplot as plt
import random
import statistics

class Utils:
	SURFACES = ["Foam", "Wood", "Plate"]
	SURFACES_INDEX = {"Foam": 0, "Wood": 1, "Plate": 2}
	SHAPES = ["Cube", "Cyl", "Sphere"]
	TRIAL_LENGTH = 42
	COLORS = ['r', 'g', 'b']

	def random(center, length):
		retval = [center]*length
		for i in range(length):
			retval[i] += random.random()*0.5-0.25
		return retval

class Trial:
	def __init__(self, surface, shape, sound, loudness):
		if surface in Utils.SURFACES:
			self.surface = surface
		if shape in Utils.SHAPES:
			self.shape = shape
		if sound in Utils.SURFACES:
			self.sound = sound
		self.loudness = loudness
		self.trick = (self.sound != self.surface)

class SubjectData:
	def __init__(self, triallist):
		self.raw_trials = triallist
		self.standard = dict()
		self.mean = dict()
		self.std = dict()
		self.tricks = dict()
		for sound in Utils.SURFACES:
			self.standard[sound] = []
			self.tricks[sound] = dict()
		for trial in self.raw_trials:
			if not trial.trick:
				self.standard[trial.sound].append(trial.loudness)
			else:
				self.tricks[trial.sound][trial.surface] = trial.loudness
		for sound in Utils.SURFACES:
			self.mean[sound] = statistics.mean(self.standard[sound])
			self.std[sound] = statistics.stdev(self.standard[sound])

class ExperimentData:
	def __init__(self, subjectlist):
		self.raw_subjects = subjectlist
		self.num_subjects = len(subjectlist)

	def plot_normalized_points(self):
		fig, axes = plt.subplots(self.num_subjects, 1, sharex=True, sharey=True)
		plt.setp(axes, xlim=(-3, 3), ylim=(-1, 3), yticks=[0, 1, 2], yticklabels=Utils.SURFACES, ylabel="Audio")
		for i in range(self.num_subjects):
			for j in range(len(Utils.SURFACES)):
				sound = Utils.SURFACES[j]
				ratings = self.raw_subjects[i].standard[sound]
				axes[i].plot(list(map(lambda x: (x-self.raw_subjects[i].mean[sound])/self.raw_subjects[i].std[sound], ratings)), [j]*len(ratings), Utils.COLORS[j]+'o', alpha=0.5)
				for k in range(len(Utils.SURFACES)):
					if k != j:
						sound = Utils.SURFACES[j]
						val = (self.raw_subjects[i].tricks[sound][Utils.SURFACES[k]]-self.raw_subjects[i].mean[sound])/self.raw_subjects[i].std[sound]
						axes[i].plot(val, j, Utils.COLORS[k]+'o', alpha=0.5)
			# axes[i].scatter(pca_latent[:, i], categories, c=[color[i] for i in categories])
		plt.show()

	def hist_normalized(self):
		fig, axes = plt.subplots(3, 1, sharex=True, sharey=True)
		plt.setp(axes, xlim=(-3, 3), ylim=(0, 30))
		for j in range(len(Utils.SURFACES)):
			sound = Utils.SURFACES[j]
			values = []
			tricks = [[],[],[]]
			for i in range(self.num_subjects):
				ratings = self.raw_subjects[i].standard[sound]
				normalized_ratings = list(map(lambda x: (x-self.raw_subjects[i].mean[sound])/self.raw_subjects[i].std[sound], ratings))
				values.extend(normalized_ratings)
				# axes[i].plot(list(map(lambda x: (x-self.raw_subjects[i].mean[sound])/self.raw_subjects[i].std[sound], ratings)), [j]*len(ratings), Utils.COLORS[j]+'o', alpha=0.5)
				for k in range(len(Utils.SURFACES)):
					if k != j:
						sound = Utils.SURFACES[j]
						val = (self.raw_subjects[i].tricks[sound][Utils.SURFACES[k]]-self.raw_subjects[i].mean[sound])/self.raw_subjects[i].std[sound]
						tricks[k].append(val)
						# axes[j].plot(val, 10, Utils.COLORS[k]+'o', alpha=0.5)
			axes[j].hist(values, bins=20,color=Utils.COLORS[j], alpha=0.5)
			for k in range(len(Utils.SURFACES)):
				if k != j:
					axes[j].hist(tricks[k], bins=20, color=Utils.COLORS[k], alpha=0.5)
			axes[j].set_ylabel(sound)
			# axes[i].scatter(pca_latent[:, i], categories, c=[color[i] for i in categories])
		axes[-1].set_xlabel("Z score")
		plt.show()

	def plot(self):
		fig, axes = plt.subplots(self.num_subjects, 1, sharex=True, sharey=True)
		plt.setp(axes, xlim=(0, 100), ylim=(-1, 3), yticks=[0, 1, 2], yticklabels=Utils.SURFACES)
		for i in range(self.num_subjects):
			for j in range(len(Utils.SURFACES)):
				sound = Utils.SURFACES[j]
				ratings = self.raw_subjects[i].standard[sound]
				axes[i].plot(ratings, [j]*len(ratings), Utils.COLORS[j]+'o', alpha=0.5)
				for k in range(len(Utils.SURFACES)):
					if k != j:
						axes[i].plot(self.raw_subjects[i].tricks[Utils.SURFACES[j]][Utils.SURFACES[k]], j, Utils.COLORS[k]+'o', alpha=0.5)
			# axes[i].scatter(pca_latent[:, i], categories, c=[color[i] for i in categories])
		axes[-1].set_xlabel("Loudness Judgement")
		axes[self.num_subjects//2].set_ylabel("Audio")
		plt.show()


def parse(filename):
	data_lines = open(filename).readlines()
	retval = dict()
	for line in data_lines:
		vals = line.split(",")
		if ' ""IsInstruction"": false' in vals:
			rating = int(vals[3].split('""')[3])
			vidname = vals[5].split('""')[3][0:-5]
			pieces = vidname.split('Dubbed')
			sound = pieces[1]
			shape, surface = pieces[0][0:-1].split('On')
			retval.setdefault(vals[0], []).append(Trial(surface, shape, sound, rating))
	return retval

subject_trials = parse('data.csv')
subjects_data = []
for person in subject_trials:
	subjects_data.append(SubjectData(subject_trials[person]))

expdata = ExperimentData(subjects_data)
# expdata.hist_normalized()
expdata.plot()
