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

import ballerina/http;
import ballerina/log;
//listener http:Listener httpListener = new(9091);


@http:ServiceConfig {
    basePath: "/gitIssues",
    cors : {
        allowOrigins: ["*"]
    }
}
service githubIssueService on httpListener {

    @http:ResourceConfig {
            methods: ["GET"],
            path: "/issueCount"
        }
        resource function getIssueCount (http:Caller httpCaller, http:Request request) {
            // Initialize an empty http response message
            http:Response response = new;
            // Invoke retrieveData function to retrieve data from mysql database
            var allGitIssueCount = getDetailsOfIssue();
            // Send the response back to the client with the git issue data
            response.setPayload( allGitIssueCount);
            var respondRet = httpCaller->respond(response);
            if (respondRet is error) {
                // Log the error for the service maintainers.
                log:printError("Error responding to the client", err = respondRet);
            }
            }

}

