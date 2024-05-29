include "proto/withdrawals_domain.thrift"
include "proto/domain.thrift"
include "proto/base.thrift"
include "limiter_base.thrift"

namespace java dev.vality.limiter.withdrawal.context
namespace erlang limproto.context.withdrawal

/**
 * Контекст, получаемый из сервисов, реализующих один из интерфейсов протокола
 * (например withdrawal в fistful)
 */
struct Context {
    1: optional Operation op
    2: optional Withdrawal withdrawal
}

union Operation {
    1: OperationWithdrawal withdrawal
}

struct OperationWithdrawal {}

struct Withdrawal {
    1: optional withdrawals_domain.Withdrawal withdrawal
    2: optional limiter_base.Route route
    3: optional base.ID wallet_id
}
