#include "search.hpp"

#include <cmath>
#include <iostream>
#include <qtypes.h>
#include <vector>
#include <string>
#include <climits>
#include <algorithm>

#include <math.h>

// Define the alphabet size (ASCII)
const int ALPHABET_SIZE = 256;

namespace emphshell {
Bitap::Bitap(QObject *parent) : QObject(parent) {
    m_k = 3;
}

void Bitap::setK(int k) {
    m_k = k;
}

    /**
     * Performs a fuzzy search of the pattern in the text allowing up to k errors.
     * * @param text The text to search in.
     * @param pattern The pattern to search for.
     * @param k The maximum number of errors (Levenshtein distance) allowed.
     * @return The ending index of the first match in the text, or -1 if not found.
     */
qint32 Bitap::search(const std::string& text, const std::string& pattern) {
    int m = pattern.length();
    int k =  std::min(m, m_k) - 2;
    k = std::max(k, 0);

    if (m > 63) return -1;
    if (m == 0) return 0;

    uint64_t pattern_mask[256];
    for (int i = 0; i < 256; ++i) pattern_mask[i] = ~0ULL;
    for (int i = 0; i < m; ++i) {
        pattern_mask[static_cast<unsigned char>(pattern[i])] &= ~(1ULL << i);
    }

    std::vector<uint64_t> R(k + 1, ~0ULL);
    uint64_t match_bit = 1ULL << (m - 1);
    int min_errors = k + 1;

    for (int i = 0; i < text.length(); ++i) {
        uint64_t char_mask = pattern_mask[static_cast<unsigned char>(text[i])];
        uint64_t old_Rd1 = R[0];

        R[0] = (R[0] << 1) | char_mask;

        for (int d = 1; d <= k; ++d) {
            uint64_t tmp = R[d];
            R[d] = ((R[d] << 1) | char_mask) &
                    (old_Rd1 << 1) &
                    (old_Rd1) &
                    (R[d-1] << 1);
            old_Rd1 = tmp;
        }

        int check_limit = std::min(k, min_errors - 1);

        for (int d = 0; d <= check_limit; ++d) {
            if ((R[d] & match_bit) == 0) {
                min_errors = d;
                if (min_errors == 0) return 0;
                break;
            }
        }
    }

    if (min_errors > k) {
        return -1;
    }

    return min_errors;
}
}
