@IsTest(IsParallel=true)
private class SObjectCollectionTest {

    private static final List<Opportunity> opportunities = new List<Opportunity>{
        newOpportunity(0, new Map<String, Object>{
            'NextStep' => 'Analysis'
        }),
        newOpportunity(1, new Map<String, Object>{
            'NextStep' => 'Analysis'
        }),
        newOpportunity(2, new Map<String, Object>{
            'NextStep' => 'Analysis'
        }),
        newOpportunity(3, new Map<String, Object>{
            'NextStep' => 'Analysis'
        }),
        newOpportunity(4, new Map<String, Object>{
            'NextStep' => 'Deal'
        }),
        newOpportunity(5, new Map<String, Object>{
            'NextStep' => 'Deal'
        }),
        newOpportunity(6, new Map<String, Object>{
            'NextStep' => 'Deal'
        }),
        newOpportunity(7, new Map<String, Object>{
            'NextStep' => 'Support'
        }),
        newOpportunity(8, new Map<String, Object>{
            'NextStep' => 'Support'
        }),
        newOpportunity(9, new Map<String, Object>{
            'NextStep' => 'Support'
        })
    };

    /**
     * Creates new Opportunity with fields prefilled for testing Collections.
     * Opportunity is created through JSON.deserialize, because some fields are not writable through constructor.
     */
    private static Opportunity newOpportunity(Integer i, Map<String, Object> opp) {
        Map<String, Object> oppMap = new Map<String, Object>{
            'Id' => '006' + ('' + i).leftPad(12, '0') + 'AAA',
            'AccountId' => '001' + ('' + Math.mod(i, 3)).leftPad(12, '0') + 'AAA',
            'OwnerId' => '005' + ('' + Math.mod(i, 5)).leftPad(12, '0') + 'AAA',
            'Name' => 'Test Opportunity ' + i,
            'CreatedDate' => Datetime.now().addDays(-i),
            'HasOpenActivity' => Math.mod(i, 2) == 0,
            'LastActivityDate' => Date.today().addDays(-i),
            'Probability' => 1.0 * i / 10,
            'Amount' => i * 100
        };
        oppMap.putAll(opp);

        return (Opportunity) JSON.deserialize(JSON.serialize(oppMap), Opportunity.class);
    }


    /**
     *@description
     * Collections.isNotEmpty() returns "true" when there's any element in the list
     * and "false" when list is null or empty.
     */
    @IsTest
    static void testIsNotEmpty() {
        System.assertEquals(false, SObjectCollection.of(null).isNotEmpty());
        System.assertEquals(false, SObjectCollection.of(new List<Opportunity>()).isNotEmpty());
    }


    /**
     *@description
     * Collections.isEmpty() returns "true" when list is empty or when it's null.
     */
    @IsTest
    static void testIsEmpty() {
        System.assertEquals(true, SObjectCollection.of(null).isEmpty());
        System.assertEquals(true, SObjectCollection.of(new List<Opportunity>()).isEmpty());
    }


    /**
     *@description
     * size() should return the actual size of the collection and 0 if collection is null.
     */
    @IsTest
    static void testSize() {
        System.assertEquals(0, SObjectCollection.of(null).size());
        System.assertEquals(0, SObjectCollection.of(new List<Opportunity>()).size());
        System.assertEquals(opportunities.size(), SObjectCollection.of(opportunities).size());
    }


    @IsTest
    static void testGetters() {
        System.assertEquals(opportunities.get(0), SObjectCollection.of(opportunities).get(0));
        System.assertEquals(opportunities.get(0), SObjectCollection.of(opportunities).getFirst());
        System.assertEquals(opportunities.get(opportunities.size() - 1), SObjectCollection.of(opportunities).getLast());
        System.assertEquals(null, SObjectCollection.of(null).getFirst());
        System.assertEquals(null, SObjectCollection.of(null).getLast());
        System.assertEquals(null, SObjectCollection.of(new List<Opportunity>()).getFirst());
        System.assertEquals(null, SObjectCollection.of(new List<Opportunity>()).getLast());
        System.assertEquals(0, SObjectCollection.of(opportunities).clear().size());
    }

    @IsTest
    static void testAddRemove() {
        SObjectCollection.of(new List<Opportunity>())
            .addAll(opportunities)
            .add(newOpportunity(10, new Map<String, Object>()))
            .add(5, newOpportunity(10, new Map<String, Object>()))
            .remove(0)
            .removeLast();
    }

    /**
     * to Map takes field value from SObjects maps record by the value.
     * Map key has the same type as SObject field.
     */
    @IsTest
    static void testMapByField() {
        Map<Id, Opportunity> expectedIds = new Map<Id, Opportunity>();
        Map<String, Opportunity> expectedStrings = new Map<String, Opportunity>();
        Map<Decimal, Opportunity> expectedDecimals = new Map<Decimal, Opportunity>();
        Map<Integer, Opportunity> expectedIntegers = new Map<Integer, Opportunity>();

        for (Opportunity opp : opportunities) {
            expectedIds.put(opp.AccountId, opp);
            expectedStrings.put(opp.Name, opp);
            expectedDecimals.put(opp.Probability, opp);
            expectedIntegers.put((Integer) opp.Probability, opp);
        }

        Test.startTest();
        Map<Id, SObject> actualIds = SObjectCollection.of(opportunities).mapById(Opportunity.AccountId);
        Map<String, SObject> actualStrings = SObjectCollection.of(opportunities).mapByString(Opportunity.Name);
        Map<Decimal, SObject> actualDecimals = SObjectCollection.of(opportunities).mapByDecimal(Opportunity.Probability);
        Map<Integer, SObject> actualIntegers = SObjectCollection.of(opportunities).mapByInteger(Opportunity.Probability);
        Test.stopTest();


        System.assertEquals(expectedIds, actualIds);
        System.assertEquals(expectedStrings, actualStrings);
        System.assertEquals(expectedDecimals, actualDecimals);
        System.assertEquals(expectedIntegers, actualIntegers);
    }


    /**
     * Reduce to Group should create Map of (Key, List<Value>) where all values in a list had the same key.
     */
    @IsTest
    static void testGroupByField() {
        Map<Id, List<Opportunity>> expectedGroupById = new Map<Id, List<Opportunity>>();
        Map<String, List<Opportunity>> expectedGroupByString = new Map<String, List<Opportunity>>();
        Map<Decimal, List<Opportunity>> expectedGroupByDecimal = new Map<Decimal, List<Opportunity>>();
        Map<Integer, List<Opportunity>> expectedGroupByInteger = new Map<Integer, List<Opportunity>>();

        for (Opportunity opportunity : opportunities) {
            expectedGroupById.put(opportunity.AccountId, addToGroup(expectedGroupById.get(opportunity.AccountId), opportunity));
            expectedGroupByString.put(opportunity.NextStep, addToGroup(expectedGroupByString.get(opportunity.NextStep), opportunity));
            expectedGroupByDecimal.put(opportunity.Probability, addToGroup(expectedGroupByDecimal.get(opportunity.Probability), opportunity));
            expectedGroupByInteger.put((Integer) opportunity.Probability, addToGroup(expectedGroupByInteger.get((Integer) opportunity.Probability), opportunity));
        }

        SObjectCollection opportunityCollection = SObjectCollection.of(opportunities);

        Test.startTest();
        Map<Id, List<SObject>> actualGroupById = opportunityCollection.groupById(Opportunity.AccountId);
        Map<String, List<SObject>> actualGroupByString = opportunityCollection.groupByString(Opportunity.NextStep);
        Map<Decimal, List<SObject>> actualGroupByDecimal = opportunityCollection.groupByDecimal(Opportunity.Probability);
        Map<Integer, List<SObject>> actualGroupByInteger = opportunityCollection.groupByInteger(Opportunity.Probability);
        Test.stopTest();


        System.assertEquals(expectedGroupById, actualGroupById);
        System.assertEquals(expectedGroupByString, actualGroupByString);
        System.assertEquals(expectedGroupByDecimal, actualGroupByDecimal);
        System.assertEquals(expectedGroupByInteger, actualGroupByInteger);
    }

    private static List<Opportunity> addToGroup(List<Opportunity> opps, Opportunity opportunity) {
        List<Opportunity> grouppedOpps = opps == null ? new List<Opportunity>() : opps;
        grouppedOpps.add(opportunity);

        return grouppedOpps;
    }


    @IsTest
    static void testReduceEmptyListToGroupShouldReturnEmptyMap() {
        Map<String, List<SObject>> expected = new Map<String, List<SObject>>();
        Map<String, List<SObject>> actual = SObjectCollection.of(new List<Opportunity>()).groupByString(Opportunity.Name);
        System.assertEquals(expected, actual);
    }


    @IsTest
    static void testFilterByField() {
        List<Opportunity> expected = new List<Opportunity>();

        for (Opportunity opp : opportunities) {
            Boolean accept = (
                opp.NextStep.contains('Analysis')
                    && opp.HasOpenActivity == true
                    && opp.LastActivityDate <= Date.today()
                    && opp.LastActivityDate > Date.today().addDays(-2)
            ) || opp.NextStep != 'Analysis';

            if (accept) {
                expected.add(opp);
            }
        }


        CollectionConditions c = new CollectionConditions();
        Test.startTest();
        List<Opportunity> actual = SObjectCollection.of(opportunities)
            .filter(
                c.ORs(
                    c.ANDs(
                        c.field(Opportunity.NextStep).contains('Analysis'),
                        c.field(Opportunity.HasOpenActivity).equals(true),
                        c.field(Opportunity.LastActivityDate).lessEqualsThan(Date.today()),
                        c.field(Opportunity.LastActivityDate).greaterThan(Date.today().addDays(-2))
                    ),
                    c.field(Opportunity.NextStep).doNot().equals('Analysis')
                )
            )
            .get();

        Test.stopTest();


        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testFilterByField2() {
        List<String> wantedSteps = new List<String>{'Analysis', 'Deal'};
        List<String> unwantedSteps = new List<String>{'Support'};

        List<Opportunity> expected = new List<Opportunity>();
        for (Opportunity opp : opportunities) {
            Boolean accept =
                opp.Name != null
                    && wantedSteps.indexOf(opp.NextStep) > -1
                    && unwantedSteps.indexOf(opp.NextStep) == -1
                    && opp.LastActivityDate < Date.today();

            if (accept) {
                expected.add(opp);
            }
        }

        CollectionConditions c = new CollectionConditions();

        Test.startTest();
        List<Opportunity> actual = SObjectCollection.of(opportunities)
            .filter(
                c.ANDs(
                    c.field(Opportunity.Name).doNot().equals(null),
                    c.field(Opportunity.NextStep).isIn(wantedSteps),
                    c.field(Opportunity.NextStep).doNot().isIn(unwantedSteps),
                    c.field(Opportunity.LastActivityDate).lessThan(Date.today())
                )
            )
            .get();

        Test.stopTest();


        System.assertEquals(expected, actual);
    }

    /**
     * @description
     * Collections.filterByFieldValues filters input records and return only those which field is one of specified values.
     */
    @IsTest
    static void tesFilterByFieldValues() {
        Set<Object> acceptedStages = new Set<Object>{
            'Analysis', 'Deal'
        };
        List<Opportunity> expectedAcceptedOpps = new List<Opportunity>();
        List<Opportunity> expectedRejectedOpps = new List<Opportunity>();

        for (Opportunity opportunity : opportunities) {
            if (acceptedStages.contains(opportunity.StageName)) {
                expectedAcceptedOpps.add(opportunity);
            } else {
                expectedRejectedOpps.add(opportunity);
            }
        }

        List<Opportunity> actualAcceptedOpps = SObjectCollection.of(opportunities).filter(Opportunity.StageName).isIn(acceptedStages).get();
        List<Opportunity> actualRejectedOpps = SObjectCollection.of(opportunities).filter(Opportunity.StageName).doNot().isIn(acceptedStages).get();

        System.assertEquals(expectedAcceptedOpps, actualAcceptedOpps);
        System.assertEquals(expectedRejectedOpps, actualRejectedOpps);
    }

    /**
     * @description
     * Collections.filterByOldFieldValues filters input records and return only those which has previous field value one of specified values.
     */
    @IsTest
    static void testFilterByOldFieldValues() {
        List<Opportunity> oldList = opportunities.deepClone(true, true, true);
        List<Opportunity> newList = opportunities;
        oldList.get(0).Amount = 500;
        newList.get(0).Amount = 600;
        oldList.get(1).Amount = 500;
        newList.get(1).Amount = 600;
        oldList.get(2).Amount = 500;
        newList.get(2).Amount = 600;
        oldList.get(3).Amount = 500;
        newList.get(3).Amount = 600;
        oldList.get(4).Amount = 500;
        newList.get(4).Amount = 600;
        oldList.get(5).Amount = 500;
        newList.get(5).Amount = 600;
        oldList.get(6).Amount = 400;
        newList.get(6).Amount = 600;
        oldList.get(7).Amount = 400;
        newList.get(7).Amount = 600;
        oldList.get(8).Amount = 400;
        newList.get(8).Amount = 600;
        oldList.get(9).Amount = 400;
        newList.get(9).Amount = 600;
        Map<Id, SObject> oldMap = new Map<Id, SObject>((List<SObject>) oldList);

        Assert.areEqual(6, SObjectCollection.of(newList).filterOld(oldMap, Opportunity.Amount).equals(500).size());
        Assert.areEqual(4, SObjectCollection.of(newList).filterOld(oldMap, Opportunity.Amount).equals(400).size());
    }

    /**
    * Reduce tests
    * */
    @IsTest
    static void testGetList() {
        List<String> strings = SObjectCollection.of(opportunities).listOfString(Opportunity.Name);
        List<Id> ids = SObjectCollection.of(opportunities).listOfId(Opportunity.Id);
        List<Decimal> decimals = SObjectCollection.of(opportunities).listOfDecimal(Opportunity.Probability);

        Assert.isFalse(strings.isEmpty());
        Assert.isFalse(ids.isEmpty());
        Assert.isFalse(decimals.isEmpty());
    }

    @IsTest
    static void testGetSet() {
        Set<String> strings = SObjectCollection.of(opportunities).setOfString(Opportunity.Name);
        Set<Id> ids = SObjectCollection.of(opportunities).setOfId(Opportunity.Id);
        Set<Decimal> decimals = SObjectCollection.of(opportunities).setOfDecimal(Opportunity.Probability);

        Assert.isFalse(strings.isEmpty());
        Assert.isFalse(ids.isEmpty());
        Assert.isFalse(decimals.isEmpty());
    }


    /**
     *@description
     * find() returns first item accepted by ByFieldValue filter.
     */
    @IsTest
    static void testFindReturnsFirstSObjectOfGivenFieldValue() {
        Opportunity expected = opportunities[1];
        Opportunity actual = (Opportunity) SObjectCollection.of(opportunities).filter(Opportunity.Probability).equals(0.1).getFirst();
        System.assertEquals(expected, actual);
    }

    /**
     *@description
     * find() returns null if there's no item accepted by filter.
     */
    @IsTest
    static void testFindReturnsNullWhenThereAreNoItemsAcceptedByFilter() {
        Opportunity actual = (Opportunity) SObjectCollection.of(opportunities).filter(Opportunity.Probability).equals(1.5).getFirst();

        System.assertEquals(null, actual);
    }


    @IsTest
    static void testFindByFilter() {
        Opportunity expected = opportunities[5];
        Opportunity actual = (Opportunity) SObjectCollection.of(opportunities).filter(new OpportunityNameContainsFilter('5')).getFirst();

        System.assertEquals(expected, actual);
    }


    @IsTest
    static void test_any_field_increased_conditions() {
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(opportunities.deepClone(true));
        Opportunity expected = opportunities[5];
        expected.Amount += 100;

        System.assertEquals(new List<Opportunity>{ expected }, SObjectCollection.of(opportunities).filterChanged(oldMap, Opportunity.Amount).get());
    }


    @IsTest
    static void test_any_field_reduced_conditions() {
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(opportunities.deepClone(true));
        Opportunity expected = opportunities[5];
        expected.Amount -= 100;

        System.assertEquals(new List<Opportunity>{ expected }, SObjectCollection.of(opportunities).filterChanged(oldMap, Opportunity.Amount).get());
        System.assertEquals(new List<Opportunity>{ expected }, SObjectCollection.of(opportunities).filterChangedTo(oldMap, Opportunity.Amount, expected.Amount).get());
    }

    @IsTest
    static void test_no_fields_changed_conditions() {
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(opportunities.deepClone(true));

        System.assertEquals(new List<Opportunity>(), SObjectCollection.of(opportunities).filterChanged(oldMap, Opportunity.Amount).get());
        System.assertEquals(new List<Opportunity>(), SObjectCollection.of(opportunities).filterChangedTo(oldMap, Opportunity.Amount, -100).get());
    }

    private class OpportunityNameContainsFilter implements Condition {
        private final String expr;

        public OpportunityNameContainsFilter(String expr) {
            this.expr = expr;
        }

        public Boolean isTrue(Object item) {
            return ((Opportunity) item).Name.contains(expr);
        }
    }
}