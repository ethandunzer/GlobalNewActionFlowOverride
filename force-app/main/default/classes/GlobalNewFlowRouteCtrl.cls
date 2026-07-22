public with sharing class GlobalNewFlowRouteCtrl {
  private static final String FLOW_RECORD_QUERY = 'SELECT Id, ApiName, ActiveVersionId FROM FlowRecord WHERE ApiName = :flowApiName LIMIT 1';

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
      String configuredFlowApiName = result.flowApiName;
      result.flowApiName = null;
      result.errorCode = 'INVALID_ROUTE';
      result.errorMessage =
        'Flow "' +
        configuredFlowApiName +
        '" is not found or does not have an active version.';
    }

    return result;
  }

  @TestVisible
  private static Boolean isFlowActive(String flowApiName) {
    if (String.isBlank(flowApiName)) {
      return false;
    }

    try {
      List<SObject> flowRecords = Database.queryWithBinds(
        FLOW_RECORD_QUERY,
        new Map<String, Object>{ 'flowApiName' => flowApiName },
        AccessLevel.USER_MODE
      );
      return !flowRecords.isEmpty() &&
        flowRecords[0].get('ActiveVersionId') != null;
    } catch (QueryException e) {
      System.debug(LoggingLevel.WARN, 'FlowRecord validation query failed.');
      return false;
    }
  }
}
