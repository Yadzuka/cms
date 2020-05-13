libs = ${CATALINA_HOME}
sources = sources/src/main/java/org/eustrosoft/
jarfile = target/
package = sources/src/main/java/
webinflib = ${webapps/cms/WEB-INF/lib/}
diffpatchmatch = diff-match-patch/java/src/

usage:
	@echo "This project is the base platform for all services that we have and will have"
	@echo "make all - download libraries, setup all configuration with standart user"
	@echo "make clean - for delete all jars, classes"
all:
	@if [ !-d ${webapps/cms/WEB-INF/lib} ]; then
		mkdir ${webapps/cms/WEB-INF/lib};
	fi
	git clone https://github.com/google/diff-match-patch.git
	javac ${diffpatchmatch}name/fraser/neil/plaintext/*.java
	cd diff-match-patch/java/src/
	touch manifest.mf
	awk 'BEGIN{print("Manifest-Version: 1.0"); print("Created-By: 1.6.0_19 (Sun Microsystems Inc.)");}' > manifest.mf
	jar cvmf manifest.mf DiffPatchMatch.jar name && cd ../../../
	wget http://mirror.linux-ia64.org/apache//commons/fileupload/binaries/commons-fileupload-1.4-bin.zip
	unzip commons-fileupload-1.4-bin.zip
	cp commons-fileupload-1.4-bin/commons-fileupload-1.4.jar ${webinflib}
	wget https://apache-mirror.rbc.ru/pub/apache//commons/io/binaries/commons-io-2.6-bin.zip
	unzip commons-io-2.6-bin.zip
	cp commons-io-2.6-bin/commons-io-2.6.jar ${webinflib}
	@echo "Creating .class file"
	javac ${sources}tools/ZLog.java
	javac -cp ${package} ${sources}providers/LogProvider.java
	javac -cp ${package}:${libs}/lib/servlet-api.jar:${webinflib}/lib/commons-fileupload-1.4.jar:${webinflib}/lib/commons-io-2.6.jar ${sources}servlets/DownloadServlet.java
	javac -cp ${package}:${libs}/lib/servlet-api.jar:${webinflib}/lib/commons-fileupload-1.4.jar:${webinflib}/lib/commons-io-2.6.jar ${sources}servlets/UploadServlet.java
	javac -cp ${package}:${libs}/lib/servlet-api.jar:${webinflib}/lib/commons-fileupload-1.4.jar:${webinflib}/lib/commons-io-2.6.jar ${sources}servlets/DownloadServletV3.java
	cd ${package}
	touch manifest.mf
	awk 'BEGIN{print("Manifest-Version: 1.0"); print("Created-By: 1.6.0_19 (Sun Microsystems Inc.)");}' > manifest.mf
	jar cvmf manifest.mf sources.jar org && cd ../../../../
	cp ${package}sources.jar ${webinflib}
clean:
	@echo "Cleaning all"
	rm ${sources}providers/*.class ${sources}tools/*.class ${sources}servlets/*.class
	rm webapps/cms/WEB-INF/lib/*.jar
maven:
	@echo "Maven making"
	mvn package
	cp ${jarfile}sources-1.0-SNAPSHOT.jar ${webinflib}
