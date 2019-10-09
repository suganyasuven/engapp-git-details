


import ballerina/http;
import ballerina/log;
listener http:Listener httpListener = new(9091);


@http:ServiceConfig {
    basePath: "/gitIssues",
    cors : {
        allowOrigins: ["*"]
    }
}
service githubIssueService on httpListener {

    @http:ResourceConfig {
            methods: ["GET"],
            path: "/issueCount"
        }
        resource function getIssueCount (http:Caller httpCaller, http:Request request) {
            // Initialize an empty http response message
            http:Response response = new;
            // Invoke retrieveData function to retrieve data from mysql database
            var allGitIssueCount = getDetailsOfIssue();
            // Send the response back to the client with the git issue data
            response.setPayload( allGitIssueCount);
            var respondRet = httpCaller->respond(response);
            if (respondRet is error) {
                // Log the error for the service maintainers.
                log:printError("Error responding to the client", err = respondRet);
            }
            }

}

