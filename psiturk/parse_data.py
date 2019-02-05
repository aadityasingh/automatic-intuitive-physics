'''

Scrapes data from database, then parses it to anonymize and make good for analysis

'''

from __future__ import division, print_function
import os
import json
import sys
import h5py
import argparse
import numpy as np
import pandas as pd
from sqlalchemy import create_engine, MetaData, Table

import pprint

import pdb

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from Network.dataset.human_dataset import HumanDataset

DBFL = "participants.db"
EXPERIMENT_FLAGS = ["2.0"] # Allowable codeversion flags to download
TRIALDB = "ramp_experiment_single-frame_database.hdf5"
#TRFL = "trialdata.csv"
#QFL = "questiondata.csv"
TROUT = "parsed_trials.csv"
QOUT = "parsed_questions.csv"

# Mostly from http://psiturk.readthedocs.io/en/latest/retrieving.html
def read_db(db_path, codeversions):
    table_name = "hg_basic"
    data_column_name = "datastring"
    mode = "live"
    engine = create_engine("sqlite:///" + db_path)
    metadata = MetaData()
    metadata.bind = engine
    table = Table(table_name, metadata, autoload=True)
    s = table.select()
    rows = s.execute()

    rawdata = []
    statuses = [3, 4, 5, 7]
    for row in rows:
        if (row['status'] in statuses and
            row['mode'] == mode and
            row['codeversion'] in codeversions):
           rawdata.append(row[data_column_name])

    rawdata = [json.loads(part) for part in rawdata]
    conddict = {}
    for part in rawdata:
        uniqueid = part['workerId'] + ':' + part['assignmentId']
        conddict[uniqueid] = part['condition']
    data = [part['data'] for part in rawdata]

    for part in data:
        for record in part:
            record['trialdata']['uniqueid'] = record['uniqueid']
            record['trialdata']['condition'] = conddict[record['uniqueid']]

    trialdata = pd.DataFrame([record['trialdata'] for part in data for
                              record in part if
                              ('IsInstruction' in record['trialdata'] and
                               not record['trialdata']['IsInstruction'])])

    qdat = []
    for part in rawdata:
        thispart = part['questiondata']
        thispart['uniqueid'] = part['workerId'] + ':' + part['assignmentId']
        qdat.append(thispart)
    questiondata = pd.DataFrame(qdat)

    return trialdata, questiondata


def main():

    parser = argparse.ArgumentParser(description = "Parses Human Galileo data")
    parser.add_argument("dataset", type = str, help = "Path to trial dataset")

    args = parser.parse_args()

    dataset = HumanDataset(args.dataset, root='training')

    #trs = pd.read_csv(TRFL, names=['WID', 'Order', 'Time', 'Data'])
    #qs = pd.read_csv(QFL, names=['WID', 'Key', 'Value']).pivot(index='WID', columns='Key', values='Value')
    trs, qs = read_db(DBFL, EXPERIMENT_FLAGS)
    #pdb.set_trace()
    qs = qs.rename(index=str, columns={'uniqueid': 'WID'})

    """Parse out the JSON data"""
    # def doparse(dat):
    #     d = json.loads(dat)
    #     if ("phase" in d.keys()) or (d['IsInstruction']):
    #         return {
    #             'Trial': '',
    #             'LengthType': '',
    #             'Rating': None,
    #             'TrialOrder': None,
    #             'RT': None
    #         }
    #     fullname = os.path.splitext(d['TrialName'])[0]
    #     lt = fullname.split('_')[-1]
    #     tnm = ('_').join(fullname.split('_')[:-1])
    #     return {
    #         'Trial': tnm,
    #         'LengthType': lt,
    #         'Rating': d['Rating'],
    #         'TrialOrder': d['TrialOrder'],
    #         'RT': d['ReactionTime']
    #     }

    def parse_rawname(trialname):
        fullname = os.path.splitext(trialname)[0]
        lengthtype = fullname.split('_')[-1]
        tname = ('_').join(fullname.split('_')[:-1])
        return {
            'Trial': tname,
            'LengthType': lengthtype
        }

    trs = trs.merge(trs.TrialName.apply(lambda s: pd.Series(parse_rawname(s))),
                    left_index=True, right_index=True)
    trs = trs.dropna()

    trs = trs.rename(index=str, columns={'ReactionTime':'RT', 'uniqueid':'WID'})

    """Make sure we have 150 observations per participant"""
    trialsbyp = trs.WID.value_counts()
    trialsbyp = trialsbyp[trialsbyp == 150]
    good_wids = trialsbyp.index
    trs = trs[trs.WID.isin(good_wids)]

    """Assign random identifiers to each participant"""
    wid_translate = {}
    for i, wid in enumerate(good_wids):
        wid_translate[wid] = "Participant_" + str(i)

    trs["ID"] = trs.WID.apply(lambda x: wid_translate[x])

    """Parse the trial name into its types

    Mario: Fill this in!
        TrialType: in ['Control', 'Matched-Normal', 'Matched-Abnormal']
        MatchName: Make sure that the matched pairs have the same name here
    """
    def parsename(tnm):
        trial_parse = tnm.split('_')
        trial_idx = int(trial_parse[-1])

        pdb.set_trace()
        params, duration = dataset[trial_idx]

        if trial_idx < 120:
            if trial_idx % 2 == 0:
                trial_type = "Matched-Normal"
                match_type = 'Normal'
            else:
                trial_type = 'Matched-Abnormal'
                match_type = 'Normal'

            match_id = np.floor(trial_idx / 2).astype(int)
        else:
            trial_type = "Control"
            match_id = trial_idx - 60
            match_type = 'NA'

        t = {
            'TrialType': trial_type,
            'MatchName': "match-name_{0:d}".format(match_id),
            'CollisionDuration' : duration
        }

        t.update(params)
        print(tnm)
        pprint.pprint(t)
        # raise ValueError()
        return t

    trs = trs.merge(trs.Trial.apply(lambda s: pd.Series(parsename(s))),
                    left_index=True, right_index=True)

    """Clean things out and write out"""
    cl_tr = trs[["ID", "Trial", "MatchName", "TrialType",
                 "LengthType", "Rating", "RT", "TrialOrder",
                 "Material", "Shape", "Mass", "Density", "Friction",
                 'CollisionDuration',]]
    cl_tr.to_csv(TROUT, index=False)

    cl_qs = qs[qs.WID.isin(good_wids)].copy()
    cl_qs["ID"] = cl_qs.WID.apply(lambda x: wid_translate[x])
    cl_qs[["ID", "instructionloops", "strategies", "notice", "comments"]].to_csv(QOUT, index=False)

if __name__ == '__main__':
    main()
