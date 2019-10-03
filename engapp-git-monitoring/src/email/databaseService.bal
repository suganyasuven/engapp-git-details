import ballerina/config;
import ballerina/io;
import ballerina/jsonutils;
import ballerina/log;
import ballerinax/java.jdbc;

jdbc:Client GithubDb = new ({
    url: "jdbc:mysql://localhost:3306/WSO2_ORGANIZATION_DETAILS",
    username: config:getAsString("UserName"),
    password: config:getAsString("Password"),
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
    int NumberOpenPRs;

};

type PR record {
    string TeamName;
    string RepoName;
    string GithubId;
    string CreatedDate;
    string UpdatedDate;
    string CreatedBy;
    string url;
    string labels;
};

function retrieveAllTeams() returns json[] {
    var Teams = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_TEAMS", Team);
    if (Teams is table<Team>) {
        json TeamJson = jsonutils:fromTable(Teams);
        return <json[]>TeamJson;
    } else {
        log:printError("Error occured while retrieving the organization details from Database", err = Teams);
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

function retrieveAllIssuesByRepoId(int RepoId) returns json[] {

    string pr = "PR";
    var issues = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_ISSUES WHERE REPO_ID=? AND ISSUE_TYPE=? AND CLOSED_DATE IS NULL", (), RepoId, pr);

    if (issues is table<record {}>) {
        json IssueJson = jsonutils:fromTable(issues);
        return <json[]>IssueJson;
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = issues);
    }
    return [];
}

function openPrsForTeam(int teamId, string teamName) returns json[]{
    json[] repositories = retrieveAllReposByTeam(teamId);
    json[] issuesForTeams  = [];
    table<PR> PRtable = table {
            { TeamName, RepoName, GithubId, CreatedDate, UpdatedDate, CreatedBy, url, labels},
            []
        };
    int repoIterator = 0;
    while (repoIterator < repositories.length()) {
        int RepoId = <int>repositories[repoIterator].RepoId;
        json[] prs = retrieveAllIssuesByRepoId(RepoId);
        int prIterator = 0;
        while (prIterator < prs.length()) {
            PR pr = {
                TeamName: teamName,
                RepoName: repositories[repoIterator].RepoName.toString(),
                GithubId: prs[prIterator].GITHUB_ID.toString(),
                CreatedDate: prs[prIterator].CREATED_DATE.toString(),
                UpdatedDate: prs[prIterator].UPDATED_DATE.toString(),
                CreatedBy: prs[prIterator].CREATED_BY.toString(),
                url: prs[prIterator].HTML_URL.toString(),
                labels: prs[prIterator].LABELS.toString()
            };
            var ret = PRtable.add(pr);
            if (ret is ()) {
                io:println("Adding record to table successful");
            } else {
                io:println("Adding to table failed: ", ret.reason());
            }
            prIterator=prIterator+1;
        }
        repoIterator = repoIterator + 1;
    }
    json prJson = jsonutils:fromTable(PRtable);
    return <json[]>prJson;
}