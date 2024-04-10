#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Sun Apr 07 20:05:00 UTC 2024
# SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xsim tb_CYBERcobra_behav -key {Behavioral:sim_1:Functional:tb_CYBERcobra} -tclbatch tb_CYBERcobra.tcl -log simulate.log"
xsim tb_CYBERcobra_behav -key {Behavioral:sim_1:Functional:tb_CYBERcobra} -tclbatch tb_CYBERcobra.tcl -log simulate.log
