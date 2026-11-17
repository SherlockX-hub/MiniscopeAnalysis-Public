# MiniscopeAnalysis-Public  
Miniscope data analysis code adapted from [MiniscopeAnalysis](https://github.com/etterguillaume/MiniscopeAnalysis). Please download that package and add to the MATLAB Path before running. Compatible with Miniscope-DAQ-QT-Software v1_11 or v2_0 and Miniscope V3/V4.  

Replace the following files in the dependency packages with the corrected versions in the `correctedFiles` folder:

| File | Location to replace |
|------|---------------------|
| `read_file.m` | `NoRMCorre/` |
| `get_data_dimension.m` | `CNMF_E-master/ca_source_extraction/endoscope/` |
| `smod_bigread2.m` | `CNMF_E-master/ca_source_extraction/utilities/` |