# GlobalNewActionFlowOverride

## Overview

GlobalNewActionFlowOverride is an Aura action-override wrapper for the standard New action.
It dynamically launches an object-specific Screen Flow and handles post-flow navigation.

## Bundle Behavior

The component in [force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverride.cmp](force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverride.cmp) implements:

- lightning:actionOverride so it can be selected as an Object Manager override for New.
- force:hasSObjectName to detect the current object API name at runtime.

Initialization is handled in [force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideController.js](force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideController.js):

1. Read sObjectName.
2. Resolve the flow API name via Apex metadata lookup in [force-app/main/default/classes/GlobalNewFlowRouteCtrl.cls](force-app/main/default/classes/GlobalNewFlowRouteCtrl.cls).
3. Start that flow.

If metadata lookup fails, or no active route is found for the object, navigation falls back to object home.

## Routing Map

Current object-to-flow mappings are stored in Custom Metadata records:

- Opportunity -> Opportunity_Creation_Screen_Flow
- Supplier_Assignments__c -> Account_Create_Supplier_Assignment

To scale to more objects, add records in [force-app/main/default/customMetadata](force-app/main/default/customMetadata).

Current route records are:

- [force-app/main/default/customMetadata/Global_New_Action_Flow_Route.Opportunity.md-meta.xml](force-app/main/default/customMetadata/Global_New_Action_Flow_Route.Opportunity.md-meta.xml)
- [force-app/main/default/customMetadata/Global_New_Action_Flow_Route.SupplierAssignments.md-meta.xml](force-app/main/default/customMetadata/Global_New_Action_Flow_Route.SupplierAssignments.md-meta.xml)

## Metadata Configuration

Route configuration is defined by the custom metadata type in [force-app/main/default/objects/Global_New_Action_Flow_Route__mdt/Global_New_Action_Flow_Route__mdt.object-meta.xml](force-app/main/default/objects/Global_New_Action_Flow_Route__mdt/Global_New_Action_Flow_Route__mdt.object-meta.xml) with fields:

- Object_Api_Name__c
- Flow_Api_Name__c
- Is_Active__c

## Flow Output Contract

Each routed Screen Flow must expose an output variable named NewRecordId.

- On FINISHED or FINISHED_SCREEN, if NewRecordId is returned, navigate to the created record.
- On FINISHED or FINISHED_SCREEN, if no NewRecordId is returned, navigate to object home.
- On ERROR, navigate to object home.

This logic is implemented in [force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideController.js](force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideController.js) and helper navigation methods in [force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideHelper.js](force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideHelper.js).

## Presentation Behavior

The flow is rendered in a styled container in [force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverride.cmp](force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverride.cmp) and [force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverride.css](force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverride.css).

- Desktop: centered shell with constrained width.
- Mobile: responsive full-width behavior with reduced padding.
