<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/banda.png" width="1000">
---
# *shinyssd v1.0*: Species Sensitivity Distributions for Ecotoxicological Risk Assessment  
---
D'Andrea, MF; Brodeur, JC

## Summary

Living organisms have different sensitivities to toxicants. This variability can be represented by constructing a species sensitivity distribution (SSD) curve, whereby the toxicity of a substance to a group of species is described by a statistical distribution. Building the SSD curve allows calculating the Hazard Concentration HC5, that is, the concentration at which 5% of the considered species are affected. The HC5 is widely used as an environmental quality criterion and a tool for ecological risk assessment (@posthuma2001).

The **ShinySSD** web application is a versatile and easy to use tool that serves to simultaneously model the SSD curve of a user-defined toxicity dataset based on four different statistical distribution models (log-normal, log-logistic, Weibull, Pareto).  ShinySSD directly calculates three estimators HC1, HC5 and HC10 associated to the four distribution models together with its confidence intervals, allowing the user to select the statistical distribution and associated HC values that best adjust the dataset. 

The level of confidence of the results obtained from a SSD curve will depend on the number of species used to produce the SSD. In this sense, the first tab of the user interface is used for visualizing the number of species for which toxicological data are available for each toxicant , species group and endpoint combination in the uploaded dataset. A minimum of species is necessary to build a SSD curve varies according to the literature (@belanger2016, @efsa2013, @wheeler2002, @newman2000).

After selecting the toxicant and species groups, the user can filter and select subsets of data from the whole database by applying different quality criteria, (e.g., if the studies reported a chemical confirmation of the concentrations of the toxicant tested). The values entered in each column of the database serve as categories to filter the database in relation to characteristics of the bioassays. The final SSD curve is fitted to different distributions using the package fitdistrplus and actuar. The HC is estimated for all the distributions.

By facilitating and streamlining toxicity data analysis and the creation of SSD curves, the user interface proposed here should be useful for environmental managers and regulators conducting ecological risk assessments and scientific research.

## Information for Users

- ShinySSD includes a preloaded database with aquatic toxicological data for the pesticides Cypermethrin and Glyphosate. This data was extracted of the ECOTOX database of the Environmental Agency of the United States (EPA) [link](https://cfpub.epa.gov/ecotox/). An external separated by commas file (.csv) could be uploaded by the user according to the format of the ``template.csv`` file attached in the repo. 

- There is a warning alert message if you are entering data with different units, to avoid conflictive results.

- ShinySSD includes the option of download the relevant results as a .docx report.

- ShinySSD is optimized for browser use.

- The app can be run from R using the following code:

``` 
library(devtools)
devtools::install_github("flor14/shinyssd", subdir = "shinyssd")
library(shinyssd)
shinyssd::shinyssd_run()
```

The source code for ``shinySSD`` has been archived to Zenodo with the linked DOI:10.5281/zenodo.1470880

## Community guidelines

Report Issues:

- Questions, feedback, bug reports: please open an issue in the issue tracker of the project [here](https://github.com/flor14/shinyssd/issues).

Contribution to the software:

- Please open an issue in the issue tracker of the project that describes the changes you would like to make to the software and open a pull request with the changes. The description of the pull request must references the corresponding issue.

## Acknowledgements

We wish to thank the R community and R-Ladies or their help and support.
 
## How to use shinyssd? 

1 - The user can load their own database in .csv format

2 - The application emphasizes checking units of toxicological data

3 - Once loaded, the database is displayed in this tab

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/imagen_shiny.png" width="500">

4 -The second tab allows to visualize the groups of species for which toxicological data are available per substance in the database.

5 -The amount of data in the database in each case is important since there is a minimum number of data to construct a valid SSD curve.

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/imagen_shiny2.png" width="500">

6 - After selecting the substance to be studied and the groups of species, the user can filter and select subsets of data by applying different criterias (for example, if the analytical validation of the concentrations of the substance evaluated in those trials was reported. toxicological).

7 - The final SSD curve adjusts to different distributions using the fitdistrplus packages and actuar. The HC5 is estimated by the distribution that presents the best goodness of fit.

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/imagen_shiny3.png" width="500">

8 - It allows you to download a report generated with RMarkdown in .docx format with all the selected inputs and their corresponding outputs

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/imagen_shiny4.png" width="500">)

<img src="https://github.com/flor14/shinyssd/blob/master/shinyssd/banda.png" width="1000">
