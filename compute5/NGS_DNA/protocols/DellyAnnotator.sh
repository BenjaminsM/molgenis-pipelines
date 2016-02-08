#MOLGENIS walltime=35:59:00 mem=12gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string project
#string snpEffVersion
#string hpoTerms
#string javaVersion
#string molgenisAnnotatorVersion
#string projectDellyAnnotatorOutputVcf
#string dellyVcf
#string dellySnpEffVcf

sleep 3

makeTmpDir ${projectDellyAnnotatorOutputVcf}
tmpProjectDellyAnnotatorOutputVcf=${MC_tmpFile}

${stage} ${javaVersion}
${stage} ${snpEffVersion}
${stage} ${molgenisAnnotatorVersion}
${checkStage}
if [ "${GCC_Analysis}" == "diagnostiek" ] || [ "${GCC_Analysis}" == "diagnostics" ] || [ "${GCC_Analysis}" == "Diagnostiek" ] || [ "${GCC_Analysis}" == "Diagnostics" ]
then
	#Run Molgenis CmdLineAnnotator with snpEff to add "Gene_Name" to be used for HPO annotation
	java -Xmx10g -jar -Djava.io.tmpdir=${tempDir} ${EBROOTCMDLINEANNOTATOR}/CmdLineAnnotator-1.9.0.jar \
	snpEff \
	${EBROOTSNPEFF}/snpEff.jar \
	${dellyVcf} \
	${dellySnpEffVcf}

	echo "Finished SnpEff annotation"

	#Annotate with HPO
	java -Xmx10g -jar -Djava.io.tmpdir=${tempDir} ${EBROOTCMDLINEANNOTATOR}/CmdLineAnnotator-1.9.0.jar \
	hpo \
	${hpoTerms} \
	${dellySnpEffVcf} \
	${tmpProjectDellyAnnotatorOutputVcf}

	echo "Finished HPO annotation"

	mv ${tmpProjectDellyAnnotatorOutputVcf} ${projectDellyAnnotatorOutputVcf}
else
	echo "Delly step is skipped"
fi
