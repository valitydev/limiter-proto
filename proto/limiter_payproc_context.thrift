include "proto/domain.thrift"
include "limiter_base.thrift"

namespace java dev.vality.limiter.payproc.context
namespace erlang limproto.context.payproc

/**
 * Контекст, получаемый из сервисов, реализующих один из интерфейсов протокола
 * (например invoicing в hellgate)
 */
struct Context {
    1: optional Operation op
    2: optional Invoice invoice
}

union Operation {
    1: OperationInvoice invoice
    3: OperationInvoicePayment invoice_payment
    4: OperationInvoicePaymentAdjustment invoice_payment_adjustment
    5: OperationInvoicePaymentRefund invoice_payment_refund
    6: OperationInvoicePaymentChargeback invoice_payment_chargeback
}

struct OperationInvoice {}
struct OperationInvoicePayment {}
struct OperationInvoicePaymentAdjustment {}
struct OperationInvoicePaymentRefund {}
struct OperationInvoicePaymentChargeback {}

struct Invoice {
    1: optional domain.Invoice invoice
    2: optional InvoicePayment payment
}

struct InvoicePayment {
    1: optional domain.InvoicePayment payment
    2: optional domain.InvoicePaymentAdjustment adjustment
    3: optional domain.InvoicePaymentRefund refund
    4: optional domain.InvoicePaymentChargeback chargeback
    5: optional limiter_base.Route route
}
