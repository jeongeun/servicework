#!/bin/bash

RECOSET=$1  #input one reco-package
if [ "$RECOSET" == "" ]; then
      echo "usage: $0 RECOSET name";
      break;
fi

cat reco_Bug.log | grep $RECOSET | awk '{print $1 "	" $3}' | sort -u >> $RECOSET.txt
INPUT=$RECOSET.txt
echo "************$RECOSET****************";

while IFS= read -r line
do
  echo "***********************************************************************";

  SOURCE=`echo $line | awk '{print $1}'`               # target source file
  FUNC=`echo $line | awk '{print $2}'`                 # function/method
  EXIST=`grep -r -n "exist" ./$SOURCE`                 # line with exist or existAs

  echo "#targetCC: $SOURCE     #function: $FUNC";      # print out

  ### FillDesctiprion Check ###

  FILLDESC_CHECK1=0
  FILLDESC_CHECK2=0
  FILLDESC_Num=0
  FILLDESC=`grep -r -n "::fillDescriptions(edm::" ./$SOURCE` # check fillDescription used in this source file
  #echo "filldescription = $FILLDESC"

  if [ "$FILLDESC" != ""  ];then
     FILLDESC_CHECK1=1                                       # if fillDescription is used in the source, then set to 1
     FILLDESC_Num=`echo $FILLDESC | awk -F':' '{print $1}'`  # keep the line number (fillDescription)
     echo "#fillDescription: $FILLDESC"                     # print out
  fi

  ### cfipython Check ###

  CFI_CHECK1=0
  CFI_CHECK2=0
  CFIPYTHON=""
  CFI=""
  CFI_PARAM=""
  CFIPYTHON=`grep -r cms.ED $CMSSW_RELEASE_BASE/cfipython/$SCRAM_ARCH/[A-Z]* | cut -d"/" -f10- | sed -e "s/[':=(,]/ /g;s/[ ]* / /g;s/ $//" | grep ${FUNC}`  # find relavant cfipython
  if [ "$CFIPYTHON" != ""  ];then                                      # if there is a relevant cfipython, then set to 1
     CFI_CHECK1=1
     CFI=`echo ../cfipython/$SCRAM_ARCH/$CFIPYTHON | awk '{print $1}'` # only cfipython file directory and name
     #echo "# cfipython: $CFIPYTHON";                                  # print out
     echo "#cfipython: $CFI";                                               # print out
  fi
  #echo "cfipython = $CFIPYHION  cfi = $CFI"
  echo "$EXIST";

  ### parameter loop ###

  while IFS= read -r EXIST                    # loop for check all parameters call to exis one by one
  do
      PARAM=`echo $EXIST | cut -d '"' -f2`    # check parameter name
      if [ "${PARAM}" != "" ];then
            CC_PARAM=""
            CC_PARAM=`grep -r -n $PARAM ./$SOURCE | grep -Ev'exist'`  # check other lines using this parameter in the source
            CC_PARAM_Num=`echo $CC_PARAM | awk -F':' '{print $1}'`    # keep the line number ( parameter)
            echo "###pramCC: $PARAM  inCC: $CC_PARAM_Num  inFillDesc: $FILLDESC_Num " ;
            echo "$CC_PARAM" ;                              # print out

            if [ "${FILLDESC_Num}" != "0"  -a "${CC_PARAM_Num}" != "" -a ${CC_PARAM_Num} -gt ${FILLDESC_Num} ];then 
                 FILLDESC_CHECK2=1                                    # if the parameter is also defined after fillDescription line, then set to 1
                 echo "--- in filldesc cc : $CC_PARAM";                        # print the reducdant line (parameter) in the source file
            else
                 echo "--- not found in filldesc cc"
            fi

            if [ "{$CFI_CHECK1}" != "0" -a "${CFI}"  ]; then                                          
                  CFI_PARAM=`grep -r -n $PARAM $CFI`                  # check all other lines using this parameter in the cfipython
                  if [ "$CFI_PARAM" != "" ];then                  
                       CFI_CHECK2=1                                   # if the parameter is also defined in cfipython file, then set to 1 
                       echo "--- in cfipy : $CFI_PARAM";                  # print the redundant line in the cfipython file
                  else
                       echo "--- not found in cfi"
                  fi
            fi
            
      fi

  done <<< "$(grep -r "exist" ./$SOURCE)" # loop finished

  ### Final check ###

  echo "###FinalCheck fillDesc $FILLDESC_CHECK1 redundent $FILLDESC_CHECK2  cfipython $CFI_CHECK1 redeudent $CFI_CHECK2";

  if [ $FILLDESC_CHECK1 -eq 1 -o $FILLDESC_CHECK2 -eq 1 -o  $CFI_CHECK1 -eq 1 -o $CFI_CHECK2 -eq 1 ];then
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
        echo "Please check $SOURCE ! $FILLDESC_CHECK1 $FILLDESC_CHECK2 $CFI_CHECK1 $CFI_CHECK2 $CFI";
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
  fi

done < "$INPUT"

rm -rf $INPUT
