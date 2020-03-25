function setParameters(path, availFiles) {
    let isFile = false;
    let files = availFiles;

    let file = document.getElementById(fileName);
    let ref = document.getElementById(refToDownload);

    let fileNameToDownload = "";

    if(file.empty)
        alert("File name is empty!");

    for(let i = 0; i < files.length; i++) {
        if (f === files[i]) {
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