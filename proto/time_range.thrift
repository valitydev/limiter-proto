/**
 * Временные интервалы
 */

namespace java   dev.vality.limiter.range.time
namespace erlang limiter.time.range

include "proto/base.thrift"
include "proto/domain.thrift"

/// Domain

typedef domain.AccountID AccountID
typedef base.Timestamp Timestamp
typedef domain.Amount IntervalAmount

union TimeRangeType {
    1: TimeRangeTypeCalendar calendar
    2: TimeRangeTypeInterval interval
}

union TimeRangeTypeCalendar {
    1: TimeRangeTypeCalendarYear year
    2: TimeRangeTypeCalendarMonth month
    3: TimeRangeTypeCalendarWeek week
    4: TimeRangeTypeCalendarDay day
}

struct TimeRangeTypeCalendarYear {}
struct TimeRangeTypeCalendarMonth {}
struct TimeRangeTypeCalendarWeek {}
struct TimeRangeTypeCalendarDay {}

struct TimeRangeTypeInterval {
    1: required IntervalAmount amount // in sec
}

struct TimeRange {
    1: required Timestamp upper
    2: required Timestamp lower
    3: optional AccountID account_id_from
    4: optional AccountID account_id_to
}
