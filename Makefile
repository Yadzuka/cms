CATALINA_HOME?=/usr/local/apache-tomcat-9.0/
SOURCES=sources/src/main/java/org/eustrosoft/
WORKDIR=work/
JARFILE=EustroCMS.jar
PACKAGE=${PWD}/sources/src/main/java/
WEBINFLIB=webapps/cms/WEB-INF/lib/
CLIBS=${PWD}/contrib/lib/
LIBS=${CATALINA_HOME}/lib/servlet-api.jar:${CLIBS}/commons-fileupload-1.4.jar:${CLIBS}/commons-io-2.6.jar:${CLIBS}/DiffPatchMatch.jar:${PACKAGE}

usage:
	@echo "This project is the base platform for all services that we have and will have"
	@echo "make all - download libraries, setup all configuration with standart user"
	@echo "make clean - for delete all jars, classes"
all: jar
	@if [ ! -d webapps/cms/WEB-INF/lib ]; then echo mkdir -p webapps/cms/WEB-INF/lib; fi
contrib-lib:
	cd contrib && make all
jar:
	@echo "Creating .class file"
	javac ${SOURCES}/tools/ZLog.java
	javac -cp ${LIBS} ${SOURCES}/providers/LogProvider.java
	javac -cp ${LIBS} ${SOURCES}/servlets/DownloadServlet.java
	javac -cp ${LIBS} ${SOURCES}/servlets/UploadServlet.java
	javac -cp ${LIBS} ${SOURCES}/servlets/UploadServletV3.java
	cd ${PACKAGE} && awk 'BEGIN{print("Manifest-Version: 1.0"); print("Created-By: 1.6.0_19 (Sun Microsystems Inc.)");}' > manifest.mf
	cd ${PACKAGE} && jar cvmf manifest.mf ${JARFILE} org
	cp ${PACKAGE}/${JARFILE} ${WEBINFLIB}
	cp ${CLIBS}/commons-fileupload-1.4.jar ${WEBINFLIB}
	cp ${CLIBS}/commons-io-2.6.jar ${WEBINFLIB}
	cp ${CLIBS}/DiffPatchMatch.jar ${WEBINFLIB}
clean:
	@echo "Cleaning all"
	rm webapps/cms/WEB-INF/lib/*.jar
	rm ${SOURCES}/providers/*.class ${SOURCES}tools/*.class ${SOURCES}servlets/*.class
maven:
	@echo "Maven making"
	mvn package
#	cp ${jarfile}sources-1.0-SNAPSHOT.jar ${webinflib}
