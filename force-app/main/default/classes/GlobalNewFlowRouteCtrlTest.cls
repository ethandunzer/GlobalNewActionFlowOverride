@IsTest
private class GlobalNewFlowRouteCtrlTest {
    @IsTest
    static void returnsNullWhenObjectApiNameIsBlank() {
        Test.startTest();
        String flowApiName = GlobalNewFlowRouteCtrl.getFlowApiNameForObject('');
        Test.stopTest();

        System.assertEquals(null, flowApiName, 'Blank object API name should return null.');
    }

    @IsTest
    static void returnsNullWhenNoRouteExists() {
        Test.startTest();
        String flowApiName = GlobalNewFlowRouteCtrl.getFlowApiNameForObject('No_Such_Object__c');
        Test.stopTest();

        System.assertEquals(null, flowApiName, 'Unknown object API name should return null.');
    }

    @IsTest
    static void returnsFlowApiNameWhenActiveRouteExists() {
        List<Global_New_Action_Flow_Route__mdt> routes = [
            SELECT Object_Api_Name__c, Flow_Api_Name__c
            FROM Global_New_Action_Flow_Route__mdt
            WHERE Is_Active__c = true
            LIMIT 1
        ];

        if (routes.isEmpty()) {
            return;
        }

        Test.startTest();
        String flowApiName = GlobalNewFlowRouteCtrl.getFlowApiNameForObject(routes[0].Object_Api_Name__c);
        Test.stopTest();

        System.assertEquals(
            routes[0].Flow_Api_Name__c,
            flowApiName,
            'Matched active route should return the mapped flow API name.'
        );
    }
}