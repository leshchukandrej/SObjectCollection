public class SObjectCollectionHelper {
    public static Object getValueByPath(SObject record, String path) {
        if (record == null || String.isBlank(path)) return null;

        return getValueByPath(record, path.split('\\.'));
    }

    public static Object getValueByPath(SObject record, List<String> pathNodes) {
        if (record == null || pathNodes.isEmpty()) return null;

        try {
            if (pathNodes.size() == 1) {
                return record.get(pathNodes.get(0));
            } else {
                return getValueByPath(record.getSObject(pathNodes.remove(0)), pathNodes);
            }
        } catch (Exception e) {
            System.debug('Error getting the value by path: ' + e);
            return null;
        }
    }
}
