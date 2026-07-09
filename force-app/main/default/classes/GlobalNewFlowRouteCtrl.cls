public with sharing class GlobalNewFlowRouteCtrl {
    @AuraEnabled(cacheable=true)
    public static String getFlowApiNameForObject(String objectApiName) {
        if (String.isBlank(objectApiName)) {
            return null;
        }

        List<Global_New_Action_Flow_Route__mdt> routes = [
            SELECT Flow_Api_Name__c
            FROM Global_New_Action_Flow_Route__mdt
            WHERE Is_Active__c = true
            AND Object_Api_Name__c = :objectApiName
            LIMIT 1
        ];

        if (routes.isEmpty()) {
            return null;
        }

        return routes[0].Flow_Api_Name__c;
    }
}
