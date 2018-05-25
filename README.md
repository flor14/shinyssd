
---
title: ' Species Sensitivity Distributions for Ecotoxicological Risk Assessment '
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
  - name: Julie Celine Brodeur
    orcid: ¿??????
    affiliation: 1,2

affiliations:
 - name: Consejo de Investigaciones Científicas y Técnicas (CONICET)
   index: 1
 - name: Instituto Nacional de Tecnología Agropecuaria (INTA)
   index: 2

date: 27 May 2018
bibliography: references.bib
---

# Summary

Living organisms have different sensitivities to toxicants. This variability can be represented by constructing a species sensitivity distribution (SSD) curve, whereby the toxicity of a substance to a group of species is described by a statistical distribution. Building the SSD curve allows calculating the Hazard Concentration HC5, that is, the concentration at which 5% of the considered species are affected. The HC5 is widely used as an environmental quality criterion and a tool for ecological risk assessment.

The criteria of data selection  influence the amount of species available to built a SSD. After selecting the pesticide and species groups, the user can filter and select subsets of data from the whole database by applying different quality criteria, (e.g., if the studies reported a chemical confirmation of the concentrations of pesticide tested). In the first tab the user could upload their own database with several toxicological endpoints and particular properties of the correspondant assay. The categories present could be visualized, being posible to be exclude the rows of the analysis according to one or multiple categories removing the particular bioassay from which the toxicological value cames from. The final SSD curve is fitted to different distributions using the package fitdistrplus. The HC5 is estimated by the distribution presenting the best goodness of fit.

The interpretation of the results is straightforward the number of data used to produce the SSD, varying in the literatura the mínimum number of species  accepted to build the curve. That is why the second tab of the user interface is used for visualization of the number of species for which toxicological data is available for each pesticide, species group and endpoint combination in the uploaded dataset.

The first selection of parameters of the SSD allow to generate an estimate of the HC5 and its confidence intervals from the database entered. The adjustment to the distributions was made using the fitdistrplus package.

The interactivity generated using the shiny package over the database allowed the visualization of the impact over the regulatory value HC5  variations regarding the data criteria selection, distribution to which the data is fitted and percentage of species affected.

By facilitating and streamlining species toxicity data analysis and the creation of SSD curves, the user interfase proposed here should be useful for environmental managers and regulators conducting ecological risk assessments and scientifics reasearching in these topics.









