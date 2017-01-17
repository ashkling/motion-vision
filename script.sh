#!/bin/bash
#
#***
#*** "#SBATCH" lines must come before any non-blank, non-comment lines ***
#***
#
# 1 nodes, 1 CPUs per node (total 6 CPUs), wall clock time of 5 hours
#
#SBATCH -N 2                  ## Node count
#SBATCH --gres=gpu:1 --ntasks-per-node=1 -N 2   ## Processors per node
#SBATCH -t 5:00:00            ## Walltime
#SBATCH --mem 30000
#
# send mail if the process fails
#SBATCH --mail-type=fail
# Remember to set your email address here instead of nobody
#SBATCH --mail-user=ajthomas@cs.princeton.edu
#

matlab -nodisplay < action_cnn.m
