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
2. Route to a flow API name with a switch-based router in [force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideHelper.js](force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideHelper.js).
3. Start that flow.

## Routing Map

Current object-to-flow mappings are defined in getFlowApiNameForObject:

- Opportunity -> Opportunity_Creation_Screen_Flow
- Account -> Account_New_Screen_Flow
- Contact -> Contact_New_Screen_Flow

To scale to more objects, add new case branches in the same switch statement.

## Flow Output Contract

Each routed Screen Flow must expose an output variable named NewRecordId.

- On FINISHED or FINISHED_SCREEN, if NewRecordId is returned, navigate to the created record.
- On FINISHED or FINISHED_SCREEN, if no NewRecordId is returned, navigate to object home.
- On ERROR, navigate to object home.

This logic is implemented in [force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideController.js](force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideController.js) and helper navigation methods in [force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideHelper.js](force-app/main/default/aura/GlobalNewActionFlowOverride/GlobalNewActionFlowOverrideHelper.js).
