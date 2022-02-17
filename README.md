*Aims :*
Cleanup redundant cases of edm::ParameterSet calls to existAs or exist for tracked parameters, where redundancy is based on the value being already defined by fillDescriptions.

*Motivation :*
values of tracked parameters should be properly defined in the configuration and be visible in the process configuration provenance; code that checks for existence of a parameter and sets a hardcoded default would bypass the configuration provenance registration and should be avoided. In general, default parameter values should be provided via fillDescriptions, as detailed in SWGuideConfigurationValidationAndHelp. Redundant calls to existAs or exist can be cleaned up.


The list of all calls of existAs or exist are available in the Static Analyzer reports accessible e.g. from IB page. 
For this task consider only modules or tools used by the modules that define fillDescriptions. 
The following cases can be considered redundant in this set and straightforward for cleanup:

- There is a setDefaults with a value the same as the hardcoded default in the existAs or exist logic.
- The fillDescriptions defines a configuration in cfipython/ with this parameter and instances of this module type already use the cfipython/ (we assume here also that the HLT configurations for these cases already define the parameter explicitly; as typically is the rule for HLT configurations)


*reference twiki :*
https://twiki.cern.ch/twiki/bin/viewauth/CMS/OpenRecoTasks
https://cmssdt.cern.ch/SDT/html/cmssdt-ib/#/ib/CMSSW_12_3_X
https://twiki.cern.ch/twiki/bin/view/CMS/SWGuideConfigurationValidationAndHelp


*Steps :*

(1) Get reco_Bug.log from the Static Analyzer reports (from IB page 12_3_X for now)

(2) Running mapping.sh <reco-package name> 

-- for example :

> ./mapping.sh RecoMuon > recomuon.log

-- workflow in mapping.sh :
**(a)** Read reco_Bug.log and make a list of files only in the RecoMuon

**(b)** Print out following information

   * Target Source file (.cc)
   * ED module name (function)
   * The line where the fillDescription is located in the source file
   * cfipython file containg the same/similar module
   * The line where the exist or existAs are located in the source file
   * The parameter name

**(c)** Check whether the parameter also defined with fillDescription in the source file => if yes 1, no 0. 
**(d)** Check if the parameter is in the cfipython (referring to the slava's mapping hint script) => if yes 1, no 0.

(3) If any (c) or (d) is set to 1, then print message "Please check & update !"
