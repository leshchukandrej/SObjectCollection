## SObjectCollection

The `SObjectCollection` class provides a convenient way to work with collections of Salesforce SObjects.<br>
The base for the service was taken from the github [repository](https://github.com/pkozuchowski/Apex-Opensource-Library/tree/master/force-app/commons/collections) and simplified to the basic functionality to use SObjects only.<br>

It offers methods to extract lists, sets of specific data types, map/group records by specific field, filter collections, and perform other common operations.

### Key Features

1. **List Extraction**: Extract lists of specific field values from a collection of SObjects.
2. **Set Extraction**: Extract sets of specific field values from a collection of SObjects.
3. **Map by Field**: Map records by a specific field value.
4. **Group by Field**: Group records by a specific field value.
5. **Filtering**: Filter collections based on field values or custom conditions.
6. **Safe operation**: The class is designed to handle null values and empty collections.

### Usage

GIVEN:
```apex
List<Opportunity> opportunities = [SELECT Id, Name, Probability, AccountId FROM Opportunity];
```

#### Extracting Sets

Old way:
```apex
Sets<Id> ids = new Sets<Id>();
for (Opportunity opportunity : opportunities) {
    ids.add(opportunity.Id);
}
```

New way:
```apex
Sets<Id> ids = SObjectCollection.of(opportunities).setOfId(Opportunity.Id);
```

Currently Available Set methods:
`setOfId`, `setOfString`, `setOfDecimal`

Currently Available List methods:
`listOfId`, `listOfString`, `listOfDecimal`

#### Mapping by Field

Old way:
```apex
Map<String, Opportunity> opportunityByName = new Map<String, Opportunity>();
for (Opportunity opportunity : opportunities) {
    opportunityByName.put(opportunity.Name, opportunity);
}
```

New way:
```apex
Map<String, Opportunity> opportunityByName = 
    (Map<String, Opportunity>) SObjectCollection.of(opportunities).mapByString(Opportunity.Name);
```

Currently Available Map methods:
`mapById`, `mapByString`, `mapByDecimal`, `mapByInteger`

#### Grouping by Field

Old way:
```apex
Map<Id, List<Opportunity>> opportunitiesByAccountId = new Map<Id, List<Opportunity>>();
for (Opportunity opportunity : opportunities) {
    if (!opportunitiesByAccountId.containsKey(opportunity.AccountId)) {
        opportunitiesByAccountId.put(opportunity.AccountId, new List<Opportunity>());
    }
    opportunitiesByAccountId.get(opportunity.AccountId).add(opportunity);
}
```

New way:
```apex
Map<Id, List<Opportunity>> opportunitiesByAccountId = 
    (Map<Id, List<Opportunity>>) SObjectCollection.of(opportunities).groupById(Opportunity.AccountId);
```

#### Filtering by changed field

In the triggers, it is very important to check if the field was changed before performing any actions.<br>
It reduces the amount of extra steps as well as targets the specific changes only.

Old way:
```apex
List<Opportunity> changedOpportunities = new List<Opportunity>();
for (Opportunity opportunity : opportunities) {
    Opportunity oldOpportunity = Trigger.oldMap.get(opportunity.Id);
    if (opportunity.Probability != oldOpportunity.Probability) {
        changedOpportunities.add(opportunity);
    }
}
```

New way:
```apex
List<Opportunity> changedOpportunities = SObjectCollection.of(opportunities).filterChanged(Trigger.oldMap, Opportunity.Probability);
```

#### Summary
The usage of SObjectCollection is important in the way that it simplifies the code and makes it more readable.<br>
It is also a good practice to use the class in the trigger handlers/services to reduce the amount of code and make it more efficient.<br>
The class is designed to handle null values and empty collections, so it is safe to use in any context.<br>
The most important is avoiding the human errors and making the code more readable and maintainable.<br>
