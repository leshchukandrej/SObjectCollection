public with sharing class CustomerTier {
    public static String tierFor(Decimal yearlySpend) {
        if (yearlySpend >= 50000) return 'Gold';
        if (yearlySpend >= 10000) return 'Silver';
        return 'Bronze';
    }
}
