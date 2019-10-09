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

    string issue = "issues";
    var issues = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_ISSUES WHERE REPO_ID=? AND ISSUE_TYPE=?", (), RepoId, issue);

    if (issues is table<record {}>) {
        json IssueJson = jsonutils:fromTable(issues);
        return <json[]>IssueJson;
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = issues);
    }
    return [];
}

function retrieveAllIssues() returns json[] {

    string issue = "issues";
    var issues = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_ISSUES WHERE  ISSUE_TYPE=? AND CLOSED_DATE IS NULL", (),issue);

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
        io:println("team_id", team_id);
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

        name : teamJson[teamIterator].TeamName.toString(),
        totalIssueCount :<int>TotalIssueCount,
        L1IssueCount :<int>L1issuecount,
        L2IssueCount :<int>L2issuecount,
        L3IssueCount :<int>L3issuecount
     };
     teamIterator = teamIterator + 1;
     }
       return teamIssues;

}


