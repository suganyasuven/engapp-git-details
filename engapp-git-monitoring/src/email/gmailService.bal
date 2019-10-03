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

string mail_template = html_header + summary_table + table_content + html_footer;

string userId = "me";
gmail:MessageRequest messageRequest = {
   recipient: config:getAsString("RECIPIENT"),
   sender: config:getAsString("SENDER"),
   cc: config:getAsString("CC"),
   subject: "Open PR Analzer",
   messageBody: mail_template,
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
