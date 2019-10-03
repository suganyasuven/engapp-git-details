import ballerina/log;
import wso2/gmail;
import ballerina/config;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        accessToken: config:getAsString("ACCESS_TOKEN"),
        refreshConfig: {
            refreshUrl: gmail:REFRESH_URL,
            refreshToken: config:getAsString("REFRESH_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET")
        }
    }
};

string ALERT_MAIL = string `<html>
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

                                  #openprs {
                                    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
                                    border-collapse: collapse;
                                    width: 100%;
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
                              <body class="">
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

                            <div id="root"></div>
                            <script src="https://cdnjs.cloudflare.com/ajax/libs/react/15.4.2/react.js"></script>
                            <script src="https://cdnjs.cloudflare.com/ajax/libs/react/15.4.2/react-dom.js"></script>
                            <script src="https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/6.21.1/babel.min.js"></script>
                            <script type="text/babel">
                            class Greeting extends React.Component {
                                render() {
                                    return (<p>Hello world</p>);
                                }
                            }
                            ReactDOM.render(
                                <Greeting />,
                                document.getElementById('root')
                            );
                            </script>
                            </body>
                            </html>
`;
string userId = "me";
gmail:MessageRequest messageRequest = {
   recipient: config:getAsString("RECIPIENT"),
   sender: config:getAsString("SENDER"),
   cc: config:getAsString("CC"),
   subject: "Open PR Analzer",
   messageBody: ALERT_MAIL,
   contentType:gmail:TEXT_HTML
};

string messageId = "";
string threadId = "";

public function sendPREmail() {
    gmail:Client gmailClient = new(gmailConfig);
    var sendMessageResponse = gmailClient->sendMessage(userId, messageRequest);
    if (sendMessageResponse is [string, string]) {
        // If successful, print the message ID and thread ID.
        [string, string][messageId, threadId] = sendMessageResponse;
        log:printInfo("Sent Message ID: " + messageId);
        log:printInfo("Sent Thread ID: " + threadId);
    } else {
        // If unsuccessful, print the error returned.
        log:printError("Error: ", sendMessageResponse);
    }
}