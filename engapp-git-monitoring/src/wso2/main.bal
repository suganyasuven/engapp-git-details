import ballerina/http;
import ballerina/log;
import ballerina/task;
import ballerina/io;
//import ballerina/jsonutils;

http:Client gitClientEP = new("https://api.github.com" ,
                         config = {
                             followRedirects:{
                              enabled: true,
                              maxCount: 5
                         }});

public function main() {
    updateReposTable();
    //getAllIssues();
    int intervalInMillis = 3600000;
    task:Scheduler timer = new({
         intervalInMillis: intervalInMillis,
         initialDelayInMillis: 0
    });

    service DBservice = service {
            resource function onTrigger() {
                updateReposTable();
                log:printInfo("Repo table is updated");
                updateIssuesTable();
                log:printInfo("Issue table is updated");
            }
    };

    var attachResult = timer.attach(DBservice);
    if (attachResult is error) {
        log:printError("Error attaching the service.");
        return;
    }

    var startResult = timer.start();
        if (startResult is error) {
            log:printError("Starting the task is failed.");
            return;
    }
}

function updateReposTable() {
    http:Request req = new;
    req.addHeader("Authorization", "token " + "<auth-key>");
    int orgIterator = 0;
    json[] organizations = retrieveAllOrganizations();
    while (orgIterator < organizations.length()) {
        string reqURL = "/users/" + organizations[orgIterator].OrgName.toString() + "/repos";
        var response = gitClientEP->get(reqURL, message = req);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            if (statusCode != 404)
            {
                var respJson = response.getJsonPayload();
                if( respJson is json) {
                    insertIntoReposTable(<json[]> respJson, <int> organizations[orgIterator].OrgId);
                    updateOrgId(<json[]> respJson, <int> organizations[orgIterator].OrgId);
                }
            }
        } else {
            log:printError("Error when calling the backend: " + response.reason());
        }
        orgIterator = orgIterator + 1;
    }
}

function updateIssuesTable() {
    http:Request req = new;
    req.addHeader("Authorization", "token " + "<auth-key>");
    int orgIterator = 0;
    json[] organizations = retrieveAllOrganizations();
    json[] RepoUUIDsJson = retrieveAllRepos(<int> organizations[orgIterator].OrgId);
    //time:Time lastUpdated = time:subtractDuration(time:currentTime(), 0, 0, 1, 0, 0, 1, 0);
    //io:println("last_updated: ", time:toString(lastUpdated));
    string lastUpdatedDate = retrieveLastUpdatedDate();
    while (orgIterator < organizations.length()) {
        io:println(organizations[orgIterator].OrgId.toString());
        if (<int> organizations[orgIterator].OrgId != -1) {
            io:println(organizations[orgIterator].OrgId.toString());
            int repoIterator = 0;
            while (repoIterator < RepoUUIDsJson.length()) {
                string reqURL = "/repos/" + organizations[orgIterator].OrgName.toString() + "/" +
                RepoUUIDsJson[repoIterator].RepoName.toString() + "/issues?since=" + lastUpdatedDate + "&state=all";
                io:println(reqURL);
                var response = gitClientEP->get(reqURL, message = req);
                if (response is http:Response) {
                    string contentType = response.getHeader("Content-Type");
                    int statusCode = response.statusCode;
                    if (statusCode != 404)
                    {
                            var respJson = response.getJsonPayload();
                            if(respJson is json) {
                                insertIntoIssueTable (<json[]> respJson, <int>RepoUUIDsJson[repoIterator].RepoId);
                            }
                    }
                } else {
                    log:printError("Error when calling the backend: " + response.reason());
                }
                repoIterator = repoIterator + 1;
                }
        }
        orgIterator = orgIterator + 1;
    }
}