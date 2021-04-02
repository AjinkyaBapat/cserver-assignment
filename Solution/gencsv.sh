#!/bin/bash

#Script to generate a file named 'inputFile' in the current working directory which contains comma separated values with index and a random number.

#Can also be used/extended beyond 10 entries by specifying a numerical value as an upper limit of an index.
#E.g. By running './gencsv.sh 50', it will generate a CSV list of 50 random numbers.


#Checking for the existing file
if [ -f "inputFile" ]; then
    rm -f inputFile
fi


#If called without an argument, print 10 CSV entries.
if [ "$1" == "" ]; then
    for i in {0..9}
        do
            echo $i"," $RANDOM >> inputFile;
        done

#If an argument is provided, print those many entries of random numbers.
else

    var="$1"  #Storing the value of First positionl parameter(No. of entries)  

    for ((i=0; i<$var; i++))
        do
            echo $i"," $RANDOM >> inputFile;
        done
fi

chmod 644 ./inputFile   #To make sure that generated file is readable by other users. 


#End
