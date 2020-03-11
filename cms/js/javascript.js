function setParameters(path, availFiles) {
    isFile = false;
    files = availFiles;

    file = document.getElementById(fileName);
    ref = document.getElementById(refToDownload);

    fileNameToDownload = "";

    if(file.empty)
        alert("File name is empty!");

    for(i = 0; i < files.length; i++) {
        if (f == files[i]) {
            isFile = true;
            fileNameToDownload = files[i];
        }
    }
    alert("Im here");
    if(isFile === true)
        refToDownload.href = "download?path=" + path + "&file=" + fileNameToDownload;
    else
        alert("There is no this file");

}