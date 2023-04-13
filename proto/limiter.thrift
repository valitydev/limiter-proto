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
typedef base.ID PartyID
typedef base.ID ShopID
typedef base.ID WalletID
typedef base.ID IdentityID
typedef limiter_base.AmountRange AmountRange
typedef domain.DataRevision Version
typedef limiter_config.LimitContextType LimitContextType
typedef string LimitChangeStatusCode

struct LimitContext {
    1: optional limiter_withdrawal_context.Context withdrawal_processing
    2: optional limiter_payproc_context.Context payment_processing
}

/**
 * https://en.wikipedia.org/wiki/Vector_clock
 */
struct VectorClock {
    1: required base.Opaque state
}

struct LatestClock {}

/**
 * Структура, позволяющая установить причинно-следственную связь операций внутри сервиса
 */
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
    2: required LimitChangeID change_id
    3: optional Version version
}

struct LimitChangeset {
    required list<LimitChange> changes
}

struct LimitChangeStatus {
    required LimitChange limit_change
    required LimitChangeStatusCode status_code
}

struct LimitChangesetStatus {
    required list<LimitChangeStatus> statuses
}

exception LimitNotFound {
    optional LimitID id
}
exception LimitChangeNotFound {
    optional LimitChange change
}
exception ForbiddenOperationAmount {
    1: required domain.Amount amount
    2: required AmountRange allowed_range
    3: optional LimitChange change
}
exception InvalidOperationCurrency {
    1: required domain.CurrencySymbolicCode currency
    2: required domain.CurrencySymbolicCode expected_currency
    3: required LimitChange change
}
exception OperationContextNotSupported {
    1: required LimitContextType context_type
    2: required LimitChange change
}
exception PaymentToolNotSupported {
    1: required string payment_tool
    2: required LimitChange change
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
        3: base.InvalidRequest e2
        4: InvalidOperationCurrency e3
        5: OperationContextNotSupported e4
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
        3: base.InvalidRequest e3
    )

    /**
     * Возвращает состояния по запрашиваемым изменениям.
     */
    LimitChangesetStatus GetChangesetStatuses(1: LimitChangeset changeset, 2: Clock clock) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3
    )

    /**
     * Метод удержания лимитов для набора изменений одного и того же контекста операции.
     *
     * **Гарантирует** что ни одно изменение не будет находиться в не конечном состоянии.
     * То есть, либо все захолдированы успешно, либо ни одного холда, а часть успешных холдов откатана.
     *
     * Следует обратить внимание что вызов метода **не гарантирует** что идентификаторы изменений можно будет успешно
     * использовать при повторной попытке холдирования.
     */
    Clock HoldChangeset(1: LimitChangeset changeset, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        3: base.InvalidRequest e2
        4: InvalidOperationCurrency e3
        5: OperationContextNotSupported e4
        6: PaymentToolNotSupported e5
    )

    /**
     * DISCUSS: Нужен ли этот метод?
     * Метод отката нескольких изменений по лимитам.
     *
     * Уже откатанное изменение игнорируется.
     */
    Clock RollbackChangeset(1: LimitChangeset changeset, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3
    )
}
