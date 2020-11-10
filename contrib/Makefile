CATALINA_HOME?=/usr/local/apache-tomcat-9.0/
libs = ${CATALINA_HOME}
WORKDIR=work/
FETCH?=${PWD}/bin/fetch

usage:
	@echo "make all - download libraries, setup all configuration with standart user"
	@echo "make clean - for delete all jars, classes"
all: diff-patch-match apache-commons

diff-patch-match:
	cd src/diff-patch-match && make all
apache-commons:
#	cd src/apache-commons && make all
	-mkdir ${WORKDIR}
	cd ${WORKDIR} && ${FETCH} http://mirror.linux-ia64.org/apache//commons/fileupload/binaries/commons-fileupload-1.4-bin.zip
	cd ${WORKDIR} && unzip commons-fileupload-1.4-bin.zip
	cd ${WORKDIR} && cp commons-fileupload-1.4-bin/commons-fileupload-1.4.jar ../lib/
	cd ${WORKDIR} && ${FETCH} https://archive.apache.org/dist/commons/io/binaries/commons-io-2.6-bin.zip
	cd ${WORKDIR} && unzip commons-io-2.6-bin.zip
	cd ${WORKDIR} && cp commons-io-2.6/commons-io-2.6.jar ../lib/
clean:
	@echo "Cleaning all contrib"
	rm -r ${WORKDIR}
	cd src/diff-patch-match && make clean
