public with sharing class GlobalNewFlowRouteCtrl {
  private static final String FLOW_STATUS_ACTIVE = 'Active';
  private static final String FLOW_DEFINITION_ACTIVE_VERSION_QUERY = 'SELECT ActiveVersionId FROM FlowDefinition WHERE DeveloperName = :flowApiName LIMIT 1';
  private static final String FLOW_ACTIVE_QUERY = 'SELECT Id FROM Flow WHERE DeveloperName = :flowApiName AND Status = :flowStatus LIMIT 1';

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

    Map<String, Object> bindVariables = new Map<String, Object>{
      'flowApiName' => flowApiName
    };

    try {
      List<SObject> flowDefinitions = Database.queryWithBinds(
        FLOW_DEFINITION_ACTIVE_VERSION_QUERY,
        bindVariables,
        AccessLevel.USER_MODE
      );
      return !flowDefinitions.isEmpty() &&
        flowDefinitions[0].get('ActiveVersionId') != null;
    } catch (QueryException e) {
      System.debug(
        LoggingLevel.WARN,
        'FlowDefinition query unavailable; falling back to Flow query.'
      );
      try {
        bindVariables.put('flowStatus', FLOW_STATUS_ACTIVE);
        List<SObject> activeFlows = Database.queryWithBinds(
          FLOW_ACTIVE_QUERY,
          bindVariables,
          AccessLevel.USER_MODE
        );
        return !activeFlows.isEmpty();
      } catch (QueryException fallbackException) {
        System.debug(
          LoggingLevel.WARN,
          'Flow validation fallback query failed.'
        );
        return false;
      }
    }
  }
}
