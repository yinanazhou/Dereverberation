## Dereverberation on Music Signals
### MUMT 501 Final Project

This project implements a block-based dereverberation algorithm proposed by [Gilbert A. Soulodre in 2010](https://www.aes.org/e-lib/browse.cfm?elib=15675) on music signals. The hyperparameter settings are explored in this project.

- `ISTFT.m` is a function that implements ISTFT using the Overlap-Add (OLA) method.
- `main.m` calls ISTFT.m and implements the dereverberation algorithm.
- `audio` folder contains all the audio examples used in this project. The audio used in this project is downloaded from [Open AIR Library](https://www.openairlib.net/) by University of York.
- `figure` folder contains all the figures in the report.
