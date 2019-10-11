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

public function generateContent(json[] data) returns string {
    int dataIterator = 0;
    string tableData = "";
    while(dataIterator < data.length()) {
        tableData = tableData +
        "<tr><td>" + data[dataIterator].TeamName.toString() + "</td>" +
        "<td>" + data[dataIterator].RepoName.toString() + "</td>" +
        "<td>" + data[dataIterator].UpdatedDate.toString() + "</td>" +
        "<td>" + data[dataIterator].CreatedBy.toString() + "</td>" +
        "<td>" + data[dataIterator].url.toString() + "</td>" +
        "<td align=\"right\">" + data[dataIterator].OpenDays.toString() + "</td>" +
        "<td>" + data[dataIterator].labels.toString() + "</td></tr>";
        dataIterator = dataIterator + 1;
    }
    return tableData;
}

public function generateTable() returns string {
    json[] teams = retrieveAllTeams();
    int teamIterator = 0;
    string summaryTable = "";
    string tableForTeam = "";
    while(teamIterator < teams.length()) {
        int teamId = <int> teams[teamIterator].TeamId;
        string teamName = teams[teamIterator].TeamName.toString();
        json[] data = openPrsForTeam(teamId, teamName);
        summaryTable = summaryTable + "<tr><td>" + teamName + "</td><td align=\"center\">" + data.length().toString() + "</td></tr>";
        string tableTitlediv = string `<div id = "title">` + teamName + "</div>";
        tableForTeam = tableForTeam + tableTitlediv + table_heading + generateContent(data) + "</table>";
        teamIterator = teamIterator + 1;
        }
    return summaryTable + "</table>" + table_title + tableForTeam;
}
