# HEV_BASHer
A BASH script to generate HEV consensus sequences.

## Overview
This pipeline has been made specifically to work with Nanopore HEV sequencing at the RIE and would need modification before anyone else could use it. It has been designed for use with the ARTIC HEV scheme, but there is no reason it wouldn't work with other amplicon based approaches after changing expected read lengths and trimming amounts. A significant chunk of the consensus building section has been reproduced from the old fieldbioinformatics pipeline (https://github.com/artic-network/fieldbioinformatics) so it's recommended to run it in an environment where you can run that successfully. The script also requires [ampli_clean](https://github.com/Desperate-Dan/ampli_clean), [porechop](https://github.com/rrwick/Porechop), [chopper](https://github.com/wdecoster/chopper) and [maskara](https://github.com/Desperate-Dan/maskara) to be callable.
