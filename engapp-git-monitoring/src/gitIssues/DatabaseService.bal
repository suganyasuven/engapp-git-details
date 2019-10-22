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

import ballerinax/java.jdbc;
import ballerina/jsonutils;
import ballerina/log;
import ballerina/config;

jdbc:Client githubDb = new ({
    url: "jdbc:mysql://localhost:3306/WSO2_ORGANIZATION_DETAILS",
    username: config:getAsString("DB_USERNAME"),
    password: config:getAsString("DB_PASSWORD"),
    poolOptions: {maximumPoolSize: 10},
    dbOptions: {useSSL: false}
});

//Retrieves the team details from the database
function retrieveAllTeams() returns json[]? {
    var teams = githubDb->select(RETRIEVE_TEAMS, ());
    if (teams is table<record {}>) {
        json teamJson = jsonutils:fromTable(teams);
        return <json[]>teamJson;
    } else {
        log:printError("Error occured while retrieving the team details from Database", err = teams);
    }
}

//Retrieves the repo details from the database for the given teamId
function retrieveAllReposByTeam(int teamId) returns json[]? {
    var repos = githubDb->select(RETRIEVE_REPOSITORIES_BY_TEAM, (), teamId);
    if (repos is table<record {}>) {
        json repoJson = jsonutils:fromTable(repos);
        return <json[]>repoJson;
    } else {
        log:printError("Error occured while retrieving the repo details for a given team id from Database", err = repos);
    }
}

//Retrieves the repo details from the database
function retrieveAllRepos() returns json[]? {
    var repos = githubDb->select(RETRIEVE_REPOSITORIES, ());
    if (repos is table<record {}>) {
        json repoJson = jsonutils:fromTable(repos);
        return <json[]>repoJson;
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = repos);
    }
}

//Retrieves the open days for each for open issue from the database
function retrieveOpendaysForIssues(int repoId) returns json[]? {
    var issues = githubDb->select(OPEN_DAYS_FOR_ISSUES, (), repoId);
    if (issues is table<record {}>) {
        json issueJson = jsonutils:fromTable(issues);
        return <json[]>issueJson;
    } else {
        log:printError("Error occured while retrieving the open days for an issue from Database", err = issues);
    }
}

//Retrieves the issue details from the database for given repo Id
function retrieveAllIssuesByRepoId(int repoId) returns json[]? {
    var issues = githubDb->select(RETRIEVE_ISSUES_BY_REPOSITORY, (), repoId);
    if (issues is table<record {}>) {
        json issueJson = jsonutils:fromTable(issues);
        return <json[]>issueJson;
    } else {
        log:printError("Error occured while retrieving the issues details for given repo id from Database", err = issues);
    }
}

//Retrieves open Issues Details
function retrieveAllIssues() returns json[]? {
    var issues = githubDb->select(RETRIEVE_ISSUES, ());
    if (issues is table<record {}>) {
        json issueJson = jsonutils:fromTable(issues);
        return <json[]>issueJson;
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = issues);
    }
}

//Get details of issue counts in terms of issue labels for each team
function getDetailsOfIssue() returns json[]{
    var teamJson = retrieveAllTeams();
    json[] teamIssues = [];
    int teamIterator = 0;
    if(teamJson is json[]) {
        foreach var team in teamJson {
            int totalIssueCount=0;
            int l1issuecount=0;
            int l2issuecount=0;
            int l3issuecount=0;
            var repositories = retrieveAllReposByTeam(<int>team.TEAM_ID);
            if(repositories is json[]) {
                foreach var repository in repositories{
                int noOfIssue = 0;
                var issues = retrieveAllIssuesByRepoId(<int>repository.REPOSITORY_ID);
                    if(issues is json[]) {
                        foreach var issue in issues{
                            string team_name=team.TEAM_NAME.toString();
                            string html_url=issue.HTML_URL.toString();
                            string labels=issue.LABELS.toString();
                            string l1Issues = "Severity/Blocker";
                            string l2Issues = "Severity/Critical";
                            string l3Issues = "Severity/Major";
                            int? l1IssueIndex = labels.indexOf(l1Issues);
                            if (l1IssueIndex is int) {
                                l1issuecount=l1issuecount+1;
                            }
                            int? l2IssueIndex = labels.indexOf(l2Issues);
                            if (l2IssueIndex is int) {
                                l2issuecount=l2issuecount+1;
                            }
                            int? l3IssueIndex = labels.indexOf(l3Issues);
                            if (l3IssueIndex is int) {
                                 l3issuecount=l3issuecount+1;
                            }
                        }
                    noOfIssue = issues.length();
                    totalIssueCount = totalIssueCount + noOfIssue;
                    } else {
                        log:printError("Returned value is not a json. Error occured while retrieving the issues details from Database", err = issues);
                    }
                }
            } else {
                log:printError("Returned value is not a json. Error occured while retrieving the repo details from Database", err = repositories);
            }
             teamIssues[teamIterator] = {
                name : team.TEAM_ABBR.toString(),
                totalIssueCount :<int>totalIssueCount,
                L1IssueCount :<int>l1issuecount,
                L2IssueCount :<int>l2issuecount,
                L3IssueCount :<int>l3issuecount
             };
             teamIterator = teamIterator + 1;
        }
     } else {
         log:printError("Returned value is not a json. Error occured while retrieving the team details from Database", err = teamJson);
     }
     return teamIssues;
}

//Inserts the number of open and closed issue count every day
function InsertIssueCountDetails(){
    var openIssueCount = githubDb->select(RETRIEVE_OPEN_ISSUE_COUNT, ());
    var closedIssueCount = githubDb->select(RETRIEVE_CLOSED_ISSUE_COUNT, ());
    if (openIssueCount is table< record {}> && closedIssueCount is table< record {}>) {
        json[] openIssueCountJson = <json[]>jsonutils:fromTable(openIssueCount);
        json[] closedIssueCountJson = <json[]>jsonutils:fromTable(closedIssueCount);
        var ret = githubDb->update(INSERT_ISSUE_COUNT, <int>openIssueCountJson[0].OPEN_ISSUES, <int>closedIssueCountJson[0].CLOSED_ISSUES);
    } else {
        log:printError("Error occured while insering the issues count details for each day to the Database");
    }
}

//Retrieves the number of open and closed Issue counts details everyday
function retrieveIssueCountDetails() returns json[] {
    var issueCounts = githubDb->select(RETRIEVE_ISSUE_COUNT, ());
    json[] issueCountDetail = [];
    if (issueCounts is table< record {}>) {
        int iterator = 0;
        json[] openIssueData = [];
        json[] closedIssueData = [];
        json[] issueCountsJson = <json[]>jsonutils:fromTable(issueCounts);
        while(iterator < issueCountsJson.length()) {
            json openIssue = {
                date : issueCountsJson[iterator].DATE.toString(),
                count: issueCountsJson[iterator].OPEN_ISSUES.toString()
            };
            json closedIssue = {
                date : issueCountsJson[iterator].DATE.toString(),
                count: issueCountsJson[iterator].CLOSED_ISSUES.toString()
            };
            openIssueData[iterator] = openIssue;
            closedIssueData[iterator] = closedIssue;
            iterator = iterator + 1;
        }
        issueCountDetail = [
            {
                name: "Open Issues",
                data: openIssueData
            },
            {
                name: "Closed Issues",
                data: closedIssueData
            }
            ];
    } else {
        log:printError("Returned value is not a json. Error occured while retrieving the issues count from Database");
    }
    return issueCountDetail;
}

//Retrieves the how many number of issues are open for specific periods like day, week, month etc
function retrieveIssueAgingDetails() returns json[]{
    json[] openDaysCount = [];
    var agingDetails = githubDb->select(RETRIEVE_AGING_DETAILS, ());
    if (agingDetails is table< record {}>) {
        json[] agingDetailsJson = <json[]>jsonutils:fromTable(agingDetails);
        int iterator = 0;
        int day = 0;
        int week = 0;
        int month = 0;
        int month3 = 0;
        int morethan = 0;
        while(iterator < agingDetailsJson.length()) {
            int openDays = <int>agingDetailsJson[iterator].OPEN_DAYS;
            if (openDays <= 1) {
                day = day + 1;
            } else if (openDays <= 7) {
                week = week + 1;
            } else if (openDays <= 30) {
                month = month + 1;
            } else if (openDays <= 90) {
                month3 = month3 + 1;
            } else {
                morethan = morethan + 1;
            }
            iterator = iterator + 1;
        }
        openDaysCount = [["1 Day", day], ["1 Week", week], ["1 Month" ,month], ["3 Months", month3], ["More than 3 months", morethan]];
    } else {
        log:printError("Error occured while retrieving the issues aging details to the Database", agingDetails);
    }
    return openDaysCount;
}

//Retrieves the how many number of issues are open for specific periods like day, week, month etc for each team
function openIssuesAgingForTeam() returns json[]{
    json[] data = [];
    var teams = retrieveAllTeams();
    if(teams is json[]) {
        json[] issuesForTeams  = [];
        foreach var team in teams {
            int day = 0;
            int week = 0;
            int month = 0;
            int month3 = 0;
            int morethan = 0;
            var repositories = retrieveAllReposByTeam(<int> team.TEAM_ID);
            if(repositories is json[]) {
                foreach var repository in  repositories {
                    var prs = retrieveOpendaysForIssues(<int>repository.REPOSITORY_ID);
                    if(prs is json[]) {
                        foreach var pr in prs{
                            int openDays = <int>pr.OPEN_DAYS;
                            if (openDays <= 1) {
                                day = day + 1;
                            } else if (openDays <= 7) {
                                week = week + 1;
                            } else if (openDays <= 30) {
                                month = month + 1;
                            } else if (openDays <= 90) {
                                month3 = month3 + 1;
                            } else {
                                morethan = morethan + 1;
                            }
                        }
                    } else {
                        log:printError("Returned value is not a json. Error occured while retrieving the issue details from Database", err = prs);
                    }
                }
            } else {
                log:printError("Returned value is not a json. Error occured while retrieving the teams aging details to the Database", err = repositories);
            }
            json teamData = {
                name : team.TEAM_NAME.toString(),
                data : [["1 Day" , day] , ["1 Week", week] , ["1 Month", month], ["3 Months" , month3], ["Morethan 3 months", morethan]]
            };
            data.push(teamData);
        }
    } else {
        log:printError("Returned value is not a json. Error occured while retrieving the teams aging details to the Database",teams);
    }
    return data;
}

//Retrieves the how many number of issues are open for specific periods like day, week, month etc in terms of issue labels
function openIssuesAgingForLabels() returns json[]{
    json[] data = [];
    var repos = retrieveAllRepos();
    if(repos is json[]) {
        json[] issuesForLabels  = [];
        string[] labels = ["Severity/Blocker", "Severity/Critical", "Severity/Major"];
        int labelIterator = 0;
        while(labelIterator < labels.length()) {
            int day = 0;
            int week = 0;
            int month = 0;
            int month3 = 0;
            int morethan = 0;
            int repoIterator = 0;
            while(repoIterator < repos.length()) {
                var prs = retrieveOpendaysForIssues(<int> repos[repoIterator].REPOSITORY_ID);
                if(prs is json[]) {
                    int prIterator = 0;
                    while (prIterator < prs.length()) {
                        int openDays = <int>prs[prIterator].OPEN_DAYS;
                        if (openDays <= 1) {
                            day = day + 1;
                        } else if (openDays <= 7) {
                            week = week + 1;
                        } else if (openDays <= 30) {
                            month = month + 1;
                        } else if (openDays <= 90) {
                            month3 = month3 + 1;
                        } else {
                            morethan = morethan + 1;
                        }
                        prIterator=prIterator+1;
                    }
                } else {
                    log:printError("Returned value is not a json. Error occured while retrieving the issues from the Database", prs);
                }
                repoIterator = repoIterator + 1;
            }
            json teamData = {
                name : labels[labelIterator],
                data : [["1 Day" , day] , ["1 week", week] , ["1 month", month], ["month 3" , month3], ["morethan 3 months", morethan]]
            };
            data.push(teamData);
            labelIterator = labelIterator + 1;
        }
    } else {
        log:printError("Returned value is not a json. Error occured while retrieving the repo details from the Database", repos);
    }
    return data;
}



