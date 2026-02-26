#include "calc.hpp"

#include <libqalculate/qalculate.h>
#include <libqalculate/includes.h>
#include <qvariant.h>

namespace emphshell {

CalcResult::CalcResult(QString result, QString expr, QString error, QObject* parent)
    : QObject(parent)
    , m_result(result)
    , m_expr(expr)
    , m_error(error) {}

QString CalcResult::result() const {
    return m_result;
}

QString CalcResult::expr() const {
    return m_expr;
}

QString CalcResult::error() const {
    return m_error;
}


Qalculator::Qalculator(QObject* parent)
    : QObject(parent) {
    if (!CALCULATOR) {
        new Calculator();
        CALCULATOR->loadExchangeRates();
        CALCULATOR->loadGlobalDefinitions();
        CALCULATOR->loadLocalDefinitions();
    }
}

CalcResult* Qalculator::eval(const QString& expr, bool printExpr) {
    if (expr.isEmpty()) {
        return new CalcResult(QString(""), QString(""), QString(""), this);
    }

    // Below settings decrease the amount of valid expressions
    // this is done since query such as "firefox" should not be evaluated as a mathematical expression
    ParseOptions parseOpt;
    parseOpt.variables_enabled = false;
    parseOpt.functions_enabled = false;
    parseOpt.unknowns_enabled = false;
    parseOpt.units_enabled = false;

    EvaluationOptions evalOpt;
    evalOpt.parse_options = parseOpt;
    evalOpt.approximation = APPROXIMATION_TRY_EXACT;
    evalOpt.auto_post_conversion = POST_CONVERSION_NONE;
    evalOpt.structuring = STRUCTURING_SIMPLIFY;
    evalOpt.calculate_functions = false;

    PrintOptions printOpt;
    printOpt.number_fraction_format = FRACTION_DECIMAL;

    std::string parsed;
    std::string result = CALCULATOR->calculateAndPrint(
        CALCULATOR->unlocalizeExpression(expr.toStdString(), evalOpt.parse_options), 100, evalOpt, printOpt, &parsed);

    std::string error;
    while (CALCULATOR->message()) {
        if (!CALCULATOR->message()->message().empty()) {
            if (CALCULATOR->message()->type() == MESSAGE_ERROR) {
                error += "error: ";
            } else if (CALCULATOR->message()->type() == MESSAGE_WARNING) {
                error += "warning: ";
            }
            error += CALCULATOR->message()->message();
        }
        CALCULATOR->nextMessage();
    }
    return new CalcResult(QString::fromStdString(result), QString::fromStdString(parsed), QString::fromStdString(error), this);

}
}
