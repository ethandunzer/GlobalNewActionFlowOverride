public with sharing class GlobalNewFlowRouteCtrl {
  public class FlowRouteResolutionResult {
    @AuraEnabled
    public String flowApiName;
    @AuraEnabled
    public String errorCode;
    @AuraEnabled
    public String errorMessage;
  }

  @AuraEnabled(cacheable=true)
  public static FlowRouteResolutionResult getFlowApiNameForObject(
    String objectApiName
  ) {
    FlowRouteResolutionResult result = new FlowRouteResolutionResult();

    if (String.isBlank(objectApiName)) {
      result.errorCode = 'NO_OBJECT';
      result.errorMessage = 'No object API name was provided to this action override.';
      return result;
    }

    List<Global_New_Action_Flow_Route__mdt> routes = [
      SELECT Flow_Api_Name__c
      FROM Global_New_Action_Flow_Route__mdt
      WHERE Is_Active__c = TRUE AND Object_Api_Name__c = :objectApiName
      LIMIT 1
    ];

    if (routes.isEmpty()) {
      result.errorCode = 'NO_ROUTE';
      result.errorMessage = 'No active routing map was found for this object. Please contact your administrator to set up a routing map.';
      return result;
    }

    result.flowApiName = routes[0].Flow_Api_Name__c;

    if (!isFlowActive(result.flowApiName)) {
      result.flowApiName = null;
      result.errorCode = 'INVALID_ROUTE';
      result.errorMessage =
        'Flow "' +
        routes[0].Flow_Api_Name__c +
        '" is not found or does not have an active version.';
    }

    return result;
  }

  @TestVisible
  private static Boolean isFlowActive(String flowApiName) {
    List<FlowDefinition> flowDefinitions;

    if (String.isBlank(flowApiName)) {
      return false;
    }

    flowDefinitions = [
      SELECT ActiveVersionId
      FROM FlowDefinition
      WHERE DeveloperName = :flowApiName
      LIMIT 1
    ];

    return !flowDefinitions.isEmpty() &&
      flowDefinitions[0].ActiveVersionId != null;
  }
}
