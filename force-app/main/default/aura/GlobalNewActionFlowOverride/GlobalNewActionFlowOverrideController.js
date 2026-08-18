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
      var routeResult;
      var flowApiName;
      var flow;

      if (state !== "SUCCESS") {
        setErrorState(
          "Routing Lookup Error",
          "Unable to resolve a routing map for this object."
        );
        return;
      }

      routeResult = response.getReturnValue() || {};
      flowApiName = routeResult.flowApiName;

      if (routeResult.errorCode === "NO_OBJECT") {
        setErrorState("No Object Passed", routeResult.errorMessage);
        return;
      }

      if (routeResult.errorCode === "NO_ROUTE") {
        setErrorState("No Routing Map Found", routeResult.errorMessage);
        return;
      }

      if (routeResult.errorCode === "INVALID_ROUTE") {
        setErrorState(
          "Invalid Routing Map Configuration",
          routeResult.errorMessage
        );
        return;
      }

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
    var flowErrorOutputName;
    var hasFlowError;
    var outputName;
    var newRecordId;
    var flowRuntimeError;
    var flowRuntimeMessage;

    if (status === "FINISHED" || status === "FINISHED_SCREEN") {
      outputVariables = event.getParam("outputVariables") || [];
      flowErrorOutputName = component.get("v.flowErrorOutputName");
      hasFlowError = helper.getOutputVariableValue(
        outputVariables,
        flowErrorOutputName
      );

      if (
        hasFlowError === true ||
        hasFlowError === "true" ||
        hasFlowError === "TRUE"
      ) {
        component.set("v.hasError", true);
        component.set("v.errorTitle", "Flow Error");
        component.set(
          "v.errorMessage",
          "The routed flow encountered an error and could not complete."
        );
        return;
      }

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
      flowRuntimeError =
        event.getParam("error") ||
        event.getParam("message") ||
        event.getParam("faultMessage");
      flowRuntimeMessage =
        flowRuntimeError && typeof flowRuntimeError === "object"
          ? flowRuntimeError.message
          : flowRuntimeError;

      component.set("v.hasError", true);
      component.set("v.errorTitle", "Flow Error");
      component.set(
        "v.errorMessage",
        flowRuntimeMessage ||
          "The routed flow encountered an error and could not complete."
      );
    }
  }
});
