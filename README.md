# SpikeDetection-Toolbox
This is a MATLAB based spike detection toolbox for extracellular recordings

This toolbox is designed to detect spikes in self generated signals. Therefor it uses different spike-detection algorithms.

To start open *SpikeDetectionDemo.m*-file. This script shows the precision of the algorithms. 

Other folders contain different data: In *Algorithms* all spike detectors can be found including a short description. 
*Data* contains the function for signal generation, the used filter and the data of spikes. Further necessary data is stored in *Misc*.

To start the spike detection open the demo-file and add the other folders to the MATLAB path. In the demo file modifications can be done to change the signal form. Run the script and results are given. Those show the detection rate *DR* and false-positive rate *FP*.

November, 2016