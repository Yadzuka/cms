PROJ=diff-match-patch
SRCHUB=https://github.com/google/
RESULTFILE=DiffPatchMatch.jar
DSTDIR=../../lib/

usage:
	@echo "make (all|clean)"
	@echo "      all - download all required for building from sources, build & put result to ../../lib/"
	@echo "      clean - delete everithing to start building from scratch (except result placed at ../../lib/)"
all: ${PROJ}

${PROJ}: ${PROJ}-build ${PROJ}-install
rebuild: ${PROJ}-build ${PROJ}-install
${PROJ}-install:
	cp ${PROJ}/java/src/${RESULTFILE} ${DSTDIR}
${PROJ}-build:
	-git clone ${SRCHUB}${PROJ}.git
	javac ${PROJ}/java/src/name/fraser/neil/plaintext/*.java
	cd ${PROJ}/java/src/ && awk 'BEGIN{print("Manifest-Version: 1.0\nCreated-By: 1.6.0_19 (Sun Microsystems Inc.)");}' > manifest.mf
	cd ${PROJ}/java/src/ && jar cvmf manifest.mf ${RESULTFILE} name 
clean:
	@echo "Cleaning contrib PROJ: ${PROJ}"
	rm -rf ${PROJ}
clean-lib:
	rm  ${DSTDIR}/${RESULTFILE}
clean-all: clean clean-lib
