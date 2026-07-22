@IsTest
private class GlobalNewFlowRouteCtrlTest {
  @IsTest
  static void returnsNoObjectErrorWhenObjectApiNameIsBlank() {
    Test.startTest();
    GlobalNewFlowRouteCtrl.FlowRouteResolutionResult result = GlobalNewFlowRouteCtrl.getFlowApiNameForObject(
      ''
    );
    Test.stopTest();

    System.assertEquals(
      'NO_OBJECT',
      result.errorCode,
      'Blank object API name should return a NO_OBJECT error.'
    );
    System.assertEquals(
      null,
      result.flowApiName,
      'Blank object API name should not return a flow API name.'
    );
  }

  @IsTest
  static void returnsNoRouteErrorWhenNoRouteExists() {
    Test.startTest();
    GlobalNewFlowRouteCtrl.FlowRouteResolutionResult result = GlobalNewFlowRouteCtrl.getFlowApiNameForObject(
      'No_Such_Object__c'
    );
    Test.stopTest();

    System.assertEquals(
      'NO_ROUTE',
      result.errorCode,
      'Unknown object API name should return a NO_ROUTE error.'
    );
    System.assertEquals(
      null,
      result.flowApiName,
      'Unknown object API name should not return a flow API name.'
    );
  }

  @IsTest
  static void returnsFlowOrInvalidRouteForConfiguredRoute() {
    List<Global_New_Action_Flow_Route__mdt> routes = [
      SELECT Object_Api_Name__c, Flow_Api_Name__c
      FROM Global_New_Action_Flow_Route__mdt
      WHERE Is_Active__c = TRUE
      LIMIT 1
    ];

    if (routes.isEmpty()) {
      return;
    }

    Test.startTest();
    GlobalNewFlowRouteCtrl.FlowRouteResolutionResult result = GlobalNewFlowRouteCtrl.getFlowApiNameForObject(
      routes[0].Object_Api_Name__c
    );
    Test.stopTest();

    if (GlobalNewFlowRouteCtrl.isFlowActive(routes[0].Flow_Api_Name__c)) {
      System.assertEquals(
        routes[0].Flow_Api_Name__c,
        result.flowApiName,
        'Matched route should return the mapped flow API name when flow exists and is active.'
      );
      System.assertEquals(
        null,
        result.errorCode,
        'Active mapped flows should not return an error code.'
      );
      return;
    }

    System.assertEquals(
      'INVALID_ROUTE',
      result.errorCode,
      'Inactive or missing mapped flows should return INVALID_ROUTE.'
    );
    System.assertEquals(
      null,
      result.flowApiName,
      'Inactive or missing mapped flows should not be returned.'
    );
  }

  @IsTest
  static void reportsInactiveForUnknownFlowName() {
    Test.startTest();
    Boolean isFlowActive = GlobalNewFlowRouteCtrl.isFlowActive(
      'No_Such_Flow_' + DateTime.now().getTime()
    );
    Test.stopTest();

    System.assertEquals(
      false,
      isFlowActive,
      'Unknown flows should not be considered active.'
    );
  }
}
