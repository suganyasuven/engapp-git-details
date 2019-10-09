import ballerina/http;
import ballerina/log;
import ballerina/task;
import ballerina/io;


http:Client gitClientEP = new("https://api.github.com" ,
                         config = {
                             followRedirects:{
                              enabled: true,
                              maxCount: 5
                         }});

public function main() {
    //updateReposTable();
    //getAllIssues();

    var hhh=getDetailsOfIssue();
    io:print(hhh);

}
