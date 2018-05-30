
---
title: 'ShinySSD: Species Sensitivity Distributions for Ecotoxicological Risk Assessment'
tags:
  - R
  - ecotoxicological risk assessment
  - shiny app
  - toxicology
  - environmental managment
authors:
  - name: María Florencia D’Andrea
    orcid: 0000-0002-0041-097X
    affiliation: 1,2
  - name: Julie Céline Brodeur
    orcid: 0000-0001-5408-6645
    affiliation: 1,2

affiliations:
 - name: Consejo de Investigaciones Científicas y Técnicas (CONICET)
   index: 1
 - name: Instituto Nacional de Tecnología Agropecuaria (INTA)
   index: 2

date: May 29, 2018
bibliography: references.bib

---

# Summary

Living organisms have different sensitivities to toxicants. This variability can be represented by constructing a species sensitivity distribution (SSD) curve, whereby the toxicity of a substance to a group of species is described by a statistical distribution. Building the SSD curve allows calculating the Hazard Concentration HC5, that is, the concentration at which 5% of the considered species are affected. The HC5 is widely used as an environmental quality criterion and a tool for ecological risk assessment.

The **ShinySSD** web application is a versatile and easy to use tool that serves to simultaneously model the SSD curve of a user-defined toxicity dataset based on four different statistical distribution models (log-normal, log-logistic, Weibull, Pareto).  ShinySSD directly calculates  the HC5 associated to the four distribution models together with its confidence intervals, allowing the user to select the statistical distribution and associated HC5 values that best adjust the dataset. 

The level of confidence of the results obtained from a SSD curve will depend on the number of species used to produce the SSD. In this sense, the first tab of the user interface is used for visualizing the number of species for which toxicological data are available for each toxicant , species group and endpoint combination in the uploaded dataset. A minimum of species is necessary to build a SSD curve varies according to the literature (cita).

After selecting the toxicant and species groups, the user can filter and select subsets of data from the whole database by applying different quality criteria, (e.g., if the studies reported a chemical confirmation of the concentrations of the toxicant tested). The values entered in each column of the database serve as categories to filter the database in relation to characteristics of the bioassays. The final SSD curve is fitted to different distributions using the package fitdistrplus and actuar. The HC5 is estimated by the distribution presenting the best goodness of fit.

By facilitating and streamlining toxicity data analysis and the creation of SSD curves, the user interface proposed here should be useful for environmental managers and regulators conducting ecological risk assessments and scientific research.

# Information for the Users

- ShinySSD includes a preloaded database with some toxicological data of the pesticides Cypermethrin and Glyphosate for aquatic animals extracted from ECOTOX database from the Environmental Agency of the United States (EPA). An external separated by commas file (.csv) could be uploaded by the user filling the template .csv file attached in the repo. 

- This app includes the option of download the relevant results as a .docx report.

- ShinySSD can be run from R using the following code:

``library(shiny)
shiny::runGitHub("paper", "flor14", subdir = "ShinySSD")``

The source code for ``shinySSD`` has been archived to Zenodo with the linked DOI: [@zenodo]

# Acknowledgements

We wish to thank the R comunity and R-Ladies for their help and support.
 
# References








