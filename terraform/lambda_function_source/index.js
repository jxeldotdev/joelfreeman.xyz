'use strict';
exports.handler = (event, context, callback) => {
    
    // Extract the request from the CloudFront event that is sent to Lambda@Edge 
    var request = event.Records[0].cf.request;

    // Extract the URI from the request
    var olduri = request.uri;
    var newuri;
    if(olduri.endsWith('/')) {

        // Match any '/' that occurs at the end of a URI. Replace it with a default index
        var newuri = olduri.replace(/\/$/, '\/index.html');
        console.log("Requrest URI: " + request.uri);
        console.log("Old URI: " + olduri);
        console.log("New URI: " + newuri);       

        request.uri = newuri; // set uri to new uri
    } else if (olduri.endsWith(".css") || olduri.endsWith(".html")) {

        // Do nothing, only write to log
        newuri = olduri; // only assigning it so i don't get confused if i look at logs
        console.log("Requrest URI: " + request.uri);
        console.log("Old URI: " + olduri);
        console.log("New URI: " + newuri);
    } else if (olduri.endsWith(".xml")) {

        // Do nothing, only write to log
        newuri = olduri; // only assigning it so i don't get confused if i look at logs
        console.log("Requrest URI: " + request.uri);
        console.log("Old URI: " + olduri);
        console.log("New URI: " + newuri);       
    } else {
        newuri = olduri + "/"; // appending slash to end of path
        console.log("Requrest URI: " + request.uri);
        console.log("Old URI: " + olduri);
        console.log("New URI: " + newuri);

        request.uri = newuri;  // set uri to new uri
    }

    // Return to CloudFront
    return callback(null, request);

};