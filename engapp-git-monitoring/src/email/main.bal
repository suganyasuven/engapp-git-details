import ballerina/log;
import ballerina/task;

public function main() {
    int intervalInMillis = 36000;
    task:Scheduler timer = new({
         intervalInMillis: intervalInMillis,
         initialDelayInMillis: 0
    });

    service DBservice = service {
        resource function onTrigger() {
            sendPREmail();
        }
    };

    var attachResult = timer.attach(DBservice);
    if (attachResult is error) {
        log:printError("Error attaching the service.");
        return;
    }

    var startResult = timer.start();
        if (startResult is error) {
            log:printError("Starting the task is failed.");
            return;
    }
}