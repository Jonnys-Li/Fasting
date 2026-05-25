//
//  FSTRecordsRepository.m
//  Fasting
//

#import "FSTRecordsRepository.h"

NSNotificationName const FSTRecordsDidChangeNotification = @"FSTRecordsDidChangeNotification";

static NSString * const FSTRecordsKey     = @"kFSTRecords";
static NSString * const FSTMealRecordsKey = @"kFSTMealRecords";

@interface FSTRecordsRepository ()
@property (nonatomic, strong) NSMutableArray<FSTFastingRecord *> *records;
@property (nonatomic, strong) NSMutableArray<FSTMealRecord *> *mealRecords;
@end

@implementation FSTRecordsRepository

+ (instancetype)sharedRepository {
    static FSTRecordsRepository *repository;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        repository = [FSTRecordsRepository new];
        [repository loadFromDefaults];
    });
    return repository;
}

#pragma mark - Persistence

- (void)loadFromDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSArray *fastingDictionaries = [userDefaults objectForKey:FSTRecordsKey];
    self.records = [NSMutableArray array];
    for (NSDictionary *entry in fastingDictionaries) {
        FSTFastingRecord *record = [FSTFastingRecord fst_recordWithDictionary:entry];
        if (record.startDate && record.endDate) [self.records addObject:record];
    }

    NSArray *mealDictionaries = [userDefaults objectForKey:FSTMealRecordsKey];
    self.mealRecords = [NSMutableArray array];
    for (NSDictionary *entry in mealDictionaries) {
        FSTMealRecord *record = [FSTMealRecord fst_recordWithDictionary:entry];
        if (record.date) [self.mealRecords addObject:record];
    }
}

- (void)saveRecordsToDefaults {
    NSMutableArray *serialized = [NSMutableArray array];
    for (FSTFastingRecord *record in self.records) {
        [serialized addObject:[record fst_dictionaryRepresentation]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:FSTRecordsKey];
}

- (void)saveMealRecordsToDefaults {
    NSMutableArray *serialized = [NSMutableArray array];
    for (FSTMealRecord *record in self.mealRecords) {
        [serialized addObject:[record fst_dictionaryRepresentation]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:FSTMealRecordsKey];
}

- (void)postChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:FSTRecordsDidChangeNotification object:self];
}

#pragma mark - Fasting records

- (NSArray<FSTFastingRecord *> *)allRecords {
    return [self.records copy];
}

- (void)updateFastingRecord:(FSTFastingRecord *)record {
    if (!record.recordID.length || !record.startDate || !record.endDate) return;
    NSUInteger existingIndex = [self.records indexOfObjectPassingTest:^BOOL(FSTFastingRecord *obj, NSUInteger idx, BOOL *stop) {
        return [obj.recordID isEqualToString:record.recordID];
    }];
    if (existingIndex != NSNotFound) {
        self.records[existingIndex] = record;
    } else {
        [self.records insertObject:record atIndex:0];
    }
    [self.records sortUsingComparator:^NSComparisonResult(FSTFastingRecord *a, FSTFastingRecord *b) {
        return [b.endDate compare:a.endDate];
    }];
    [self saveRecordsToDefaults];
    [self postChangeNotification];
}

- (void)deleteFastingRecord:(FSTFastingRecord *)record {
    if (!record.recordID.length) return;
    NSIndexSet *indexes = [self.records indexesOfObjectsPassingTest:^BOOL(FSTFastingRecord *obj, NSUInteger idx, BOOL *stop) {
        return [obj.recordID isEqualToString:record.recordID];
    }];
    if (indexes.count == 0) return;
    [self.records removeObjectsAtIndexes:indexes];
    [self saveRecordsToDefaults];
    [self postChangeNotification];
}

#pragma mark - Meal records

- (NSArray<FSTMealRecord *> *)allMealRecords {
    return [self.mealRecords copy];
}

- (void)addOrUpdateMealRecord:(FSTMealRecord *)record {
    if (!record || !record.date) return;
    if (!record.recordID.length) record.recordID = [[NSUUID UUID] UUIDString];
    NSUInteger existingIndex = [self.mealRecords indexOfObjectPassingTest:^BOOL(FSTMealRecord *obj, NSUInteger idx, BOOL *stop) {
        return [obj.recordID isEqualToString:record.recordID];
    }];
    if (existingIndex != NSNotFound) {
        self.mealRecords[existingIndex] = record;
    } else {
        [self.mealRecords insertObject:record atIndex:0];
    }
    [self.mealRecords sortUsingComparator:^NSComparisonResult(FSTMealRecord *a, FSTMealRecord *b) {
        return [b.date compare:a.date];
    }];
    [self saveMealRecordsToDefaults];
    [self postChangeNotification];
}

- (void)deleteMealRecord:(FSTMealRecord *)record {
    if (!record.recordID.length) return;
    NSIndexSet *indexes = [self.mealRecords indexesOfObjectsPassingTest:^BOOL(FSTMealRecord *obj, NSUInteger idx, BOOL *stop) {
        return [obj.recordID isEqualToString:record.recordID];
    }];
    if (indexes.count == 0) return;
    [self.mealRecords removeObjectsAtIndexes:indexes];
    [self saveMealRecordsToDefaults];
    [self postChangeNotification];
}

#pragma mark - Derived

- (NSDate *)latestFastingEndDate {
    return self.records.firstObject.endDate;
}

- (NSDate *)latestMealDate {
    return self.mealRecords.firstObject.date;
}

@end
