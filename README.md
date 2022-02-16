Steps

(1) Get static_analyzer.log from the static analyzer

(2) Running mapping.sh reco-package name 

> ./mapping.sh RecoMuon

**(a)** Read static_analyzer.log and make a list of files only in the RecoMuon

**(b)** Print out following information

   * Target Source file (.cc)
   * EDModule type name (function)
   * Line with exist or existAs
   * parameter name

**(c)** Check whether the parameter defined with fillDescription in the source => YES or No
**(d)** Check if there is cfipython mapping hint (duplicated case) => YES or No

(3) If any (c) or (d) is "YES", then print message "====> !!!! Update !!!!"
