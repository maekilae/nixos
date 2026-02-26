#pragma once

#include <qobject.h>
#include <qqmlintegration.h>

namespace emphshell {

class CalcResult : public QObject {
        Q_OBJECT
        QML_ELEMENT
        QML_UNCREATABLE("Result object cannot be created directly")

        Q_PROPERTY(QString result READ result CONSTANT)
        Q_PROPERTY(QString expr READ expr CONSTANT)
        Q_PROPERTY(QString error READ error CONSTANT)

      public:
        explicit CalcResult(QString result, QString expr, QString error,
                            QObject* parent = nullptr);
        [[nodiscard]] QString result() const;
        [[nodiscard]] QString expr() const;
        [[nodiscard]] QString error() const;

      private:
        QString m_result;
        QString m_expr;
        QString m_error;
};

class Qalculator : public QObject {
        Q_OBJECT
        QML_ELEMENT
        QML_SINGLETON
      public:
        explicit Qalculator(QObject* parent = nullptr);

        Q_INVOKABLE CalcResult* eval(const QString& expr,
                                     bool printExpr = true);
};

} // namespace emphshell
