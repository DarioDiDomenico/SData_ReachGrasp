<h1 align="center">
  Reach & Grasp
</h1>

<p align="center"><img src="https://github.com/DarioDiDomenico/Reach-Grasp/blob/main/assets/movement.gif" alt="" /></p>

## Description

This is the repository associated to the dataset Reach&Grasp presented in the publication [Reach&Grasp](INSERT_URL).

The dataset is hosted in the [IIT Dataverse](https://dataverse.iit.it/) and it is identified by the following [![DOI:10.48557/L6OWMM](https://img.shields.io/badge/DOI-10.48557/L6OWMM-0a7bbc.svg)](https://doi.org/10.48557/L6OWMM).

The dataset contains data acquired from 4 different devices, aiming at measuring huge information from the movements of the whole upper limb. The data includes electromyographic signals (bipolar and high-density EMG), kinematic signals (upper limb and fingers) and tactile infromation. During the experiments the subject was asked to perform both simple and complex tasks.
Moreover, the organzation of the folders structure and file naming follows the [BIDS](https://bids.neuroimaging.io/) standard.

Specifically, the dataset contains for each subject folder, three different subfolders namely `emg`, `motion` and `tactile`.
Within the `emg` folder there are different types of file: 
- `*_channels.tsv` : a ***tsv*** file containing informations about the acquired emg-channels (i.e., name, type, unit of measure, sampling frequency);
- `*_emg.csv` : a ***csv*** file containing the emg-data;
- `*_emg.json` : a ***json*** file containing all the descriptions related to the acquisition system and the specific performed task.
The acquisition of emg-data has been performed with two different systems: [Cometa](https://www.cometasystems.com/) and [Sesssantaquattro](https://www.otbioelettronica.it/prodotti/hardware/sessantaquattro) it has been specified in the file naming (i.e., acq-cometa, acq-sessantaquattro).

Within the `motion` folder there are different types of file:
- `*_channels.tsv` : a ***tsv*** file containing all the informations about the acquired human joints (i.e., name, type, units, sampling_frequency, tracked_point, component);
- `*_motion.csv` : a ***csv*** file containing the kinematic-data of each acquired joint;
- `*_motion.json` : a ***json*** file containing all the descriptions related to the acquisition system and the specific performed task.


Within the `tactile` folder there are different types of file:
- `*_channels.tsv` : a ***tsv*** file containing all the informations about the acquired taxels on the glove (i.e., name, type, units, sampling_frequency);
- `*_tactile.csv` : a ***csv*** file containing the tactile-data of each acquired taxel;
- `*_tactile.json` : a ***json*** file containing all the descriptions related to the acquisition system and the specific performed task.

## How to download the dataset

<img src="https://github.com/DarioDiDomenico/Reach-Grasp/blob/main/assets/linux.png" width="40" height="40"> **Linux system**

In order to download the dataset `curl` and `jq` are required.
Navigate into the directory where you cloned this repo and download the dataset using:
```console
bash tools/download/download_dataset.sh
```
<img src="https://github.com/DarioDiDomenico/Reach-Grasp/blob/main/assets/windows.png" width="40" height="40"> **Windows system**

In order to download the dataset `jq` is required.
Please follow [these](https://github.com/DarioDiDomenico/Reach-Grasp/issues/1#issue-1863330666) instructions to set up `jq` in Windows.
As soon as `jq` is setup, navigate into the directory where you cloned this repo and download the dataset using:
```console
cd tools\download
.\download_dataset.sh
```

## How to access data

We provide [Matlab](https://github.com/DarioDiDomenico/Reach-Grasp/tree/1c675ea611cc46e4682ba93d0f1808af694f1165/code) code to access the information contained in the dataset and to generate figures contained in the Dataset article.

## Citing Reach&Grasp

If you find the Reach&Grasp dataset useful, please consider citing the associated publication:

<!-- ```bibtex
@ARTICLE{9568706,
author={Piga, Nicola A. and Onyshchuk, Yuriy and Pasquale, Giulia and Pattacini, Ugo and Natale, Lorenzo},
journal={IEEE Robotics and Automation Letters},
title={ROFT: Real-Time Optical Flow-Aided 6D Object Pose and Velocity Tracking},
year={2022},
volume={7},
number={1},
pages={159-166},
doi={10.1109/LRA.2021.3119379}
}
``` -->

and the Dataset:

<!-- ```bibtex
@data{G2QJDM_2022,
author = {Piga, Nicola A. and Onyshchuk, Yuriy and Pasquale, Giulia and Pattacini, Ugo and Natale, Lorenzo},
publisher = {IIT Dataverse},
title = {{Fast-YCB Dataset}},
year = {2022},
version = {V1},
doi = {10.48557/G2QJDM},
url = {https://doi.org/10.48557/G2QJDM}
}
``` -->

## Maintainer

This repository is maintained by:

[<img src="https://github.com/dariodidomenico.png" width="40">](https://github.com/DarioDiDomenico) [@dariodidomenico](https://github.com/DarioDiDomenico)
