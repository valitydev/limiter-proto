include "proto/base.thrift"
include "proto/domain.thrift"

namespace java dev.vality.limiter.payproc.context
namespace erlang limiter.context.payproc

/**
 * Контекст, получаемый из сервисов, реализующих один из интерфейсов протокола
 * (например invoicing в hellgate)
 */
struct ContextPaymentProcessing {
    1: optional PaymentProcessingOperation op
    2: optional Invoice invoice
}

union PaymentProcessingOperation {
    1: PaymentProcessingOperationInvoice invoice
    2: PaymentProcessingOperationInvoiceAdjustment invoice_adjustment
    3: PaymentProcessingOperationInvoicePayment invoice_payment
    4: PaymentProcessingOperationInvoicePaymentAdjustment invoice_payment_adjustment
    5: PaymentProcessingOperationInvoicePaymentRefund invoice_payment_refund
    6: PaymentProcessingOperationInvoicePaymentChargeback invoice_payment_chargeback
}

struct PaymentProcessingOperationInvoice {}
struct PaymentProcessingOperationInvoiceAdjustment {}
struct PaymentProcessingOperationInvoicePayment {}
struct PaymentProcessingOperationInvoicePaymentAdjustment {}
struct PaymentProcessingOperationInvoicePaymentRefund {}
struct PaymentProcessingOperationInvoicePaymentChargeback {}

struct Invoice {
    1: optional domain.Invoice invoice
    2: optional domain.InvoicePayment effective_payment
    3: optional domain.InvoiceAdjustment effective_adjustment
}

struct InvoicePayment {
    1: optional domain.InvoicePayment payment
    2: optional domain.InvoicePaymentAdjustment effective_adjustment
    3: optional domain.InvoicePaymentRefund effective_refund
    4: optional domain.InvoicePaymentChargeback effective_chargeback
}
