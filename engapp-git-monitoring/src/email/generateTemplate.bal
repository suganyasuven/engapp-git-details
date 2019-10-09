import ballerina/time;

string html_header = string `
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
        width: 100%;
        margin: 20px;
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
        text-align: left;
        background-color: #cecece;
        color: #044767;
      }
    </style>
  </head>
  <body>
 `;

string template_header = string `
   <div id = "headings">
       GitHub Open Pull Request Analyzer
   </div>
   <div id = "subhead">
     Daily Update of GitHub Open Pull Requests on Teams
   </div>
   <table id="openprs">
   <tr>
    <th>team Names</th>
    <th>No of Open PRs</th>
   </tr>
`;

string table_title = string `</table>
                                <div id = "subhead">
                                    Details of Open Pull Requests
                                </div>`;

string table_heading = string `
       <table id="openprs">
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

string table_content = generateTable();
string updatedTime = time:toString(time:currentTime());
string updatedDate = updatedTime.substring(0,10);
string date_content = string `
                         <div id = "subhead">
                             Updated Time <br/>`
                             + updatedDate + "</div><br/>";

string template_footer = string `
    <div align = center>
        <img src="https://upload.wikimedia.org/wikipedia/en/5/56/WSO2_Software_Logo.png" width="90" height="37" style="display: block; border: 0px;>
        <p align="center" >
            Copyright (c) 2019 | WSO2 Inc.<br/>All Right Reserved.
        </p>
    </div>
`;



string html_footer = string `
    </body>
    </html> `;