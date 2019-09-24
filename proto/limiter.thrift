namespace java com.rbkmoney.limiter
namespace erlang limiter

include "proto/shumpune.thrift"
include "proto/base.thrift"

typedef string LimitID
typedef string PlanID
typedef i64    BatchID
typedef i64    AccountID
typedef string LimitRef
typedef i64    DomainRevision

typedef shumpune.Clock Clock
typedef shumpune.Balance Balance
typedef base.InvalidRequest InvalidRequest

enum LimitType {
    cash
    count
}

struct Sublimit {
    1: required AccountID account_id
    2: required LimitTimeRange time_range
}

/**
* Структура данных, описывающая свойства счета:
* id -идентификатор машины лимита
* ref - идентификатор лимита в domain конфигурации
* domain_revision - ревизия конфигурации
* type - тип лимита
* sublimits - сублимиты лимита
* description - описание (неизменяемо после создания лимита)
*/
struct Limit {
    1: required LimitID id
    2: required LimitRef ref
    3: required DomainRevision domain_revision
    4: required LimitType type
    5: required list<Sublimit> sublimits
    6: optional string description
}

/**
*  Описывает одно изменение лимита в системе, может быть следующих типов:
*  cash - изменение валютного лимита
*  count - изменение счетного лимита
*/

union LimitUnit {
   1: LimitUnitCash cash
   2: LimitUnitCount count
}

struct LimitUnitCash {
    1: required base.Amount amount
    2: required base.CurrencySymbolicCode currency_sym_code
}

struct LimitUnitCount {
    1: required base.Amount amount
}

/**
* Описывает батч - набор изменений лимита, служит единицей атомарности операций в системе:
* id -  идентификатор набора, уникален в пределах плана
* units - набор изменений лимита
*/
struct LimitBatch {
    1: required BatchID id
    2: required list<LimitUnit> units
}

/**
 * План состоит из набора батчей, который можно пополнить, подтвердить или отменить:
 * id - идентификатор плана, уникален в рамках системы
 * batch_list - набор батчей, связанный с данным планом
*/
struct LimitPlan {
    1: required PlanID id
    2: required list<LimitBatch> batch_list
}

/**
* Описывает параметры создания лимита:
* ref - идентификатор лимита в domain конфигурации
* domain_revision - ревизия конфигурации
* create_time - время старта нового временного интервала лимита
*/
struct LimitCreateParams {
    1: required LimitRef ref
    2: required DomainRevision domain_revision
    3: required base.Timestamp create_time
}

/**
* Описывает единицу изменения плана:
* id - id плана, к которому применяется данное изменение
* batch - набор изменений, который нужно добавить в план
* create_params - если такого лимита нет или срок дейтсвия сублимита истек, то эти параметры
*                 будут использованы чтобы проинициализировать новый лимит/сублимит.
                  Так как мы не знаем существует ли лимит, то всегда прикладываем эти параметры.
*/
struct LimitPlanChange {
    1: required PlanID id
    2: required LimitBatch batch
    3: required LimitCreateParams create_params
}

/**
* Описывает время действия лимита:
* start_time - начало действия лимита
* end_time - конец, если не бесконечно
*/
struct LimitTimeRange {
    1: required base.Timestamp start_time
    2: optional base.Timestamp end_time
}

/**
* Описывает точку во времени жизни лимита:
* clock - clock состояния счета аккаунта, привязанного к сублимиту
* time_range - время действия сублимита, чтобы можно было его найти в лимите
*/
struct LimitClock {
    1: required Clock clock
    2: required LimitTimeRange time_range
}

exception LimitNotFound {
    1: required LimitID limit_id
}

exception PlanNotFound {
    1: required PlanID plan_id
}

/**
* Возникает в случае, если переданы некорректные параметры в одном или нескольких изменениях лимита
*/
exception InvalidLimitParams {
    1: required map<LimitUnit, string> wrong_limits
}

exception ClockInFuture {}

service Accounter {
    LimitClock Hold(1: LimitPlanChange plan_change) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitClock CommitPlan(1: LimitPlan plan) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitClock RollbackPlan(1: LimitPlan plan) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitPlan GetPlan(1: PlanID id) throws (1: PlanNotFound e1)
    Limit GetLimitByID(1: LimitID id) throws (1:LimitNotFound e1)
    Balance GetBalanceByID(1: LimitID id, 2: LimitClock clock) throws (1:LimitNotFound e1, 2: ClockInFuture e2)
}
