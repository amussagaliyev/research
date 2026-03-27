# Balance Calculation Theory

A mathematical framework for computing account balances over event streams, built from first principles using formal set-theoretic definitions.

## Overview

The theory addresses a fundamental problem: given a stream of transactions in a multi-dimensional measurement space, how to rigorously define, compute, and aggregate balances — ensuring strict additivity isolation, unambiguous transaction assignment, and O(1) balance reads.

The framework is general enough to cover classical accounting balances, GMV aggregates, reporting-basis conversions, and analytical roll-ups — all within one unified formal model.

## Documents

The theory is developed across four papers, each extending the previous one:

### 1. Formal Theory of Domains (`balance-domains`)

The foundational layer. Defines the measurement space as a set of dimensions, introduces additive domains (classes of transactions that may be summed together), rules (scope predicates), and materializations (groupBy projections). Each balance family F = (D, R, M) produces a set of balance rows addressed by canonical paths. Covers conversions between domains, roll-ups, and derived balance composition.

Available in: [English](balance-domains-en.md) | [Russian](balance-domains.md)

### 2. Temporal Extension (`balance-domains-temporal`)

Extends the base domain theory with time as a special dimension. Introduces transaction timestamps, hierarchical period mappings (day → month → quarter → year), period-turnovers, and cumulative balances as-of-a-date. Time is treated separately from ordinary dimensions because it is linearly ordered and potentially infinite, requiring its own aggregation mechanism.

Available in: [English](balance-domains-temporal-en.md) | [Russian](balance-domains-temporal.md)

### 3. Balance Trees and External Projections (`balance-tree`)

Defines a strictly additive balance tree where each transaction's contribution is placed at exactly one node, preserving the local and global balance equation. Projections, marginals, and filter-based aggregates that would break tree additivity are placed in an external projection layer. This separation ensures no double-counting while still supporting analytical queries.

Available in: [English](balance-tree-en.md) | [Russian](balance-tree.md)

### 4. Generalised Balance Algebras (`balance-generalized`)

Abstracts away the choice of summation as the aggregation function. Defines the class of admissible aggregation functions (balance algebras) and shows that each function induces its own parent–children composition rule. Classical sum-based additivity becomes one special case alongside weighted averages, max, min, and other monoidal operations. Identifies which properties of the model are truly fundamental and which are consequences of choosing summation.

Available in: [English](balance-generalized-en.md) | [Russian](balance-generalized.md)

## Key Concepts

- **Measurement space** — a finite set of dimensions (account type, country, currency, etc.) forming a multi-dimensional coordinate system for balances
- **Additive domain** — a class of transactions whose values may be meaningfully summed (e.g., "transaction-basis EUR" vs "reporting-basis USD")
- **Balance family** — a triple (Domain, Rule, Materialization) that produces a named set of balance rows
- **Canonical path** — the full-dimensional address of a balance row, enabling O(1) reads
- **Balance tree** — a hierarchical structure preserving strict additivity, with projections handled externally
- **Balance algebra** — a generalisation allowing arbitrary aggregation functions beyond summation
