# SpikeDetection-Toolbox
This is a MATLAB based spike detection toolbox for extracellular recordings. 

This toolbox is designed to detect spikes in self generated signals. 
The file *SpikeDetectionDemo.m* shows the precision of the implemented algorithms as an demonstration. It also contains parameter to change the form of the generated signals. 

The other folders have different content: 
In "*Data*" You can find the function for the signal generation, data for the filter and the spikes which are used. 
"*Algorithmen*" contains all spike detection algorithms used in this toolbox. For further data, necessary for the algorithms, the folder "*Misc*" was created. 

To use the toolbox open the file *SpikeDetectionDemo.m* and add all folders to the MATLAB path. As soon this is done You can modify the parameters discribed in the Demo and run the script. 

As a result the detection rate *DR* and the false-positive rate *FP* is shown in the command window. 
