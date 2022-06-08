/**
 * Машина хранящая конфигурацию лимита
 */

namespace java   dev.vality.limiter.config
namespace erlang limiter_config

include "base.thrift"
include "time_range.thrift"

/// Domain

typedef base.ID LimitConfigID
typedef base.Timestamp Timestamp
typedef base.Amount ShardSize
typedef base.CurrencySymbolicCode CurrencySymbolicCode

struct LimitConfigParams {
    1: required LimitConfigID id
    3: required Timestamp started_at
    4: required ShardSize shard_size
    5: required time_range.TimeRangeType time_range_type
    6: required LimitContextType context_type
    7: required LimitType type
    8: required LimitScope scope
    9: optional string description
    10: required OperationLimitBehaviour op_behaviour
}

struct LimitConfig {
    1: required LimitConfigID id
    2: required string processor_type
    3: required Timestamp created_at
    5: required Timestamp started_at
    6: required ShardSize shard_size
    7: required time_range.TimeRangeType time_range_type
    11: required LimitContextType context_type
    8: optional LimitType type
    9: optional LimitScope scope
    10: optional string description
    12: optional OperationLimitBehaviour op_behaviour

    // deprecated
    4: optional LimitBodyType body_type_deprecated
}

struct OperationLimitBehaviour {
    1: optional OperationBehaviour invoice_payment_refund
}

union OperationBehaviour {
    1: Subtraction subtraction
    2: Addition addition
}

struct Subtraction {}
struct Addition {}

union LimitType {
    1: LimitTypeTurnover turnover
}

struct LimitTypeTurnover {
    /**
     * Metric to account turnover with.
     * If undefined, equivalent to specifying `LimitTurnoverNumber`.
     */
    1: optional LimitTurnoverMetric metric
}

union LimitTurnoverMetric {

    /**
     * Measure turnover over number of operations.
     */
    1: LimitTurnoverNumber number

    /**
     * Measure turnover over aggregate amount of operations denominated in a single currency.
     * In the event operation's currency differs from limit's currency operation will be accounted
     * with appropriate exchange rate fixed against operation's timestamp.
     */
    2: LimitTurnoverAmount amount

}

struct LimitTurnoverNumber {}
struct LimitTurnoverAmount {
    1: required CurrencySymbolicCode currency
}

union LimitScope {

    /**
     * Set of scopes.
     * Each additional scope increases specificity of a limit. Each possible set describes unique
     * limit, e.g. limit with scope { party } and limit with scope { party, shop } are completely
     * different limits. Empty set is equivalent to a limit having global scope.
     */
    3: set<LimitScopeType> multi

    /**
     * Single scope.
     * Equivalent to the set of scopes containing exactly one scope.
     * Kept to preserve backward compatibility with existing data.
     */
    2: LimitScopeType single

    // Reserved
    // 1

}

union LimitScopeType {

    1: LimitScopeEmptyDetails party
    2: LimitScopeEmptyDetails shop
    3: LimitScopeEmptyDetails wallet
    4: LimitScopeEmptyDetails identity

    /**
     * Scope over data which uniquely identifies payment tool used in a payment.
     * E.g. `domain.BankCard.token` + `domain.BankCard.exp_date` when bank card is being used as
     * payment tool.
     *
     * See: https://github.com/valitydev/damsel/blob/2e1dbc1a/proto/domain.thrift#L1824-L1830
     */
    5: LimitScopeEmptyDetails payment_tool

}

struct LimitScopeEmptyDetails {}

union LimitContextType {
    1: LimitContextTypePaymentProcessing payment_processing
}

struct LimitContextTypePaymentProcessing {}

/// LimitConfig events

struct TimestampedChange {
    1: required base.Timestamp occured_at
    2: required Change change
}

union Change {
    1: CreatedChange created
}

struct CreatedChange {
    1: required LimitConfig limit_config
}

/// Deprecated definitions

union LimitBodyType {
    2: LimitBodyTypeCash cash
}

struct LimitBodyTypeCash {
    1: required CurrencySymbolicCode currency
}
