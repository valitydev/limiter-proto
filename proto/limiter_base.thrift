include "proto/base.thrift"
include "proto/domain.thrift"

namespace java dev.vality.limiter.base
namespace erlang limiter_base

struct AmountRange {
    1: required AmountBound upper
    2: required AmountBound lower
}

union AmountBound {
    1: domain.Amount inclusive
    2: domain.Amount exclusive
}
