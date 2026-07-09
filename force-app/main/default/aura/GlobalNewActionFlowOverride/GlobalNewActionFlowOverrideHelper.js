({
    getOutputVariableValue: function (outputVariables, variableName) {
        for (var i = 0; i < outputVariables.length; i += 1) {
            if (outputVariables[i].name === variableName) {
                return outputVariables[i].value;
            }
        }

        return null;
    },

    navigateToRecord: function (recordId) {
        var navigateToSObject = $A.get("e.force:navigateToSObject");

        if (!navigateToSObject) {
            return;
        }

        navigateToSObject.setParams({
            recordId: recordId
        });
        navigateToSObject.fire();
    },

    navigateToObjectHome: function (component) {
        var objectApiName = component.get("v.sObjectName");
        var navigateToObjectHome = $A.get("e.force:navigateToObjectHome");

        if (!navigateToObjectHome || !objectApiName) {
            return;
        }

        navigateToObjectHome.setParams({
            scope: objectApiName
        });
        navigateToObjectHome.fire();
    }
});