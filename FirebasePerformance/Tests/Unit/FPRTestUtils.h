// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>

#import "FirebasePerformance/Sources/Timer/FIRTrace+Internal.h"
#import "FirebasePerformance/Sources/Timer/FIRTrace+Private.h"

#import "FirebasePerformance/Sources/Loggers/FPRGDTEvent.h"

#import <GoogleDataTransport/GoogleDataTransport.h>

#import "FirebasePerformance/ProtoSupport/PerfMetric.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface FPRTestUtils : NSObject

/** Default initializer. */
- (instancetype)init NS_UNAVAILABLE;

/** Creates a Performance Trace object. */
+ (FIRTrace *)createRandomTraceWithName:(NSString *)name;

/** Add verbose session to specific Performance Trace object. */
+ (FIRTrace *)addVerboseSessionToTrace:(FIRTrace *)trace;

/** Creates a random Performance Metric Proto object. */
+ (FPRMSGPerfMetric *)createRandomPerfMetric:(NSString *)traceName;

/**
 * Creates a random Performance Metric Proto object, with verbose
 * session ID if it is set as verbose.
 */
+ (FPRMSGPerfMetric *)createVerboseRandomPerfMetric:(NSString *)traceName;

/** Creates a random internal Performance Metric Proto object. */
+ (FPRMSGPerfMetric *)createRandomInternalPerfMetric:(NSString *)traceName;

/** Creates a random network request Performance Metric Proto object. */
+ (FPRMSGPerfMetric *)createRandomNetworkPerfMetric:(NSString *)url;

/** Creates a random gauge Performance Metric Proto object. */
+ (FPRMSGPerfMetric *)createRandomGaugePerfMetric;

/** Creates a random GDTCOREvent object. */
+ (GDTCOREvent *)createRandomTraceGDTEvent:(NSString *)traceName;

/** Creates a random GDTCOREvent object with internal trace event. */
+ (GDTCOREvent *)createRandomInternalTraceGDTEvent:(NSString *)traceName;

/** Creates a random GDTCOREvent object with network event. */
+ (GDTCOREvent *)createRandomNetworkGDTEvent:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
