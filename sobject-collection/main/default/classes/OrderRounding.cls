public with sharing class OrderRounding {
    public static Decimal toCents(Decimal amount) {
        return amount.setScale(2, System.RoundingMode.HALF_UP);
    }
}
