//Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/jsonutils;
import ballerina/log;
import ballerina/task;
import ballerina/config;

http:Client gitClientEP = new("https://api.github.com" ,
                         config = {
                             followRedirects:{
                              enabled: true,
                              maxCount: 5
                         }});

task:AppointmentConfiguration appointmentConfiguration = {
    appointmentDetails: CRON_EXPRESSION
};

listener task:Listener appointment = new(appointmentConfiguration);

service appointmentService on appointment {
    resource function onTrigger() {
        updateReposTable();
        log:printInfo("Repo table is updated");
        updateIssuesTable();
        log:printInfo("Issue table is updated");
    }
}

public function main() {
    updateReposTable();
    getAllIssues();
}

//Update the repo table
function updateReposTable() {
    http:Request req = new;
    req.addHeader("Authorization", "token " + config:getAsString("AUTH_KEY"));
    int orgIterator = 0;
    var organizations = retrieveAllOrganizations();
    if(organizations is json[]) {
       foreach var organization in organizations {
            string reqURL = "/users/" + organization.ORG_NAME.toString() + "/repos";
            var response = gitClientEP->get(reqURL, message = req);
            if (response is http:Response) {
                int statusCode = response.statusCode;
                if (statusCode != 404)
                {
                    var respJson = response.getJsonPayload();
                    if( respJson is json) {
                        insertIntoReposTable(<json[]> respJson, <int> organization.ORG_ID);
                        updateOrgId(<json[]> respJson, <int> organization.ORG_ID);
                    }
                }
            } else {
                log:printError("Error when calling the backend: " + response.detail().toString());
            }
        }
    } else {
        log:printError("Error while retrieving the repo details" , err = organizations);
    }
}

//Update the issue table
function updateIssuesTable() {
    http:Request req = new;
    req.addHeader("Authorization", "token " + config:getAsString("AUTH_KEY"));
    int orgIterator = 0;
    var organizations = retrieveAllOrganizations();
    if(organizations is json[]) {
        var repoUuidsJson = retrieveAllRepos(<int> organizations[orgIterator].ORG_ID);
        if(repoUuidsJson is json[]) {
            var lastUpdatedDate = retrieveLastUpdatedDate();
            if(lastUpdatedDate is string) {
                foreach var organization in organizations {
                    if (<int> organization.ORG_ID != -1) {
                        foreach var uuid in repoUuidsJson {
                            string reqURL = "/repos/" + organization.ORG_NAME.toString() + "/" +
                            uuid.REPOSITORY_NAME.toString() + "/issues?since=" + lastUpdatedDate + "&state=all";
                            var response = gitClientEP->get(reqURL, message = req);
                            if (response is http:Response) {
                                string contentType = response.getHeader("Content-Type");
                                int statusCode = response.statusCode;
                                if (statusCode != 404)
                                {
                                        var respJson = response.getJsonPayload();
                                        if(respJson is json) {
                                            insertIntoIssueTable (<json[]> respJson, <int>uuid.REPO_ID);
                                        }
                                }
                            } else {
                                log:printError("Error when calling the backend: " + response.detail().toString());
                            }
                        }
                    }
                }
            } else {
                log:printError("Error occured while retrieving organization details", err = lastUpdatedDate);
            }
        } else {
            log:printError("Error occured while retrieving organization details", err = repoUuidsJson);
        }
    } else {
        log:printError("Error occured while retrieving organization details", err = organizations);
    }
}

//Inserts the issues for the first time
function getAllIssues() {
    http:Request req = new;
    req.addHeader("Authorization", "token " + config:getAsString("AUTH_KEY"));
    var repositories =retrieveAllReposDetails();
    if(repositories is json[]) {
        foreach var repository in repositories {
            json[] repoUuidsJson =  [];
            int orgId=<int> repository.ORG_ID;
            if(orgId!=-1){
                var repoUuids = githubDb->select(GET_ORG_NAME, (), orgId);
                if (repoUuids is table< record {}>) {
                     repoUuidsJson = <json[]> jsonutils:fromTable(repoUuids);
                } else {
                      log:printError("Error occured while retrieving the product names from Database", err = repoUuids);
                }
                string orgName=repoUuidsJson[0].ORG_NAME.toString();
                int repositoryId= <int> repository.REPOSITORY_ID;
                string reqURL = "/repos/" + orgName + "/"+ repository.REPOSITORY_NAME.toString() + "/issues?state=all";
                var response = gitClientEP->get(reqURL, message = req);
                if (response is http:Response) {
                    string contentType = response.getHeader("Content-Type");
                    int statusCode = response.statusCode;
                    if (statusCode != 404)
                    {
                        var respJson = response.getJsonPayload();
                        if( respJson is json) {
                            insertIntoIssueTable(<json[]> respJson,repositoryId);
                        }
                    }
                } else {
                    log:printError("Error when calling the backend: " );
                }
            }
        }
    }
}