// CEW 3/2016. Based on osdloader.js
var SERVER = 'http://localhost:8080/exist/restxq/springs/iiif/'

var mirador_config = {
    id: "viewer",
    currentWorkspaceType: "bookReading",
    data: [],
    windowObjects: [
        {
            "loadedManifest" : SERVER + MANIFESTS[0] + '/manifest.json',
            "viewType" : "BookView",
            "canvasID" : SERVER + MANIFESTS[0] + '/canvas/' + COVERDIV
        }
    ]
    }
    
for (c=0; c<MANIFESTS.length; c++) {
    var m = new Object();
    m.manifestUri = SERVER + MANIFESTS[c] + '/manifest.json'
    mirador_config['data'].push(m)
}
 
 Mirador(mirador_config)
