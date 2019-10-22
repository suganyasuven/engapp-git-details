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

//Generates the issue details content for each team for mail template

import ballerina/log;

public function generateContent(json[] data) returns string {
     string tableData = "";
     foreach var datum in data {
        tableData = tableData +
        "<tr><td align=\"center\">" + datum.teamName.toString() + "</td>" +
        "<td align=\"center\">" + datum.repoName.toString() + "</td>" +
        "<td align=\"center\">" + datum.updatedDate.toString() + "</td>" +
        "<td align=\"center\">" + datum.createdBy.toString() + "</td>" +
        "<td align=\"left\">" + datum.url.toString() + "</td>" +
        "<td align=\"right\">" + datum.openDays.toString() + "</td>" +
        "<td align=\"center\">" + datum.labels.toString() + "</td></tr>";
    }
    return tableData;
}

//Generates the summary table content for issue counts for each team for mail template
public function generateTable() returns string {
    var teams = retrieveAllTeams();
    string summaryTable = "";
    string tableForTeam = "";
    if(teams is json[]) {
        int teamIterator = 0;
        foreach var team in teams {
            int teamId = <int> team.TEAM_ID;
            string teamName = team.TEAM_NAME.toString();
            var data = openPrsForTeam(teamId, teamName);
            if (data is json[]) {
                summaryTable = summaryTable + "<tr><td>" + teamName + "</td><td align=\"center\">" + data.length().toString() + "</td></tr>";
                string tableTitlediv = string `<div id = "title">` + teamName + "</div>";
                tableForTeam = tableForTeam + tableTitlediv + tableHeading + generateContent(data) + "</table>";
            } else {
                log:printError("Error occured while retrieving the issue details from Database", data);
            }
        }
    } else {
        log:printError("Error occured while retrieving the issue details from Database", teams);
    }
    return summaryTable + "</table></div>" + tableTitle + tableForTeam;
}
