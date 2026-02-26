#pragma once
#include "appdb.hpp"

#include <qobject.h>
#include <qqmlintegration.h>
#include <qt6/QtCore/qtypes.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace emphshell {
    class Bitap : public QObject {
        Q_OBJECT
        QML_ELEMENT
        Q_PROPERTY(qint32 k READ k WRITE setK)
    public:
        explicit Bitap(QObject *parent = nullptr);
        Q_INVOKABLE qint32 search(const std::string& text, const std::string& pattern);
        [[nodiscard]] qint32 k() const;
        void setK(int k);
        private:
            qint32 m_k;
    };

}
