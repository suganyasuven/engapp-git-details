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

string mail_subject = "[Open Pr's] Open Pull Requests: " + updatedDate;
string mail_template = html_header + template_header + table_content + date_content + template_footer + html_footer;

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
