<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/banda.png" width="1000">

---
# *shinySSD v1.0*: Species Sensitivity Distributions for Ecotoxicological Risk Assessment  
---
D'Andrea, MF; Brodeur, JC

## Summary

Living organisms have different sensitivities to toxicants. This variability can be represented by constructing a species sensitivity distribution (SSD) curve, whereby the toxicity of a substance to a group of species is described by a statistical distribution. Building the SSD curve allows calculating the Hazard Concentration 5% (HC<sub>5</sub>), that is, the concentration at which 5% of the considered species are affected. The HC<sub>5</sub> is widely used as an environmental quality criterion and a tool for ecological risk assessment (@posthuma2001).

The ``shinyssd`` web application is a versatile and easy to use tool that serves to simultaneously model the SSD curve of a user-defined toxicity dataset based on four different statistical distribution models (log-normal, log-logistic, Weibull, Pareto).  ``shinyssd`` directly calculates three estimators HC<sub>1</sub>, HC<sub>5</sub> and HC<sub>10</sub> associated to the four distribution models together with its confidence intervals, allowing the user to select the statistical distribution and associated HC values that best adjust the dataset. 

The level of confidence of the results obtained from a SSD curve will depend on the number of species used to produce the SSD. In this sense, the first tab of the user interface is used for visualizing the number of species for which toxicological data are available for each toxicant , species group and endpoint combination in the uploaded dataset. A minimum of species is necessary to build a SSD curve varies according to the literature (@belanger2016, @efsa2013, @wheeler2002, @newman2000).

After selecting the toxicant and species groups, the user can filter and select subsets of data from the whole database by applying different quality criteria, (e.g., if the studies reported a chemical confirmation of the concentrations of the toxicant tested). The values entered in each column of the database serve as categories to filter the database in relation to characteristics of the bioassays. The final SSD curve is fitted to different distributions using the package fitdistrplus and actuar. The HC is estimated for all the distributions.

By facilitating and streamlining toxicity data analysis and the creation of SSD curves, the user interface proposed here should be useful for environmental managers and regulators conducting ecological risk assessments and scientific research.

## Information for Users

- ``shinyssd`` includes a preloaded database with aquatic toxicological data for the pesticides Cypermethrin and Glyphosate. This data was extracted of the ECOTOX database of the Environmental Agency of the United States (EPA) [link](https://cfpub.epa.gov/ecotox/). An external separated by commas file (.csv) could be uploaded by the user according to the format of the ``template.csv`` file attached in the repo. 

- There is a warning alert message if you are entering data with different units, to avoid conflictive results.

- ``shinyssd`` includes the option of download the relevant results as a .docx report.

- ``shinyssd`` is optimized for browser use.

- The app can be run from R using the following code:

``` 
library(devtools)
devtools::install_github("flor14/shinyssd", subdir = "shinyssd")
library(shinyssd)
shinyssd::shinyssd_run()
```

The source code for ``shinyssd`` has been archived to Zenodo with the linked DOI:10.5281/zenodo.3233033

## Community guidelines

Report Issues:

- Questions, feedback, bug reports: please open an issue in the issue tracker of the project [here](https://github.com/flor14/shinyssd/issues).

Contribution to the software:

- Please open an issue in the issue tracker of the project that describes the changes you would like to make to the software and open a pull request with the changes. The description of the pull request must references the corresponding issue.

## Acknowledgements

We wish to thank Ana Laura Diedrichs and R-Ladies or their help and support.
 
## How to use ``shinyssd``? 

1 - The user can upload their own database in .csv format according to the template.csv file found in this same repository

2 - Shinyssd checks that the units are homogeneous

3 - Once loaded, the database is displayed

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/imagen_shiny.png" width="500">

4 - The "Visualization" tab allows you to see how many species have enough data to estimate the SSD for a selected toxic substance.

5 -There are minimum requirements for the amount of data to build a valid SSD curve. The colors indicate different criteria within the bibliography.

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/imagen_shiny2.png" width="500">

6 - After selecting the substance to be studied and the groups of species, the user can filter and select subsets of data by applying different criterias (for example, if the analytical validation of the concentrations of the substance evaluated in those trials was reported).

7 - The SSD curve is adjusted to different distributions according to the previously selected data. The HC1, HC5 and HC10 are estimated from the distribution that presents the best goodness of fit.

8 - Shinyssd allows you to download a report in .docx format with the data selection and the results obtained.

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/imagen_shiny3.png" width="500">

9 - In the tab "HC<sub>5</sub> and Plot" you can identify each of the SSD species and obtain the values of HC1, HC5 and HC10 with their confidence intervals.

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/imagen_shiny4.png" width="500">)

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/banda.png" width="1000">
