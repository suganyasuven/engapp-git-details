public function generateContent(json[] data) returns string {
    int dataIterator = 0;
    string tableData = "";
    while(dataIterator < data.length()) {
        tableData = tableData +
        "<tr><td>" + data[dataIterator].TeamName.toString() + "</td>" +
        "<td>" + data[dataIterator].RepoName.toString() + "</td>" +
        "<td>" + data[dataIterator].GithubId.toString() + "</td>" +
        "<td>" + data[dataIterator].CreatedDate.toString() + "</td>" +
        "<td>" + data[dataIterator].UpdatedDate.toString() + "</td>" +
        "<td>" + data[dataIterator].CreatedBy.toString() + "</td>" +
        "<td>" + data[dataIterator].url.toString() + "</td>" +
        "<td>" + data[dataIterator].labels.toString() + "</td></tr>";
        dataIterator = dataIterator + 1;
    }
    return tableData;
}

public function generateTable() returns string {
    json[] teams = retrieveAllTeams();
    int teamIterator = 0;
    string tableForTeam = "";
    while(teamIterator < teams.length()) {
        int teamId = <int> teams[teamIterator].TeamId;
        string teamName = teams[teamIterator].TeamName.toString();
        json[] data = openPrsForTeam(teamId, teamName);
            string tableTitlediv = string `<div id = "title">` + teamName + "</div>";
            tableForTeam = tableForTeam + tableTitlediv + table_heading + generateContent(data) + "</table>";
            teamIterator = teamIterator + 1;
        }
    return tableForTeam;
}