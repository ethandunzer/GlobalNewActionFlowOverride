// eslint-disable-next-line no-unused-expressions
({
  doInit: function (component) {
    var objectApiName = component.get("v.sObjectName");
    var action = component.get("c.getFlowApiNameForObject");
    var setErrorState = function (title, message) {
      component.set("v.hasError", true);
      component.set("v.errorTitle", title);
      component.set("v.errorMessage", message);
    };

    if (!objectApiName) {
      setErrorState(
        "No Object Passed",
        "No object API name was provided to this action override."
      );
      return;
    }

    action.setParams({
      objectApiName: objectApiName
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      var flowApiName;
      var flow;

      if (state !== "SUCCESS") {
        setErrorState(
          "Routing Lookup Error",
          "Unable to resolve a routing map for this object."
        );
        return;
      }

      flowApiName = response.getReturnValue();

      if (!flowApiName) {
        setErrorState(
          "No Routing Map Found",
          "No active routing map was found for this object. Please contact your administrator to set up a routing map."
        );
        return;
      }

      component.set("v.flowApiName", flowApiName);
      flow = component.find("newActionFlow");
      try {
        flow.startFlow(flowApiName);
      } catch (startFlowError) {
        setErrorState(
          "Invalid Routing Map Configuration",
          "The routing map contains an incorrect object or flow API name." +
            (startFlowError && startFlowError.message
              ? " " + startFlowError.message
              : "")
        );
      }
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
      component.set("v.hasError", true);
      component.set("v.errorTitle", "Invalid Routing Map Configuration");
      component.set(
        "v.errorMessage",
        "The routed flow failed to load. Verify the routing map object and flow API names."
      );
    }
  }
});
