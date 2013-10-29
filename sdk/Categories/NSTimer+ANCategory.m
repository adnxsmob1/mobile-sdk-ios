/*   Copyright 2013 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "NSTimer+ANCategory.h"
#import "ANLogging.h"

@implementation NSTimer (ANCategory)

- (BOOL)isScheduled
{
    CFRunLoopRef runLoopRef = [[NSRunLoop currentRunLoop] getCFRunLoop];
    return CFRunLoopContainsTimer(runLoopRef, (__bridge CFRunLoopTimerRef)self, kCFRunLoopDefaultMode);
}

- (void)scheduleNow
{
    ANLogDebug(@"Scheduled timer (%p) with interval %f.", self, self.timeInterval);
	[[NSRunLoop currentRunLoop] addTimer:self forMode:NSDefaultRunLoopMode];
    
    BOOL isScheduled = [self isScheduled];
    
    if (isScheduled)
    {
        ANLogInfo(@"[ANTimer scheduleNow] %@ is scheduled", self);
    }
}

@end