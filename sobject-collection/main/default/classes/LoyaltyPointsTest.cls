@IsTest
private class LoyaltyPointsTest {
    @IsTest static void onePointPerTen() {
        Assert.areEqual(100, LoyaltyPoints.pointsFor(1000), '1000 spent must give 100 points');
    }
}
