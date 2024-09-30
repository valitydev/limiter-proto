include "proto/base.thrift"
include "proto/domain.thrift"
include "proto/limiter_config.thrift"
include "limiter_base.thrift"
include "limiter_payproc_context.thrift"
include "limiter_withdrawal_context.thrift"

namespace java dev.vality.limiter
namespace erlang limproto.limiter

typedef string LimitChangeID
typedef string LimitID
typedef string OperationID
typedef base.ID PartyID
typedef base.ID ShopID
typedef base.ID WalletID
typedef base.ID IdentityID
typedef limiter_base.AmountRange AmountRange
typedef domain.DataRevision Version
typedef limiter_config.LimitContextType LimitContextType

struct LimitContext {
    1: optional limiter_withdrawal_context.Context withdrawal_processing
    2: optional limiter_payproc_context.Context payment_processing
}

/**
 * https://en.wikipedia.org/wiki/Vector_clock
 **/
struct VectorClock {
    1: required base.Opaque state
}

struct LatestClock {}

/**
* Структура, позволяющая установить причинно-следственную связь операций внутри сервиса
**/
union Clock {
    1: VectorClock vector
    2: LatestClock latest
}

struct Limit {
    1: required LimitID id
    2: required domain.Amount amount
    3: optional base.Timestamp creation_time
    4: optional string description
}

struct LimitChange {
    1: required LimitID id
    // For single requests only
    2: optional LimitChangeID change_id
    3: optional Version version
}

struct LimitRequest {
    1: required OperationID operation_id
    2: required list<LimitChange> limit_changes
}

exception LimitNotFound {}
exception LimitChangeNotFound {}
exception ForbiddenOperationAmount {
    1: required domain.Amount amount
    2: required AmountRange allowed_range
}
exception InvalidOperationCurrency {
    1: required domain.CurrencySymbolicCode currency
    2: required domain.CurrencySymbolicCode expected_currency
}
exception OperationContextNotSupported {
    1: required LimitContextType context_type
}
exception PaymentToolNotSupported {
    1: required string payment_tool
}

service Limiter {

    Limit Get(1: LimitID id, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        2: base.InvalidRequest e2
    )

    Limit GetVersioned(1: LimitID id, 2: Version version, 3: Clock clock, 4: LimitContext context) throws (
        1: LimitNotFound e1,
        2: base.InvalidRequest e2
    )

    Clock Hold(1: LimitChange change, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        3: base.InvalidRequest e2,
        4: InvalidOperationCurrency e3,
        5: OperationContextNotSupported e4,
        6: PaymentToolNotSupported e5
    )

    Clock Commit(1: LimitChange change, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3,
        4: ForbiddenOperationAmount e4
    )

    Clock Rollback(1: LimitChange change, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3,
        /*
         * Исключения бизнес-логики повторяются для `Rollback` с целью
         * согласованности контракта при вызове метода с тем же контекстом что
         * и в методе `Hold`.
         * То есть клиенту при последовательном обращении к методам удержания и
         * отката с одними и теми же контекстом и идентификаторами изменений
         * гарантируется что те же самые ошибки бизнес-логики будут явно
         * сообщены, а операция отката не будет пытаться найти и изменить
         * состояния не удержанного изменения.
         */
        4: InvalidOperationCurrency e4,
        5: OperationContextNotSupported e5,
        6: PaymentToolNotSupported e6
    )

    list<Limit> GetBatch(1: LimitRequest request, 2: LimitContext context) throws (
        1: LimitNotFound e1,
        2: base.InvalidRequest e2
    )

    list<Limit> HoldBatch(1: LimitRequest request, 2: LimitContext context) throws (
        1: LimitNotFound e1,
        3: base.InvalidRequest e2,
        4: InvalidOperationCurrency e3,
        5: OperationContextNotSupported e4,
        6: PaymentToolNotSupported e5
    )

    void CommitBatch(1: LimitRequest request, 2: LimitContext context) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3,
        4: ForbiddenOperationAmount e4
    )

    Clock RollbackBatch(1: LimitRequest request, 2: LimitContext context) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3,
        /*
         * Исключения бизнес-логики повторяются для `Rollback` с целью
         * согласованности контракта при вызове метода с тем же контекстом что
         * и в методе `Hold`.
         * То есть клиенту при последовательном обращении к методам удержания и
         * отката с одними и теми же контекстом и идентификаторами изменений
         * гарантируется что те же самые ошибки бизнес-логики будут явно
         * сообщены, а операция отката не будет пытаться найти и изменить
         * состояния не удержанного изменения.
         */
        4: InvalidOperationCurrency e4,
        5: OperationContextNotSupported e5,
        6: PaymentToolNotSupported e6
    )

}
