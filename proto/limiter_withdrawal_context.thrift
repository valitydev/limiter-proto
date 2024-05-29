include "proto/withdrawals_domain.thrift"
include "proto/domain.thrift"
include "proto/base.thrift"
include "limiter_base.thrift"

namespace java dev.vality.limiter.withdrawal.context
namespace erlang limproto.context.withdrawal

typedef string Token
typedef string ID

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
    4: optional Destination destination
}

struct Destination {
    1: optional AuthData auth_data
    2: optional Resource resource
}

union AuthData {
    1: SenderReceiverAuthData sender_receiver
}

struct SenderReceiverAuthData {
    1: optional Token sender
    2: optional Token receiver
}

union Resource {
    1: ResourceBankCard bank_card
}

struct ResourceBankCard {
    1: optional BankCard bank_card
}

struct BankCard {
    1: optional Token token
}
