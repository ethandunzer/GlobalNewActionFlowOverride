/* eslint-disable no-unused-expressions */
({
  doInit: function (component, event, helper) {
    var objectApiName = component.get("v.sObjectName");
    var action = component.get("c.getFlowApiNameForObject");

    action.setParams({
      objectApiName: objectApiName
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      var flowApiName;
      var flow;

      if (state !== "SUCCESS") {
        helper.navigateToObjectHome(component);
        return;
      }

      flowApiName = response.getReturnValue();

      if (!flowApiName) {
        component.set("v.noRouteFound", true);
        return;
      }

      component.set("v.flowApiName", flowApiName);
      flow = component.find("newActionFlow");
      flow.startFlow(flowApiName);
    });

    $A.enqueueAction(action);
  },

  handleStatusChange: function (component, event, helper) {
    var status = event.getParam("status");
    var outputVariables;
    var outputName;
    var newRecordId;

    if (status === "FINISHED" || status === "FINISHED_SCREEN") {
      outputVariables = event.getParam("outputVariables") || [];
      outputName = component.get("v.newRecordIdOutputName");
      newRecordId = helper.getOutputVariableValue(outputVariables, outputName);

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
/* eslint-enable no-unused-expressions */
