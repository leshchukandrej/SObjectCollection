public with sharing class LoyaltyPoints {
    public static Integer pointsFor(Decimal amount) {
        // Bug on purpose for the demo: a 10% "fee" sneaked in.
        return (Integer) (amount / 10 * 0.9);
    }
}
