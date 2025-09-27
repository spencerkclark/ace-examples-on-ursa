# Training and inference examples with the Ai2 Climate Emulator on Ursa

This repository contains example configurations and scripts for training and running
inference with the [Ai2 Climate Emulator](https://github.com/ai2cm/ace) on NOAA's
Ursa computer. It includes a configuration for training a model on ERA5
reanalysis like that described in
[Watt-Meyer et al. (2025)](https://www.nature.com/articles/s41612-025-01090-0)
and included in the [`ace2-paper` repository](https://github.com/ai2cm/ace2-paper)
accompanying it. All data referenced in the configuration files is public and stored
in a directory with open permissions on Ursa's scratch filesystem.

## Installation

Installation assumes you have `conda` installed and in your search path. To install
the necessary software, clone this repository and run:
```
$ git clone
$ cd ace-examples-on-ursa
$ make install
```
This will create a conda environment named `fme` with all the necessary
dependencies installed. If you would like to give the environment a different
name you can use:
```
$ ENVIORNMENT_NAME=my-environment-name make install
```

## Examples

Examples are included for training, inference, and evaluation. These can be
done by running the `submit-train.sh`, `submit-inference.sh`, and
`submit-evaluator.sh` scripts with appropriate modification of their
parameters. Note that you will likely need to modify the SLURM account
referenced within the scripts in the `sbatch-scripts` directory to one
you have permission to run with to be able to run these examples successfully.

## Documentation

For documentation describing the full details around configuring and running
ACE, see [https://ai2-climate-emulator.readthedocs.io/en/latest/](https://ai2-climate-emulator.readthedocs.io/en/latest/).
