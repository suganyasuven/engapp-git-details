import ballerinax/java.jdbc;
import ballerina/config;
import ballerina/log;
import ballerina/jsonutils;
import ballerina/io;

jdbc:Client GithubDb = new({
        url: "jdbc:mysql://localhost:3306/WSO2_ORGANIZATION_DETAILS",
        username: config:getAsString("UserName"),
        password: config:getAsString("Password"),
        poolOptions: { maximumPoolSize: 10 },
        dbOptions: { useSSL: false }
    });

type Organization record {
    int OrgId;
    string GitUuid;
    string OrgName;
};

type Repo record {
    int RepoId;
    string GitUuid;
    string RepoName;
    int OrgId;
    string url;
    int TeamId;
};

function retrieveAllOrganizations() returns json[] {
    var Organizations = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_ORGANIZATIONS", Organization);
    if (Organizations is table<Organization>) {
        json OrganizationJson = jsonutils:fromTable(Organizations);
            return <json[]>OrganizationJson;
    } else {
        log:printError("Error occured while retrieving the organization details from Database", err = Organizations);
    }
    return [];
}

function retrieveAllReposDetails() returns json[] {
    var Repositorys = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_REPOS", Repo);
    if (Repositorys is table<Repo>) {
        json Repositorysjson = jsonutils:fromTable(Repositorys);
        return <json[]>Repositorysjson;
    } else {
        log:printError("Error occured while retrieving the product names from Database", err = Repositorys);
    }
    return [];
}

function retrieveAllRepos(int OrgId) returns json[] {
    var Repos = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_REPOS WHERE ORG_ID=?", Repo , OrgId);
    if (Repos is table<Repo>) {
        json RepoJson = jsonutils:fromTable(Repos);
            return <json[]>RepoJson;
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = Repos);
    }
    return [];
}

function getIssueLabels(json[] issueLabels) returns string {
    int i = 0;
    int numOfLabels = issueLabels.length();
    string labelss = "";
    while (i < numOfLabels) {
        string lab = issueLabels[i].name.toString();
        labelss = lab + "," + labelss;
        i = i + 1;
    }
    return labelss;
}

function GetIssueAssignees(json[] issueAssignees) returns string {
    int i = 0;
    int numOfAssignees = issueAssignees.length();
    string Assignees = "";
    while (i < numOfAssignees) {
        string Assinee = issueAssignees[i].login.toString();
        Assignees = Assinee + "," + Assignees;
        i = i + 1;
    }
    return Assignees;
}

function retrieveLastUpdatedDate() returns string {
    var LastUpdatedDate = GithubDb->select("SELECT DATE_FORMAT(UPDATED_DATE, '%Y-%m-%dT%TZ') as date FROM ENGAPP_GITHUB_ISSUES", ());
    if (LastUpdatedDate is table< record {}>) {
        json[] LastUpdatedDateJson = <json[]> jsonutils:fromTable(LastUpdatedDate);
            return  LastUpdatedDateJson[0].date.toString();

    } else {
        log:printError("Error occured while retrieving the last updated date from Database", err = LastUpdatedDate);
    }
    return "null";
}

function insertIntoReposTable(json[] response, int orgId) {
    int repoIterator = 0;
     while (repoIterator < response.length()) {
        boolean flag = true;
        string gitUuid = response[repoIterator].id.toString();
        string repoName = response[repoIterator].name.toString();
        string url = response[repoIterator].html_url.toString();
        int teamId = 1;
        json[] RepoUUIDsJson = retrieveAllRepos(orgId);
        int UUIDIterator = 0;
        while (UUIDIterator < RepoUUIDsJson.length()) {
            if(gitUuid == RepoUUIDsJson[UUIDIterator].GitUuid.toString()){
                flag = false;
                if (repoName != RepoUUIDsJson[UUIDIterator].REPO_NAME.toString() || url != RepoUUIDsJson[UUIDIterator].URL.toString()) {
                                    var ret = GithubDb->update("UPDATE  ENGAPP_GITHUB_REPOS SET REPO_NAME=?,URL=? WHERE GITHUB_UUID=?", repoName, url, gitUuid);
                 }
             }
            UUIDIterator = UUIDIterator + 1;
        }
        if(flag){
           var ret = GithubDb->update("INSERT INTO ENGAPP_GITHUB_REPOS(GITHUB_ID, REPO_NAME, ORG_ID, URL, TEAM_ID) Values (?,?,?,?,?)",
                                gitUuid, repoName, orgId, url, teamId);
           handleUpdate(ret, "Inserted to the repo table with variable parameters");
        }
        repoIterator = repoIterator + 1;
    }
}

function insertIntoIssueTable(json[] response, int repoId) {
    int repoIterator = 0;
    string types;
    json[] RepoUUIDsJson = [];
    while (repoIterator < response.length()) {
        io:println("Count: ", repoIterator);
        io:println("REPOID: ", repoId);
        jdbc:Parameter createdTime = { sqlType: jdbc:TYPE_DATETIME, value: response[repoIterator].created_at.toString()};
        jdbc:Parameter updatedTime = { sqlType: jdbc:TYPE_DATETIME, value: response[repoIterator].created_at.toString()};
        jdbc:Parameter closedTime = { sqlType: jdbc:TYPE_DATETIME, value: response[repoIterator].created_at.toString()};
        string html_url = response[repoIterator].html_url.toString();
        string github_id = response[repoIterator].id.toString();
        var issueLabels = response[repoIterator].labels;
        string issuelab = "";
        if (issueLabels is json)
        {
            issuelab = getIssueLabels(<json[]>issueLabels);
        }
        var issueAssignee = response[repoIterator].assignees;
        string issueAss = "";
        if (issueAssignee is json)
        {
            issueAss = GetIssueAssignees(<json[]>issueAssignee);
        }
        int? index = html_url.indexOf("pull");
        if (index is int) {
            types = "PR";
        }
        else {
            types = "issues";
        }
        int repo_Id = repoId;
        string createdby = response[repoIterator].user.login.toString();
        var ret = GithubDb->update("INSERT INTO ENGAPP_GITHUB_ISSUES(GITHUB_ID,REPO_ID,CREATED_DATE,UPDATED_DATE,CLOSED_DATE,
          CREATED_BY,ISSUE_TYPE,HTML_URL,LABELS,ASSIGNEES) Values (?,?,?,?,?,?,?,?,?,?)", github_id, repo_Id, createdTime, updatedTime, closedTime, createdby, types, html_url, issuelab, issueAss);
        handleUpdate(ret, "Insert to the repo table with variable parameters");
        repoIterator = repoIterator + 1;
    }
}

function updateOrgId (json[] repoJson, int orgId) {
    int id =-1;
    int UUIDIterator = 0;
    json[] RepoUUIDsJson =retrieveAllRepos(orgId);
    while (UUIDIterator < RepoUUIDsJson.length()){
        int repoIterator = 0;
        boolean exists = true;
        while (repoIterator < repoJson.length()) {
            if(RepoUUIDsJson[UUIDIterator].GitUuid.toString() == repoJson[repoIterator].id.toString()) {
                    exists = false;
            }
            repoIterator = repoIterator + 1;
        }
        if(exists) {
            var ret = GithubDb->update("UPDATE ENGAPP_GITHUB_REPOS SET ORG_ID=? WHERE GITHUB_ID=?",id,RepoUUIDsJson[UUIDIterator].GITHUB_UUID.toString());
            handleUpdate(ret, "Updated the repo table with variable parameters");
        }
        UUIDIterator = UUIDIterator + 1;
    }
}

function isIssueExist (string issue_id) returns boolean {
    var issue = GithubDb->select("SELECT * FROM ENGAPP_GITHUB_ISSUES WHERE GITHUB_ID=?",(),issue_id);
    if (issue is table<record {}>) {
        json issueJson = jsonutils:fromTable(issue);
        if(issueJson.toString() != ""){
            return true;
        }
    } else {
        log:printError("Error occured while retrieving the repo details from Database", err = issue);
    }
    return false;
}

function handleUpdate(jdbc:UpdateResult|jdbc:Error status, string message) {
    if (status is jdbc:UpdateResult) {
           log:printInfo(message);
    }
    else {
        log:printInfo("Failed to update!");
    }
}
