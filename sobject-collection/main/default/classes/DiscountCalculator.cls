public with sharing class DiscountCalculator {
    public static Decimal discountFor(Decimal orderTotal) {
        return orderTotal >= 1000 ? orderTotal * 0.10 : 0;
    }
}
