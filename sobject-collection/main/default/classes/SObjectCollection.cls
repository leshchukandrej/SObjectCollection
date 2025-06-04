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

    public static SObjectCollection of(List<SObject> items) {
        return new SObjectCollection(items);
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

    public SObjectCollection.FieldFilterAbstract filterOld(Map<Id, SObject> oldMap, SObjectField field) {
        return this.filterOld(oldMap, String.valueOf(field));
    }

    public SObjectCollection.FieldFilterAbstract filterOld(Map<Id, SObject> oldMap, String fieldPath) {
        return new OldFieldFilter(oldMap, this, fieldPath);
    }

    public SObjectCollection.FieldFilterAbstract filter(SObjectField field) {
        return this.filter(String.valueOf(field));
    }

    public SObjectCollection.FieldFilterAbstract filter(String fieldPath) {
        return new FieldFilter(this, fieldPath);
    }

    public SObjectCollection filter(Condition condition) {
        return this.filter(condition, false);
    }

    public SObjectCollection filter(Condition condition, Boolean doNot) {
        List<SObject> filteredItems = new List<SObject>();
        for (SObject record : this.items) {
            if (doNot || condition.isTrue(record)) {
                filteredItems.add(record);
            }
        }
        return SObjectCollection.of(filteredItems);
    }

    public SObjectCollection filterOld(Map<Id, SObject> oldMap, Condition condition, Boolean doNot) {
        List<SObject> filteredItems = new List<SObject>();
        for (SObject record : this.items) {
            if (oldMap?.containsKey(record.Id) != true) { continue; }

            if (doNot || condition.isTrue(oldMap.get(record.Id))) {
                filteredItems.add(record);
            }
        }
        return SObjectCollection.of(filteredItems);
    }

    public Set<Id> setOfId(SObjectField idField) {
        return this.setOfId(String.valueOf(idField));
    }

    public Set<Id> setOfId(String fieldPath) {
        return new Set<Id>(this.listOfId(fieldPath));
    }

    public Set<Id> setOfIdIgnoreNulls(SObjectField idField) {
        return this.setOfIdIgnoreNulls(String.valueOf(idField));
    }

    public Set<Id> setOfIdIgnoreNulls(String fieldPath) {
        return new Set<Id>(this.listOfId(fieldPath, true));
    }

    public Set<String> setOfString(SObjectField stringField) {
        return this.setOfString(String.valueOf(stringField));
    }

    public Set<String> setOfString(String fieldPath) {
        return new Set<String>(this.listOfString(fieldPath));
    }

    public Set<String> setOfStringIgnoreNulls(SObjectField stringField) {
        return this.setOfStringIgnoreNulls(String.valueOf(stringField));
    }

    public Set<String> setOfStringIgnoreNulls(String fieldPath) {
        return new Set<String>(this.listOfString(fieldPath, true));
    }

    public Set<Decimal> setOfDecimal(SObjectField decimalField) {
        return this.setOfDecimal(String.valueOf(decimalField));
    }

    public Set<Decimal> setOfDecimal(String fieldPath) {
        return new Set<Decimal>(this.listOfDecimal(fieldPath));
    }

    public Set<Decimal> setOfDecimalIgnoreNulls(SObjectField decimalField) {
        return this.setOfDecimalIgnoreNulls(String.valueOf(decimalField));
    }

    public Set<Decimal> setOfDecimalIgnoreNulls(String fieldPath) {
        return new Set<Decimal>(this.listOfDecimal(fieldPath, true));
    }

    public List<Id> listOfId(SObjectField field) {
        return this.listOfId(String.valueOf(field));
    }

    public List<Id> listOfId(SObjectField field, Boolean ignoreNulls) {
        return (List<Id>) listOfId(String.valueOf(field), ignoreNulls);
    }

    public List<Id> listOfId(String fieldPath) {
        return (List<Id>) listOfId(fieldPath, false);
    }

    public List<Id> listOfId(String fieldPath, Boolean ignoreNulls) {
        return (List<Id>) listOf(fieldPath, Id.class, ignoreNulls);
    }

    public List<String> listOfString(SObjectField field) {
        return this.listOfString(String.valueOf(field));
    }

    public List<String> listOfString(SObjectField field, Boolean ignoreNulls) {
        return this.listOfString(String.valueOf(field), ignoreNulls);
    }

    public List<String> listOfString(String fieldPath) {
        return this.listOfString(fieldPath, false);
    }

    public List<String> listOfString(String fieldPath, Boolean ignoreNulls) {
        return (List<String>) listOf(fieldPath, String.class, false);
    }

    public List<Decimal> listOfDecimal(SObjectField field) {
        return this.listOfDecimal(String.valueOf(field));
    }

    public List<Decimal> listOfDecimal(SObjectField field, Boolean ignoreNulls) {
        return this.listOfDecimal(String.valueOf(field), ignoreNulls);
    }

    public List<Decimal> listOfDecimal(String fieldPath) {
        return this.listOfDecimal(fieldPath, false);
    }

    public List<Decimal> listOfDecimal(String fieldPath, Boolean ignoreNulls) {
        return (List<Decimal>) listOf(fieldPath, Decimal.class, ignoreNulls);
    }

    public Map<Id, SObject> mapById(SObjectField field) {
        return this.mapById(String.valueOf(field));
    }

    public Map<Id, SObject> mapById(String fieldPath) {
        return (Map<Id, SObject>) mapBy(fieldPath, Id.class);
    }

    public Map<String, SObject> mapByString(SObjectField field) {
        return this.mapByString(String.valueOf(field));
    }

    public Map<String, SObject> mapByString(String fieldPath) {
        return (Map<String, SObject>) mapBy(fieldPath, String.class);
    }

    public Map<Decimal, SObject> mapByDecimal(SObjectField field) {
        return this.mapByDecimal(String.valueOf(field));
    }

    public Map<Decimal, SObject> mapByDecimal(String fieldPath) {
        return (Map<Decimal, SObject>) mapBy(fieldPath, Decimal.class);
    }

    public Map<Integer, SObject> mapByInteger(SObjectField field) {
        return this.mapByInteger(String.valueOf(field));
    }

    public Map<Integer, SObject> mapByInteger(String fieldPath) {
        return (Map<Integer, SObject>) mapBy(fieldPath, Integer.class);
    }

    public Map<Id, List<SObject>> groupById(SObjectField field) {
        return this.groupById(String.valueOf(field));
    }

    public Map<Id, List<SObject>> groupById(String fieldPath) {
        return (Map<Id, List<SObject>>) groupBy(fieldPath, Id.class);
    }

    public Map<String, List<SObject>> groupByString(SObjectField field) {
        return this.groupByString(String.valueOf(field));
    }

    public Map<String, List<SObject>> groupByString(String fieldPath) {
        return (Map<String, List<SObject>>) groupBy(fieldPath, String.class);
    }

    public Map<Decimal, List<SObject>> groupByDecimal(SObjectField field) {
        return this.groupByDecimal(String.valueOf(field));
    }

    public Map<Decimal, List<SObject>> groupByDecimal(String fieldPath) {
        return (Map<Decimal, List<SObject>>) groupBy(fieldPath, Decimal.class);
    }

    public Map<Integer, List<SObject>> groupByInteger(SObjectField field) {
        return this.groupByInteger(String.valueOf(field));
    }

    public Map<Integer, List<SObject>> groupByInteger(String fieldPath) {
        return (Map<Integer, List<SObject>>) groupBy(fieldPath, Integer.class);
    }

    private Object listOf(SObjectField field, Type keyType, Boolean ignoreNulls) {
        return this.listOf(String.valueOf(field), keyType, ignoreNulls);
    }

    private Object listOf(String field, Type keyType, Boolean ignoreNulls) {
        List<Object> listOf = (List<Object>) Type.forName('List<' + keyType + '>').newInstance();
        for (SObject record : items) {
            Object value = SObjectCollectionHelper.getValueByPath(record, field);
            if (ignoreNulls && value == null) continue;
            listOf.add(value);
        }
        return listOf;
    }

    private Object mapBy(SObjectField field, Type keyType) {
        return mapBy(String.valueOf(field), keyType);
    }

    private Object mapBy(String field, Type keyType) {
        UntypedMap untypedMap = newMap(keyType, this.getSObjectType());
        for (SObject record : items) {
            untypedMap.put(SObjectCollectionHelper.getValueByPath(record, field), record);
        }
        return untypedMap.toMap();
    }

    public Object groupBy(SObjectField field, Type keyType) {
        return this.groupBy(String.valueOf(field), keyType);
    }

    public Object groupBy(String field, Type keyType) {
        Type listType = Type.forName('List<' + this.getSObjectType() + '>');

        UntypedMap groupMap = newMap(keyType, listType);

        List<Object> emptyList = (List<Object>) listType.newInstance();
        for (SObject record : this.items) {
            Object key = SObjectCollectionHelper.getValueByPath(record, field);
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


    public abstract class FieldFilterAbstract {
        private final SObjectCollection collection;
        private final CollectionConditions.FieldValueConditionFactory filterFactory;
        private Boolean isNot;

        private FieldFilterAbstract(SObjectCollection filterFacade, String fieldPath) {
            this.collection = filterFacade;
            this.filterFactory = new CollectionConditions().field(fieldPath);
            this.isNot = false;
        }

        public FieldFilterAbstract doNot() {
            this.isNot = !this.isNot;
            return this;
        }

        public SObjectCollection equals(Object value) {
            return this.filter(filterFactory.equals(value));
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

        protected abstract SObjectCollection filter(Condition condition);
    }

    public class OldFieldFilter extends FieldFilterAbstract {
        private final Map<Id, SObject> oldMap;

        private OldFieldFilter(Map<Id, SObject> oldMap, SObjectCollection collection, String fieldPath) {
            super(collection, fieldPath);
            this.oldMap = oldMap;
        }

        protected override SObjectCollection filter(Condition condition) {
            return this.collection.filterOld(oldMap, condition, this.isNot);
        }
    }

    public class FieldFilter extends FieldFilterAbstract {

        private FieldFilter(SObjectCollection collection, String fieldPath) {
            super(collection, fieldPath);
        }

        protected override SObjectCollection filter(Condition condition) {
            return this.collection.filter(condition, this.isNot);
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
