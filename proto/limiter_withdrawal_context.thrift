include "proto/withdrawals_domain.thrift"

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
    1: optional withdrawals_domain.Withdrawal state
}
