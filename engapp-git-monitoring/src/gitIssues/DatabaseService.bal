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

import ballerina/io;
import ballerina/jsonutils;
import ballerina/log;
import ballerinax/java.jdbc;

jdbc:Client GithubDb = new ({
    url: "jdbc:mysql://localhost:3306/WSO2_ORGANIZATION_DETAILS",
    username: "root",
    password: "root",
    poolOptions: {maximumPoolSize: 10},
    dbOptions: {useSSL: false}
});

type Repo record {
    int RepoId;
    string GitUuid;
    string RepoName;
    int OrgId;
    string url;
    int TeamId;
};

type Team record {
    int TeamId;
    string TeamName;
    string TeamAbbr;

};

function retrieveAllTeams() returns json[] {
    var Teams = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_TEAMS", Team);
    if (Teams is table<Team>) {
        json TeamJson = jsonutils:fromTable(Teams);
        return <json[]>TeamJson;
    } else {
        log:printError("Error occured while retrieving the team details from Database", err = Teams);
    }
    return [];
}

function retrieveAllReposByTeam(int TeamId) returns json[] {
    var Repos = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_REPOS WHERE TEAM_ID=?", Repo, TeamId);
    if (Repos is table<Repo>) {
        json RepoJson = jsonutils:fromTable(Repos);
        return <json[]>RepoJson;
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = Repos);
    }
    return [];
}

function retrieveAllRepos() returns json[] {
    var Repos = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_REPOS", Repo);
    if (Repos is table<Repo>) {
        json RepoJson = jsonutils:fromTable(Repos);
        return <json[]>RepoJson;
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = Repos);
    }
    return [];
}

function retrieveOpendaysForIssues(int RepoId) returns json[] {
    string issueType = "ISSUE";
    var issues = GithubDb->select("SELECT DATEDIFF(CURDATE(), CAST(CREATED_DATE AS DATE)) AS OPEN_DAYS FROM ENGAPP_GITHUB_ISSUES WHERE REPO_ID=? AND ISSUE_TYPE=? AND CLOSED_DATE IS NULL", (), RepoId, issueType);
    io:println("repoId: ", RepoId);
    if (issues is table<record {}>) {
        json IssueJson = jsonutils:fromTable(issues);
        io:println("IssueJson", IssueJson.toString());
        return <json[]>IssueJson;
    } else {
        log:printError("Error occured while retrieving the issue details from Database", err = issues);
    }
    return [];
}

function retrieveAllIssuesByRepoId(int RepoId) returns json[] {

    string issueType = "ISSUE";
    var issues = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_ISSUES WHERE REPO_ID=? AND ISSUE_TYPE=?", (), RepoId, issueType);

    if (issues is table<record {}>) {
        json IssueJson = jsonutils:fromTable(issues);
        return <json[]>IssueJson;
    } else {
        log:printError("Error occured while retrieving the issues details from Database", err = issues);
    }
    return [];
}

function retrieveAllIssues() returns json[] {

    string issueType = "ISSUE";
    var issues = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_ISSUES WHERE  ISSUE_TYPE=? AND CLOSED_DATE IS NULL", (), issueType);

    if (issues is table<record {}>) {
        json IssueJson = jsonutils:fromTable(issues);
        return <json[]>IssueJson;
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = issues);
    }
    return [];
}

function getDetailsOfIssue() returns json[]{
    json[] teamJson = retrieveAllTeams();
    json[] issueCountByTeam = [];
    int teamIterator = 0;
    json[] teamIssues = [];
    while (teamIterator < teamJson.length()) {
        int team_id = <int>teamJson[teamIterator].TeamId;
        int TotalIssueCount=0;
        int L1issuecount=0;
        int L2issuecount=0;
        int L3issuecount=0;
        int repoIterator = 0;

        json[] repositories = retrieveAllReposByTeam(team_id);
        while (repoIterator < repositories.length()) {
        int no_of_issue = 0;
        int issueIterator=0;
        int RepoId = <int>repositories[repoIterator].RepoId;

        json[] issues1 = retrieveAllIssuesByRepoId(RepoId);
        while (issueIterator < issues1.length()){
            string team_name=teamJson[teamIterator].TeamName.toString();
            string html_url=issues1[issueIterator].HTML_URL.toString();
            string labels=issues1[issueIterator].LABELS.toString();
            string L1Issues = "Severity/Blocker";
            string L2Issues = "Severity/Critical";
            string L3Issues = "Severity/Major";
            int? index1 = labels.indexOf(L1Issues);
            if (index1 is int) {
                L1issuecount=L1issuecount+1;
                io:println("L1issuecount",  L1issuecount );
            }
            int? index2 = labels.indexOf(L2Issues);
            if (index2 is int) {
                L2issuecount=L2issuecount+1;

                io:println("L2issuecount",  L2issuecount );
            }
            int? index3 = labels.indexOf(L3Issues);
            if (index3 is int) {
                 L3issuecount=L3issuecount+1;
            }
        issueIterator=issueIterator+1;
        }
        no_of_issue = issues1.length();
        TotalIssueCount = TotalIssueCount + no_of_issue;
        repoIterator = repoIterator + 1;
     }
     teamIssues[teamIterator] = {

        name : teamJson[teamIterator].TeamAbbr.toString(),
        totalIssueCount :<int>TotalIssueCount,
        L1IssueCount :<int>L1issuecount,
        L2IssueCount :<int>L2issuecount,
        L3IssueCount :<int>L3issuecount
     };
     teamIterator = teamIterator + 1;
     }
     return teamIssues;

}

function InsertIssueCountDetails(){
     var OpenIssueCount = GithubDb->select("SELECT COUNT(DISTINCT(GITHUB_ID)) as OpenIssues FROM ENGAPP_GITHUB_ISSUES WHERE ISSUE_TYPE LIKE 'ISSUE' AND CLOSED_DATE IS NOT NULL", ());
        var ClosedIssueCount = GithubDb->select("SELECT COUNT(DISTINCT(GITHUB_ID)) as ClosedIssues FROM ENGAPP_GITHUB_ISSUES WHERE ISSUE_TYPE LIKE 'ISSUE' AND CLOSED_DATE IS NULL", ());
        if (OpenIssueCount is table< record {}> && ClosedIssueCount is table< record {}>) {
            json[] OpenIssueCountJson = <json[]>jsonutils:fromTable(OpenIssueCount);
            json[] ClosedIssueCountJson = <json[]>jsonutils:fromTable(ClosedIssueCount);
            int openIssues = <int>OpenIssueCountJson[0].OpenIssues;
            int closedIssues = <int>ClosedIssueCountJson[0].ClosedIssues;
            var ret = GithubDb->update("INSERT INTO ENGAPP_ISSUE_COUNT(DATE, OPEN_ISSUES, CLOSED_ISSUES) Values (CURDATE(),?,?)", openIssues, closedIssues);
        } else {
            log:printError("Error occured while insering the issues count details to the Database");
        }
}

function retrieveIssueCountDetails() returns json[]{
    var IssueCounts = GithubDb->select("SELECT * FROM ENGAPP_ISSUE_COUNT", ());
    if (IssueCounts is table< record {}>) {
        int iterator = 0;
        json[] OpenIssueData = [];
        json[] ClosedIssueData = [];
        json[] IssueCountsJson = <json[]>jsonutils:fromTable(IssueCounts);
        while(iterator < IssueCountsJson.length()) {
            json openIssue = {
                date : IssueCountsJson[iterator].DATE.toString(),
                count: IssueCountsJson[iterator].OPEN_ISSUES.toString()
            };
            json closedIssue = {
                date : IssueCountsJson[iterator].DATE.toString(),
                count: IssueCountsJson[iterator].CLOSED_ISSUES.toString()
            };
            OpenIssueData[iterator] = openIssue;
            ClosedIssueData[iterator] = closedIssue;
            iterator = iterator + 1;
        }
        json[] IssueCountDetail = [
            {
                name: "Open Issues",
                data: OpenIssueData
            },
            {
                name: "Closed Issues",
                data: ClosedIssueData
            }
            ];
        return IssueCountDetail;
    } else {
        log:printError("Error occured while retrieving the issues count from Database");
    }
    return [];
}

function retrieveIssueAgingDetails() returns json[]{
    var AgingDetails = GithubDb->select("SELECT DISTINCT(GITHUB_ID), DATEDIFF(CURDATE(), CAST(CREATED_DATE AS DATE)) as OPEN_DAYS FROM ENGAPP_GITHUB_ISSUES WHERE ISSUE_TYPE LIKE 'ISSUE' AND CLOSED_DATE IS NULL", ());
    if (AgingDetails is table< record {}>) {
        json[] AgingDetailsJson = <json[]>jsonutils:fromTable(AgingDetails);
        int iterator = 0;
        int day = 0;
        int week = 0;
        int month = 0;
        int month3 = 0;
        int morethan = 0;
        while(iterator < AgingDetailsJson.length()) {
            int openDays = <int>AgingDetailsJson[iterator].OPEN_DAYS;
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
        json[] openDaysCount = [["1 Day", day], ["1 Week", week], ["1 Month" ,month], ["3 Months", month3], ["More than 3 months", morethan]];
        return openDaysCount;
    } else {
        log:printError("Error occured while tetrieving the issues aging details to the Database");
    }
    return [];
}
function openIssuesAgingForTeam() returns json[]{
    json[] data = [];
    json[] teams = retrieveAllTeams();
    io:println(teams.toString());
    json[] issuesForTeams  = [];
    int teamIterator = 0;
    while(teamIterator < teams.length()) {
        int day = 0;
        int week = 0;
        int month = 0;
        int month3 = 0;
        int morethan = 0;
        int repoIterator = 0;
        json[] repositories = retrieveAllReposByTeam(<int> teams[teamIterator].TeamId);
        while (repoIterator < repositories.length()) {
            json[] prs = retrieveOpendaysForIssues(<int>repositories[repoIterator].RepoId);
            io:println(prs.toString());
            int prIterator = 0;
            while (prIterator < prs.length()) {
                int openDays = <int>prs[prIterator].OPEN_DAYS;
                io:println(openDays);
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
            repoIterator = repoIterator + 1;
        }
        json teamData = {
            name : teams[teamIterator].TeamName.toString(),
            data : [["1 Day" , day] , ["1 week", week] , ["1 month", month], ["month 3" , month3], ["morethan 3 months", morethan]]
        };
        io:println(teamData.toString());
        data.push(teamData);
        teamIterator = teamIterator + 1;
    }
    return data;
}

function openIssuesAgingForLabels() returns json[]{
    json[] data = [];
    json[] repos = retrieveAllRepos();
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
            json[] prs = retrieveOpendaysForIssues(<int> repos[repoIterator].RepoId);
            int prIterator = 0;
            while (prIterator < prs.length()) {
                int openDays = <int>prs[prIterator].OPEN_DAYS;
                io:println(openDays);
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
            repoIterator = repoIterator + 1;
        }
        json teamData = {
            name : labels[labelIterator],
            data : [["1 Day" , day] , ["1 week", week] , ["1 month", month], ["month 3" , month3], ["morethan 3 months", morethan]]
        };
        io:println(teamData.toString());
        data.push(teamData);
        labelIterator = labelIterator + 1;
    }
    return data;
}



