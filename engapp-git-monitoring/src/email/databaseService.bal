import ballerina/config;
import ballerina/io;
import ballerina/jsonutils;
import ballerina/log;
import ballerinax/java.jdbc;

jdbc:Client GithubDb = new ({
    url: "jdbc:mysql://localhost:3306/WSO2_ORGANIZATION_DETAILS",
    username: config:getAsString("UNAME"),
    password: config:getAsString("PASS"),
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

function getDetailsOfOpenPRs() {
    json[] teamJson = retrieveAllTeams();
    io:println("teamJson", teamJson);
    int teamIterator = 0;
    while (teamIterator < teamJson.length()) {
        int team_id = <int>teamJson[teamIterator].TeamId;
        int i = 0;
        int repoIterator = 0;
        io:println("team_id", team_id);
        json[] repositories = retrieveAllReposByTeam(team_id);
        while (repoIterator < repositories.length()) {
            int no_of_open_pr = 0;
            int prIterator=0;
            int RepoId = <int>repositories[repoIterator].RepoId;
            json[] issues1 = retrieveAllIssuesByRepoId(RepoId);
            while (prIterator < issues1.length()){
                string team_name=teamJson[teamIterator].TeamName.toString();
                string repo_name=repositories[repoIterator].RepoName.toString();
                string github_id = issues1[prIterator].GITHUB_ID.toString();
                string create_date=issues1[prIterator].CREATED_DATE.toString();
                string updated_date=issues1[prIterator].UPDATED_DATE.toString();
                string created_by=issues1[prIterator].CREATED_BY.toString();
                string html_url=issues1[prIterator].HTML_URL.toString();
                string labels=issues1[prIterator].LABELS.toString();
                string assignee=issues1[prIterator].ASSIGNEES.toString();
                prIterator=prIterator+1;

            }
            no_of_open_pr = issues1.length();
            i = i + no_of_open_pr;
            repoIterator = repoIterator + 1;
         }
        teamIterator = teamIterator + 1;
     }
}
