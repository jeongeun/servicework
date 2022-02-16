#!/bin/bash

RECOSET=$1
if [ "$RECOSET" == "" ]; then
      echo "usage: $0 RECOSET name";
      break;
fi

cat reco_Bug.log | grep $RECOSET | awk '{print $0}' | sort -u >> $RECOSET.txt
INPUT=$RECOSET.txt
echo "************$RECOSET****************";

while IFS= read -r line
do
  echo "***********************************************************************";
  SOURCE=`echo $line | awk '{print $1}'`
  FUNC=`echo $line | awk '{print $3}'`
  EXIST=`grep -r -n "exist" ./$SOURCE`
  echo "#TargetCC: $SOURCE     #Function: $FUNC";
#  echo "$EXIST";
#  echo ">>>>> parameter Check in CC--------";

  while IFS= read -r EXIST
  do
        FILLDESC_CHECK1=0
        FILLDESC=`grep -r -n "::fillDescriptions" ./$SOURCE`
        PARAM=`echo $EXIST | cut -d '"' -f2`
        CC_PARAM=`grep -r -n $PARAM ./$SOURCE | grep -Ev'exist'`

        echo "###prameterCC : $PARAM";
        if [ "$FILLDESC" != ""  ];then
           FILLDESC_CHECK1=1
           echo "###FillDescription : $FILLDESC" 
        fi
        echo "$CC_PARAM";
  done <<< "$(grep -r "exist" ./$SOURCE)"

#  echo ">>>>> parameter Check in CFI-------";
  CFI_CHECK1=0
  CFI_CHECK2=0
  CFIPYTHON=`grep -r cms.ED $CMSSW_RELEASE_BASE/cfipython/$SCRAM_ARCH/[A-Z]* | cut -d"/" -f10- | sed -e "s/[':=(,]/ /g;s/[ ]* / /g;s/ $//" | grep ${FUNC}`
  if [ "$CFIPYTHON" != "" ]; then
        CFI_CHECK1=1
        echo "###Cfipython : $CFIPYTHON";
        CFI=`echo $CFIPYTHON | awk '{print $1}'`
        CFI_PARAM=`grep -r -n $PARAM $CFI`

        if [ "$CFI_PARAM" != "" ];then
             CFI_CHECK2=1
             echo "$CFI_PARAM";
        fi
  fi

  echo "# Last Check : fillDescription: $FILLDESC_CHECK1   cfipython: $CFI_CHECK1   param: $CFI_CHECK2";
  if [ $FILLDESC_CHECK1 -eq 1 -o $CFI_CHECK1 -eq 1 -o $CFI_CHECK2 -eq 1 ];then
        echo "===>> !!!!! Update $SOURCE !!!  $FILLDESC_CHECK1 $CFI_CHECK1 $CFI_CHECK2  $CFI";
        echo "##########################################3#########";
  fi
  echo "***********************************************************************";

done < "$INPUT"

rm -rf $RECOSET.txt
