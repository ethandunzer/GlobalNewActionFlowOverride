({
    doInit: function (component, event, helper) {
        var objectApiName = component.get("v.sObjectName");
        var flowApiName = helper.getFlowApiNameForObject(objectApiName);

        if (!flowApiName) {
            helper.navigateToObjectHome(component);
            return;
        }

        component.set("v.flowApiName", flowApiName);
        var flow = component.find("newActionFlow");
        flow.startFlow(flowApiName);
    },

    handleStatusChange: function (component, event, helper) {
        var status = event.getParam("status");

        if (status === "FINISHED" || status === "FINISHED_SCREEN") {
            var outputVariables = event.getParam("outputVariables") || [];
            var outputName = component.get("v.newRecordIdOutputName");
            var newRecordId = helper.getOutputVariableValue(outputVariables, outputName);

            if (newRecordId) {
                helper.navigateToRecord(newRecordId);
                return;
            }

            helper.navigateToObjectHome(component);
            return;
        }

        if (status === "ERROR") {
            helper.navigateToObjectHome(component);
        }
    }
});