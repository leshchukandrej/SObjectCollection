/*
 * *
 *  MIT License
 *
 *  Copyright (c) 2024 Andrii Leshchuk
 *  The code is simplified for SObject collection use from the original generic version by Piotr Kożuchowski
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
public inherited sharing class SObjectCollection {
    private final List<SObject> items;

    private SObjectCollection(List<SObject> items) {
        this.items = items == null ? new List<SObject>() : items;
    }

    public SObject getFirst() {
        return isEmpty() ? null : items[0];
    }

    public SObject getLast() {
        return isEmpty() ? null : items[items.size() - 1];
    }
    public SObject get(Integer i) {
        return items[i];
    }
    public List<SObject> get() {
        return this.items;
    }

    public static SObjectCollection of(List<SObject> items) {
        return new SObjectCollection(items);
    }

    public SObjectCollection add(Integer index, SObject element) {
        items.add(index, element);
        return this;
    }

    public SObjectCollection add(SObject element) {
        items.add(element);
        return this;
    }

    public SObjectCollection addAll(List<SObject> elements) {
        items.addAll(elements);
        return this;
    }

    public SObjectCollection remove(Integer index) {
        items.remove(index);
        return this;
    }

    public SObjectCollection removeLast() {
        if (isNotEmpty()) {
            items.remove(size() - 1);
        }
        return this;
    }

    public SObjectCollection clear() {
        if (isNotEmpty()) {
            items.clear();
        }
        return this;
    }

    public Boolean isNotEmpty() { return !isEmpty(); }
    public Boolean isEmpty() { return items == null || items.isEmpty(); }
    public Integer size() { return items == null ? 0 : items.size(); }

    public SObjectCollection filterChanged(Map<Id, SObject> oldMap, SObjectField field) {
        return this.filterAnyChanged(oldMap, new List<SObjectField>{ field });
    }

    public SObjectCollection filterAnyChanged(Map<Id, SObject> oldMap, List<SObjectField> fields) {
        return this.filter(new CollectionConditions.AnyFieldsChangedCondition(oldMap, fields));
    }

    public SObjectCollection filterChangedTo(Map<Id, SObject> oldMap, SObjectField field, Object value) {
        return this.filterAnyChangedTo(oldMap, new Map<SObjectField, Object>{ field => value });
    }

    public SObjectCollection filterAnyChangedTo(Map<Id, SObject> oldMap, Map<SObjectField, Object> valueByFieldToCompare) {
        return this.filter(new CollectionConditions.AnyFieldsChangedToCondition(oldMap, valueByFieldToCompare));
    }

    public SObjectCollection.FieldFilter filter(SObjectField field) {
        return new FieldFilter(this, field);
    }

    public SObjectCollection filter(Condition condition) {
        return this.filter(condition, false);
    }

    public SObjectCollection filter(Condition condition, Boolean doNot) {
        List<SObject> filteredItems = new List<SObject>();
        for (Integer i = 0, size = this.size(); i < size; i++) {
            Boolean result = doNot ? !condition.isTrue(items[i]) : condition.isTrue(items[i]);
            if (result) {
                filteredItems.add(items[i]);
            }
        }
        return SObjectCollection.of(filteredItems);
    }

    public Set<Id> setOfId(SObjectField idField) {
        return new Set<Id>(this.listOfId(idField));
    }

    public Set<String> setOfString(SObjectField stringField) {
        return new Set<String>(this.listOfString(stringField));
    }

    public Set<Decimal> setOfDecimal(SObjectField decimalField) {
        return new Set<Decimal>(this.listOfDecimal(decimalField));
    }

    public Set<Id> setOfIdIgnoreNulls(SObjectField idField) {
        return new Set<Id>(this.listOfId(idField, true));
    }

    public Set<String> setOfStringIgnoreNulls(SObjectField stringField) {
        return new Set<String>(this.listOfString(stringField, true));
    }

    public Set<Decimal> setOfDecimalIgnoreNulls(SObjectField decimalField) {
        return new Set<Decimal>(this.listOfDecimal(decimalField, true));
    }

    public List<Id> listOfId(SObjectField field) {
        return (List<Id>) listOf(field, Id.class, false);
    }

    public List<String> listOfString(SObjectField field) {
        return (List<String>) listOf(field, String.class, false);
    }

    public List<Decimal> listOfDecimal(SObjectField field) {
        return (List<Decimal>) listOf(field, Decimal.class, false);
    }

    public List<Id> listOfId(SObjectField field, Boolean ignoreNulls) {
        return (List<Id>) listOf(field, Id.class, ignoreNulls);
    }

    public List<String> listOfString(SObjectField field, Boolean ignoreNulls) {
        return (List<String>) listOf(field, String.class, ignoreNulls);
    }

    public List<Decimal> listOfDecimal(SObjectField field, Boolean ignoreNulls) {
        return (List<Decimal>) listOf(field, Decimal.class, ignoreNulls);
    }

    public Map<Id, SObject> mapById(SObjectField field) {
        return (Map<Id, SObject>) mapBy(field, Id.class);
    }

    public Map<String, SObject> mapByString(SObjectField field) {
        return (Map<String, SObject>) mapBy(field, String.class);
    }

    public Map<Decimal, SObject> mapByDecimal(SObjectField field) {
        return (Map<Decimal, SObject>) mapBy(field, Decimal.class);
    }

    public Map<Integer, SObject> mapByInteger(SObjectField field) {
        return (Map<Integer, SObject>) mapBy(field, Integer.class);
    }

    public Map<Id, List<SObject>> groupById(SObjectField field) {
        return (Map<Id, List<SObject>>) groupBy(field, Id.class);
    }

    public Map<String, List<SObject>> groupByString(SObjectField field) {
        return (Map<String, List<SObject>>) groupBy(field, String.class);
    }

    public Map<Decimal, List<SObject>> groupByDecimal(SObjectField field) {
        return (Map<Decimal, List<SObject>>) groupBy(field, Decimal.class);
    }

    public Map<Integer, List<SObject>> groupByInteger(SObjectField field) {
        return (Map<Integer, List<SObject>>) groupBy(field, Integer.class);
    }
    private Object listOf(SObjectField field, Type keyType, Boolean ignoreNulls) {
        List<Object> listOf = (List<Object>) Type.forName('List<' + keyType + '>').newInstance();
        for (SObject record : items) {
            if (ignoreNulls && record.get(field) == null) continue;
            listOf.add(record.get(field));
        }
        return listOf;
    }

    private Object mapBy(SObjectField field, Type keyType) {
        UntypedMap untypedMap = newMap(keyType, this.getSObjectType());
        for (SObject record : items) {
            untypedMap.put(record.get(field), record);
        }
        return untypedMap.toMap();
    }

    public Object groupBy(SObjectField field, Type keyType) {
        Type listType = Type.forName('List<' + this.getSObjectType() + '>');

        UntypedMap groupMap = newMap(keyType, listType);

        List<Object> emptyList = (List<Object>) listType.newInstance();
        for (SObject record : this.items) {
            Object key = record.get(field);
            if (!groupMap.containsKey(key)) {
                groupMap.put(key, emptyList.clone());
            }
            List<Object> groupedRecords = (List<Object>) groupMap.get(key);
            groupedRecords.add(record);
        }

        return groupMap.toMap();
    }
    private Type getSObjectType() {
        String sObjectName = String.valueOf(this.items.getSObjectType());

        return Type.forName(sObjectName ?? 'SObject');
    }

    public class FieldFilter {
        private final SObjectCollection collection;
        private final CollectionConditions.FieldValueConditionFactory filterFactory;
        private Boolean isNot;

        private FieldFilter(SObjectCollection filterFacade, SObjectField field) {
            this.collection = filterFacade;
            this.filterFactory = new CollectionConditions().field(field);
            this.isNot = false;
        }

        public FieldFilter doNot() {
            this.isNot = !this.isNot;
            return this;
        }

        public SObjectCollection equals(Object value) {
            return collection.filter(filterFactory.equals(value), this.isNot);
        }
        public SObjectCollection greaterThan(Object value) {
            return collection.filter(filterFactory.greaterThan(value), this.isNot);
        }
        public SObjectCollection greaterEqualsThan(Object value) {
            return collection.filter(filterFactory.greaterEqualsThan(value), this.isNot);
        }
        public SObjectCollection lessThan(Object value) {
            return collection.filter(filterFactory.lessThan(value), this.isNot);
        }
        public SObjectCollection lessEqualsThan(Object value) {
            return collection.filter(filterFactory.lessEqualsThan(value), this.isNot);
        }
        public SObjectCollection isIn(Set<Object> values) {
            return collection.filter(filterFactory.isIn(values), this.isNot);
        }
        public SObjectCollection isIn(List<Object> values) {
            return collection.filter(filterFactory.isIn(values), this.isNot);
        }
        public SObjectCollection contains(String value) {
            return collection.filter(filterFactory.contains(value), this.isNot);
        }
        public SObjectCollection isNull() {
            return collection.filter(filterFactory.equals(null), this.isNot);
        }
        public SObjectCollection isBlank() {
            return collection.filter(filterFactory.isBlank(), this.isNot);
        }
    }

    private static UntypedMap newMap(Type keyType, Type objectType) {
        Object sfMap = Type.forName('Map<' + keyType + ',' + objectType + '>').newInstance();

        if (keyType == Id.class) return new MapById((Map<Id, Object>) sfMap);
        if (keyType == String.class) return new MapByString((Map<String, Object>) sfMap);
        if (keyType == Decimal.class) return new MapByDecimal((Map<Decimal, Object>) sfMap);
        if (keyType == Integer.class) return new MapByInteger((Map<Integer, Object>) sfMap);

        throw new SObjectCollectionException('Unsupported key type: ' + keyType);
    }

    private interface UntypedMap {
        Object toMap();
        void put(Object key, Object value);
        Object get(Object key);
        Boolean containsKey(Object key);
    }

    private class MapById implements UntypedMap {
        private final Map<Id, Object> untypedMap;

        private MapById(Map<Id, Object> untypedMap) {
            this.untypedMap = untypedMap;
        }

        public Object toMap() { return this.untypedMap; }
        public void put(Object key, Object value) { this.untypedMap.put((Id) key, value); }
        public Object get(Object key) { return this.untypedMap.get((Id) key); }
        public Boolean containsKey(Object key) { return this.untypedMap.containsKey((Id) key); }
    }

    private class MapByString implements UntypedMap {
        private final Map<String, Object> untypedMap;

        private MapByString(Map<String, Object> untypedMap) {
            this.untypedMap = untypedMap;
        }

        public Object toMap() { return this.untypedMap; }
        public void put(Object key, Object value) { this.untypedMap.put((String.valueOf(key)), value); }
        public Object get(Object key) { return this.untypedMap.get(String.valueOf(key)); }
        public Boolean containsKey(Object key) { return this.untypedMap.containsKey(String.valueOf(key)); }
    }

    private class MapByDecimal implements UntypedMap {
        private final Map<Decimal, Object> untypedMap;

        private MapByDecimal(Map<Decimal, Object> untypedMap) {
            this.untypedMap = untypedMap;
        }

        public Object toMap() { return this.untypedMap; }
        public void put(Object key, Object value) { this.untypedMap.put((Decimal) key, value); }
        public Object get(Object key) { return this.untypedMap.get((Decimal) key); }
        public Boolean containsKey(Object key) { return this.untypedMap.containsKey((Decimal) key); }
    }

    private class MapByInteger implements UntypedMap {
        private final Map<Integer, Object> untypedMap;

        private MapByInteger(Map<Integer, Object> untypedMap) {
            this.untypedMap = untypedMap;
        }

        public Object toMap() { return this.untypedMap; }
        public void put(Object key, Object value) { this.untypedMap.put(Integer.valueOf(key), value); }
        public Object get(Object key) { return this.untypedMap.get(Integer.valueOf(key)); }
        public Boolean containsKey(Object key) { return this.untypedMap.containsKey(Integer.valueOf(key)); }
    }

    private class SObjectCollectionException extends Exception {}
}