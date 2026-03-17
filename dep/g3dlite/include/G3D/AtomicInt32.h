/**
 @file AtomicInt32.h

 @maintainer Morgan McGuire, http://graphics.cs.williams.edu

 @created 2005-09-01
 @edited  2006-06-21
 */
#ifndef G3D_ATOMICINT32_H
#define G3D_ATOMICINT32_H

#include "G3D/platform.h"
#include "G3D/g3dmath.h"
#include <atomic>

namespace G3D {

/**
 An integer that may safely be used on different threads without
 external locking.

 Implemented using std::atomic for portability across all architectures.

 <B>BETA API</B>  This is unsupported and may change
 */
class AtomicInt32 {
private:
    std::atomic<int32_t> m_value;

public:

    /** Initial value is undefined. */
    AtomicInt32() {}

    /** Atomic set */
    explicit AtomicInt32(const int32 x) {
        m_value.store(x, std::memory_order_relaxed);
    }

    /** Atomic set */
    AtomicInt32(const AtomicInt32& x) {
        m_value.store(x.m_value.load(std::memory_order_relaxed), std::memory_order_relaxed);
    }

    /** Atomic set */
    const AtomicInt32& operator=(const int32 x) {
        m_value.store(x, std::memory_order_relaxed);
        return *this;
    }

    /** Atomic set */
    void operator=(const AtomicInt32& x) {
        m_value.store(x.m_value.load(std::memory_order_relaxed), std::memory_order_relaxed);
    }

    /** Returns the current value */
    int32 value() const {
        return m_value.load(std::memory_order_relaxed);
    }

    /** Returns the old value, before the add. */
    int32 add(const int32 x) {
        return m_value.fetch_add(x, std::memory_order_seq_cst);
    }

    /** Returns old value. */
    int32 sub(const int32 x) {
        return m_value.fetch_sub(x, std::memory_order_seq_cst);
    }

    void increment() {
        m_value.fetch_add(1, std::memory_order_seq_cst);
    }

    /** Returns zero if the result is zero after decrement, non-zero otherwise.*/
    int32 decrement() {
        return m_value.fetch_sub(1, std::memory_order_seq_cst) - 1;
    }

    /** Atomic test-and-set: if <code>*this == comperand</code> then <code>*this := exchange</code> else do nothing.
        In both cases, returns the old value of <code>*this</code>.
     */
    int32 compareAndSet(const int32 comperand, const int32 exchange) {
        int32_t expected = comperand;
        m_value.compare_exchange_strong(expected, exchange,
                                        std::memory_order_seq_cst,
                                        std::memory_order_seq_cst);
        return expected;
    }

};

} // namespace

#endif