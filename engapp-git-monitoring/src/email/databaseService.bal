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

//import ballerina/config;
import ballerina/jsonutils;
import ballerinax/java.jdbc;
import ballerina/log;

jdbc:Client githubDb = new ({
    url: "jdbc:mysql://localhost:3306/WSO2_ORGANIZATION_DETAILS",
    username: "root",
    password: "root",
    dbOptions: {useSSL: false}
});

//Retrieves the team details from the database
function retrieveAllTeams() returns json[]? {
    var teams = githubDb->select(RETRIEVE_TEAMS, ());
    if (teams is table<record {}>) {
        json teamJson = jsonutils:fromTable(teams);
        return <json[]>teamJson;
    } else {
        log:printDebug("Error occured while retrieving the team details from Database");
    }
}

//Retrieves the repo details from the database for given Team id
function retrieveAllReposByTeam(int teamId) returns json[]? {
    var repositories = githubDb->select(RETRIEVE_REPOS, (), teamId);
    if (repositories is table<record {}>) {
        json repositoriesJson = jsonutils:fromTable(repositories);
        return <json[]>repositoriesJson;
    } else {
        log:printDebug("Error occured while retrieving the repo details from Database");
    }
}

//Retrieves the Issue details from the database for the given Repo id
function retrieveAllIssuesByRepoId(int repositoryId) returns json[]? {
    var issues = githubDb->select(RETRIEVE_ISSUES, (), repositoryId);
    if (issues is table<record {}>) {
        json issueJson = jsonutils:fromTable(issues);
        return <json[]>issueJson;
    } else {
        log:printDebug("Error occured while retrieving the issues details from Database");
    }
}

//Retrieves the count of open PRs for each team
function openPrsForTeam(int teamId, string teamName) returns json[]?{
    var repositories = retrieveAllReposByTeam(teamId);
    if(repositories is json[]) {
        json[] issuesForTeams  = [];
        json[] prJson = [];
        foreach var repository in repositories {
            var prs = retrieveAllIssuesByRepoId(<int>repository.REPOSITORY_ID);
            if(prs is json[]) {
               foreach var pr in prs {
                    json prDetail = {
                        teamName: teamName,
                        repoName: repository.REPOSITORY_NAME.toString(),
                        updatedDate: pr.UPDATED_DATE.toString(),
                        createdBy: pr.CREATED_BY.toString(),
                        url: pr.HTML_URL.toString(),
                        openDays: pr.OPEN_DAYS.toString(),
                        labels: pr.LABELS.toString()
                    };
                    prJson.push(prDetail);
                }
            } else {
                log:printError("Error occured while retrieving the issue details from Database", err = prs);
            }
        }
        return <json[]>prJson;
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = repositories);
    }
}
