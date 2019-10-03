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

string summary_table = string `
   <div id = "headings">
       GitHub Open Pull Request Analyzer
   </div>
   <div id = "subhead">
     Daily Update of GitHub Open Pull Requests on WSO2 Organization
   </div>
   <table id="openprs">
     <tr>
       <th>WSO2 Teams</th>
       <th>No of Open PRs</th>
     </tr>
     <tr>
       <td>API Management</td>
       <td>10</td>
     </tr>
     <tr>
       <td>Enterprise Integrator</td>
       <td>45</td>
     </tr>
     <tr>
       <td>Ballerina </td>
       <td>60</td>
     </tr>
     <tr>
       <td>Identity Server</td>
       <td>80</td>
     </tr>
   </table>
   <div id = "subhead">
        Details of Open Pull Requests
   </div>
`;

string table_heading = string `
       <table id="openprs">
         <tr>
           <th>Team Name</th>
           <th>Repo Name</th>
           <th>Github Id</th>
           <th>Created Date</th>
           <th>Updated Date</th>
           <th>Created By</th>
           <th>URL</th>
           <th>Labels</th>
         </tr>
    `;

string table_content = generateTable();
string html_footer = string `
    </body>
    </html> `;

