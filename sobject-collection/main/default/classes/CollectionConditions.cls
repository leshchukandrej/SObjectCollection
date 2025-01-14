/*
 * *
 *  MIT License
 *
 *  Copyright (c) 2023 Piotr Kożuchowski
 *  Copyright (c) 2024 Andrii Leshchuk
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
*/

public with sharing class CollectionConditions extends Conditions {

    /**
     * Creates filter by field value
     */
    public FieldValueConditionFactory field(SObjectField field) {
        return new FieldValueConditionFactory(toString(field));
    }


    /**
     * Creates instance of Field Filter using operator parameter
     */
    public class FieldValueConditionFactory {
        private String field;
        private Boolean isNot = false;

        public FieldValueConditionFactory(String field) {
            this.field = field;
        }
        
        public FieldValueConditionFactory doNot() {
            this.isNot = !this.isNot;
            return this;
        }

        public Condition equals(Object value) { return new ConditionWrapper(new FieldValueCondition(field, new IntegerEquals(), value), this.isNot); }
        public Condition greaterThan(Object value) { return new ConditionWrapper(new FieldValueCondition(field, new IntegerGreaterThan(), value), this.isNot); }
        public Condition greaterEqualsThan(Object value) { return new ConditionWrapper(new FieldValueCondition(field, new IntegerGreaterEqualsThan(), value), this.isNot); }
        public Condition lessThan(Object value) { return new ConditionWrapper(new FieldValueCondition(field, new IntegerLessThan(), value), this.isNot); }
        public Condition lessEqualsThan(Object value) { return new ConditionWrapper(new FieldValueCondition(field, new IntegerLessEqualsThan(), value), this.isNot); }
        public Condition isIn(Set<Object> values) { return new ConditionWrapper(new FieldValuesCondition(field, true, values), this.isNot); }
        public Condition isIn(List<Object> values) { return new ConditionWrapper(new FieldValuesCondition(field, true, values), this.isNot); }
        public Condition startsWith(String value) { return new ConditionWrapper(new FilterFieldStartsWith(field, value), this.isNot); }
        public Condition contains(String value) { return new ConditionWrapper(new FilterFieldContaining(field, value), this.isNot); }
        public Condition isBlank() { return new ConditionWrapper(new IsBlank(field), this.isNot); }

    }
    
    public class ConditionWrapper implements Condition {
        private final Condition condition;
        private final Boolean isNot;
        
        public ConditionWrapper(Condition condition, Boolean isNot) {
            this.condition = condition;
            this.isNot = isNot;
        }
        
        public Boolean isTrue(Object record) {
            return this.isNot ? !condition.isTrue(record) : condition.isTrue(record);    
        }
    }
    
    private class IsBlank implements Condition {
        private String field;

        public IsBlank(String field) {
            this.field = field;
        }

        public Boolean isTrue(Object record) {
            String fieldValue = (String) ((SObject) record).get(field);
            return String.isBlank(fieldValue);
        }
    }


    /**
     * Creates instance of SObject Filter for finding changed records
     */
    public class AnyFieldsChangedCondition implements Condition {
        private final Map<Id, SObject> oldMap;
        private final List<SObjectField> fieldsToTrack;

        public AnyFieldsChangedCondition(Map<Id, SObject> oldMap, List<SObjectField> fieldsToTrack) {
            this.oldMap = oldMap;
            this.fieldsToTrack = fieldsToTrack;
        }

        public Boolean isTrue(Object record) {
            SObject newRecord = (SObject) record;
            SObject oldRecord = this.oldMap.get(newRecord.Id);

            for (SObjectField field : fieldsToTrack) {
                if (newRecord.get(field) != oldRecord.get(field)) {
                    return true;
                }
            }
            return false;
        }
    }

    public class AnyFieldsChangedToCondition implements Condition {
        private final Map<Id, SObject> oldMap;
        private final Map<SObjectField, Object> valueByFieldToCompare;

        public AnyFieldsChangedToCondition(Map<Id, SObject> oldMap, Map<SObjectField, Object> valueByFieldToCompare) {
            this.oldMap = oldMap;
            this.valueByFieldToCompare = valueByFieldToCompare;
        }

        public Boolean isTrue(Object record) {
            SObject newRecord = (SObject) record;
            SObject oldRecord = this.oldMap.get(newRecord.Id);

            for (SObjectField field : valueByFieldToCompare.keySet()) {
                Object newValue = newRecord.get(field);
                Object oldValue = oldRecord.get(field);
                Object expectedValue = valueByFieldToCompare.get(field);
                if (newValue != oldValue && new FieldValueCondition(toString(field), new IntegerEquals(), expectedValue).isTrue(newRecord)) {
                    return true;
                }
            }
            return false;
        }
    }

    private class FieldValueCondition implements Condition {
        private Object value;
        private String field;
        private Comparator<Object> comparator;
        private final Condition expectedResult;

        public FieldValueCondition(String field, Condition expectedResult, Object value) {
            this.field = field;
            this.value = value;
            this.expectedResult = expectedResult;
            this.comparator = Comparators.getForPrimitive(value);
        }

        public Boolean isTrue(Object record) {
            Object fieldValue = ((SObject) record).get(field);
            Integer outcome = comparator.compare(fieldValue, value);

            return expectedResult.isTrue(outcome);
        }
    }
    
    /**
     * Filters List of SObject by one of many possible field values.
     */
    private class FieldValuesCondition implements Condition {
        private Set<Object> values;
        private String field;
        private Boolean valueIn;

        public FieldValuesCondition(String field, Boolean valueIn, List<Object> values) {
            this(field, valueIn, new Set<Object>(values));
        }

        public FieldValuesCondition(String field, Boolean valueIn, Set<Object> values) {
            this.values = values;
            this.field = field;
            this.valueIn = valueIn;
        }

        public Boolean isTrue(Object record) {
            return valueIn == (values.contains(((SObject) record).get(field)));
        }
    }

    /**
     * Filters SObject list to those related to given parents by given relationship field.
     */
    private class FilterFieldContaining implements Condition {
        private String field;
        private String value;

        public FilterFieldContaining(String field, String value) {
            this.field = field;
            this.value = value;
        }

        public Boolean isTrue(Object record) {
            String fieldValue = (String) ((SObject) record).get(field);
            return fieldValue.contains(value);
        }
    }

    /**
     * Filters SObject list to those related to given parents by given relationship field.
     */
    private class FilterFieldStartsWith implements Condition {
        private String field;
        private String value;

        public FilterFieldStartsWith(String field, String value) {
            this.field = field;
            this.value = value;
        }

        public Boolean isTrue(Object record) {
            String fieldValue = (String) ((SObject) record).get(field);
            return fieldValue?.startsWith(value) ?? false;
        }
    }


    private class IntegerEquals implements Condition {
        public Boolean isTrue(Object i) { return i == 0; }
    }
    private class IntegerGreaterThan implements Condition {
        public Boolean isTrue(Object i) { return (Integer) i > 0; }
    }
    private class IntegerGreaterEqualsThan implements Condition {
        public Boolean isTrue(Object i) { return (Integer) i >= 0; }
    }
    private class IntegerLessThan implements Condition {
        public Boolean isTrue(Object i) { return (Integer) i < 0; }
    }
    private class IntegerLessEqualsThan implements Condition {
        public Boolean isTrue(Object i) { return (Integer) i <= 0; }
    }

    private static String toString(SObjectField field) {
        return '' + field;
    }
}