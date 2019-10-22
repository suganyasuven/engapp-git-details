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

string htmlHeader = string `
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Open PR Details</title>
      <style>
        #headings {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        width: 100%;
        background-color: #044767;
        color: #fff;
        padding: 10px;
        text-align: center;
        font-weight: 600px;
        font-size: 20px;
        margin-bottom: 10px;
        margin-top: 30px;
      }
        #subhead {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        font-weight: 400px;
        font-size: 18px;
        color: #777777;
        padding: 20px;
        text-align: center;
        margin: 10px;
      }
        #title {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        font-weight: 350px;
        font-size: 16px;
        color: #777777;
        padding: 20px;
        text-align: center;
        margin: 10px;
      }
      #openprs {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        border-collapse: collapse;
        margin: 20px;
        font-weight: 200px;
        font-size: 14px;
      }

      #openprs td, #openprs th {
        border: 1px solid #ddd;
        padding: 8px;
      }

      #openprs tr{
        background-color: #dedede;
      }

      #openprs tr:nth-child(even){background-color: #efefef;}

      #openprs tr:hover {background-color: #ddd;}

      #openprs th {
        padding-top: 12px;
        padding-bottom: 12px;
        text-align: center;
        background-color: #cecece;
        color: #044767;
      }
    </style>
  </head>
  <body>
 `;

string templateHeader = string `
   <div id = "headings">
       GitHub Open Pull Request Analyzer
   </div>
   <div id = "subhead">
     Weekly Update of GitHub Open Pull Requests on Teams
   </div>
   <div align = "center">
   <table id="openprs">
   <tr>
    <th style="width:240px">team Names</th>
    <th style="width:120px">No of Open PRs</th>
   </tr>
`;

string tableTitle = string `</table>
                                <div id = "subhead">
                                    Details of Open Pull Requests
                                </div>`;

string tableHeading = string `
       <table id="openprs" width="100%">
         <tr>
           <th style="width:80px">Team Name</th>
           <th style="width:120px">Repo Name</th>
           <th style="width:70px">Updated Date</th>
           <th style="width:80px">Created By</th>
           <th style="width:240px">URL</th>
           <th style="width:50px">Open Days</th>
           <th style="width:80px">Labels</th>
         </tr>
    `;

string tableContent = generateTable();
string dateContent = string `
                         <div id = "subhead">
                             Updated Time <br/>`
                             + UPDATED_DATE + "</div><br/>";

string templateFooter = string `
    <div align = center>
        <img src="https://upload.wikimedia.org/wikipedia/en/5/56/WSO2_Software_Logo.png" width="90" height="37" style="display: block; border: 0px;>
        <p align="center" >
            Copyright (c) 2019 | WSO2 Inc.<br/>All Right Reserved.
        </p>
    </div>
`;

string htmlFooter = string `
    </body>
    </html> `;