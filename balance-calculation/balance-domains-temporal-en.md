# Temporal Extension of Domain Theory of Balances

## Preamble

This document extends the formal theory of domains, rules, materializations, and current balances.

The base theory (balance-domains) defines:

- a space of dimensions $\mathbb D$;
- transactions with numeric values;
- additive domains;
- rules (scope) and materializations (groupBy);
- balance families $F=(D,R,M)$;
- operations conversion, roll-up, derived composition.

The base theory operates with current balances: the value of a balance row is the accumulated sum of all matching transactions without time restrictions.

The temporal extension adds time as a special dimension, enabling:

- turnover by periods;
- cumulative balance as of a date;
- hierarchical period mapping (day → month → quarter → year).

Meanwhile, the core foundation—domains, rules, materializations, additivity—remains unchanged.

---

## T1. Transaction timestamp

Each transaction $e$ carries a timestamp

$$\tau(e) \in \mathbb T,$$

where $\mathbb T$ is a linearly ordered set of time moments (for example, $\mathbb T = \mathbb R$ or $\mathbb T = \mathbb Z$ for discrete days).

### Business interpretation

$\tau(e)$ is the moment when the transaction occurred or was recorded in the system.

For example:

- $\tau(e) = \text{2025-03-15T14:30:00}$

A timestamp is not an ordinary dimension from $\mathbb D$. It does not participate in the domain prefix, is not included in the rule scope, and is not directly part of groupBy. Instead, time is processed through a special period mapping mechanism.

### Why time is not an ordinary dimension

Ordinary dimensions from $\mathbb D$ have the following properties:

1. a finite set of values $Val(d)$;
2. values are unordered (or ordering is not material to additivity);
3. groupBy on a dimension produces a finite fixed set of keys.

Time differs in these respects:

1. the set of values is infinite and monotonically growing;
2. values are strictly ordered, and this order is material;
3. the same timestamp can be aggregated at different granularities (day, month, year);
4. there exists cumulative semantics (balance as-of), which cannot be expressed by simple groupBy.

Therefore, time is introduced as a separate structure, not as an element of $\mathbb D$.

---

## T2. Granularity and period mapping function

### T2.1. Granularity

Granularity $g$ is a method of mapping a precise moment in time to a discrete period.

Let a finite set of granularities be given:

$$\mathbb G = \{g_1, \dots, g_s\},$$

ordered from coarsest to finest:

$$g_1 \prec g_2 \prec \dots \prec g_s.$$

### T2.2. Period mapping function

For each granularity $g \in \mathbb G$, a period mapping function is defined:

$$\pi_g : \mathbb T \to Per(g),$$

where $Per(g)$ is the set of periods for granularity $g$.

### T2.3. Consistency of granularities

If $g_a \prec g_b$ (meaning $g_a$ is coarser than $g_b$), then there exists a roll-down function

$$\rho_{b \to a} : Per(g_b) \to Per(g_a),$$

such that for any moment $t \in \mathbb T$:

$$\pi_{g_a}(t) = \rho_{b \to a}(\pi_{g_b}(t)).$$

In other words, a finer period uniquely determines a coarser one.

### Business interpretation

A typical set of granularities:

$$\mathbb G = \{year, quarter, month, week, day\}.$$

Period mapping functions:

- $\pi_{day}(\text{2025-03-15}) = \text{2025-03-15}$
- $\pi_{month}(\text{2025-03-15}) = \text{2025-03}$
- $\pi_{quarter}(\text{2025-03-15}) = \text{2025-Q1}$
- $\pi_{year}(\text{2025-03-15}) = \text{2025}$

Roll-down:

- $\rho_{day \to month}(\text{2025-03-15}) = \text{2025-03}$
- $\rho_{month \to year}(\text{2025-03}) = \text{2025}$

This means that knowing the day, one can uniquely determine the month, quarter, and year.

---

## T3. Temporal materialization

### T3.1. Extension of balance family

In the base theory, a family is defined as

$$F = (D, R, M).$$

In the temporal extension, a family is defined as

$$F = (D, R, M, \Theta),$$

where $\Theta$ is a temporal specification.

### T3.2. Temporal specification

A temporal specification $\Theta$ takes one of three values:

1. **Accumulated** ($\Theta = acc$): current balance, without splitting by time.
2. **Turnover** ($\Theta = turn(g)$): turnover by periods of granularity $g$.
3. **As-of** ($\Theta = asof(g)$): cumulative balance at the end of each period of granularity $g$.

### T3.3. Compatibility with base theory

If $\Theta = acc$, then the family $F = (D, R, M, acc)$ is fully equivalent to the base theory family $F = (D, R, M)$.

This means that the base theory is a special case of the temporal extension.

---

## T4. Extended canonical path

### T4.1. Definition

For a family $F = (D, R, M, \Theta)$ and a transaction $e$, the extended canonical path is defined as:

$$BalPath_F(e) = Canon\bigl(DomPath(D),\ Scope_R,\ Key_M(e),\ TemporalKey_\Theta(e)\bigr),$$

where $TemporalKey_\Theta(e)$ is defined as follows:

- if $\Theta = acc$: $TemporalKey_\Theta(e) = \varepsilon$ (empty, no temporal component);
- if $\Theta = turn(g)$: $TemporalKey_\Theta(e) = \pi_g(\tau(e))$;
- if $\Theta = asof(g)$: $TemporalKey_\Theta(e)$ is defined separately (see §T6).

### T4.2. Business interpretation

For a family with $\Theta = turn(month)$ and groupBy = (country, vertical), paths will be:

- `trx / EUR / country=EE / vertical=Food / month=2025-03`
- `trx / EUR / country=EE / vertical=Food / month=2025-04`
- `trx / EUR / country=LV / vertical=Grocery / month=2025-03`

For a family with $\Theta = acc$, paths remain as in the base theory:

- `trx / EUR / country=EE / vertical=Food`

---

## T5. Turnover balance

### T5.1. Definition

For a family $F = (D, R, M, turn(g))$, the balance for extended path $p$ is defined as

$$B_F(p) = \sum_{\substack{e \in E,\ e \in D,\ Scope_R(e)=1,\\ Key_M(e) = k_M,\ \pi_g(\tau(e)) = \omega}} Val(e),$$

where $p = Canon(DomPath(D), Scope_R, k_M, \omega)$.

### T5.2. Explanation

Turnover is the sum of contributions from transactions that:

- belong to the domain;
- satisfy the rule scope;
- have the same materialization key;
- **and fall within the same period.**

### T5.3. Additivity of turnover

Turnover balance is additive with respect to transactions:

$$B_F^{E_1 \cup E_2}(p) = B_F^{E_1}(p) + B_F^{E_2}(p).$$

This is a direct consequence of the definition: the summation formula is the same, only the transaction set is expanded.

### T5.4. Business interpretation

If a family represents "GMV by country and month", then:

- $B(\text{EE}, \text{Food}, \text{2025-03}) = 15\,000$ means: for March 2025, GMV for Estonia/Food was 15,000.
- $B(\text{EE}, \text{Food}, \text{2025-04}) = 18\,000$ means: for April 2025, GMV for Estonia/Food was 18,000.

These are precisely turnovers—sums for a period, not accumulated values.

---

## T6. As-of balance (cumulative balance)

### T6.1. Intuition

As-of balance answers the question: "what is the balance at the end of this period?"

It is not the sum for a period, but the sum of all transactions from the beginning of time through the end of the given period.

### T6.2. Definition

For a family $F = (D, R, M, asof(g))$ and a period $\omega \in Per(g)$, the cumulative balance is defined as

$$B_F^{asof}(k_M, \omega) = \sum_{\substack{e \in E,\ e \in D,\ Scope_R(e)=1,\\ Key_M(e) = k_M,\ \pi_g(\tau(e)) \le \omega}} Val(e).$$

### T6.3. Relationship with turnover

As-of balance is expressed in terms of turnover:

$$B_F^{asof}(k_M, \omega) = \sum_{\omega' \le \omega} B_F^{turn}(k_M, \omega'),$$

where the sum ranges over all periods $\omega'$ of granularity $g$ that precede $\omega$ inclusively.

Conversely, turnover is expressed in terms of as-of:

$$B_F^{turn}(k_M, \omega) = B_F^{asof}(k_M, \omega) - B_F^{asof}(k_M, \omega^{-}),$$

where $\omega^{-}$ is the preceding period.

### T6.4. Additivity of as-of

As-of balance is additive with respect to transactions:

$$B_F^{asof,\, E_1 \cup E_2}(k_M, \omega) = B_F^{asof,\, E_1}(k_M, \omega) + B_F^{asof,\, E_2}(k_M, \omega).$$

However, as-of balance is **not additive with respect to periods**: one cannot sum as-of for March and as-of for April—that would double-count the mass.

### T6.5. Business interpretation

If maintaining an accounting balance on an account:

- $B^{asof}(\text{expense/opscost/EE}, \text{2025-03}) = 450\,000$ means: at the end of March 2025, cumulative opscost expenses for Estonia total 450,000.
- $B^{asof}(\text{expense/opscost/EE}, \text{2025-04}) = 570\,000$ means: at the end of April—570,000.
- Turnover for April: $570\,000 - 450\,000 = 120\,000$.

---

## T7. Temporal roll-up

### T7.1. Definition

Temporal roll-up is a special case of conversion between families with different granularities.

Suppose there are two families:

- $F_b = (D, R, M, turn(g_b))$ — fine-grained (for example, daily);
- $F_a = (D, R, M, turn(g_a))$ — coarse-grained (for example, monthly).

If $g_a \prec g_b$, then:

$$B_{F_a}^{turn}(k_M, \omega_a) = \sum_{\substack{\omega_b \in Per(g_b),\\ \rho_{b \to a}(\omega_b) = \omega_a}} B_{F_b}^{turn}(k_M, \omega_b).$$

### T7.2. Business interpretation

Monthly GMV is the sum of daily GMV for all days in that month.

$$GMV(\text{EE}, \text{Food}, \text{2025-03}) = \sum_{d \in days(\text{2025-03})} GMV(\text{EE}, \text{Food}, d).$$

This is the standard roll-up from the base theory, applied to the temporal dimension.

### T7.3. Roll-up for as-of

For as-of balance, roll-up between granularities is defined differently.

If $g_a \prec g_b$ (for example, $g_a = month$, $g_b = day$), then:

$$B_{F_a}^{asof}(k_M, \omega_a) = B_{F_b}^{asof}(k_M, \text{last}(\omega_a)),$$

where $\text{last}(\omega_a)$ is the last period of $g_b$ contained in $\omega_a$.

### Business interpretation

The as-of balance at the end of a month equals the as-of balance on the last day of that month.

$$B^{asof}(\text{EE}, \text{2025-03}) = B^{asof}(\text{EE}, \text{2025-03-31}).$$

This is not the sum of daily as-of values (which would be nonsensical), but the value at the end of the last day.

---

## T8. Relationship between accumulated, turnover, and as-of

### T8.1. Accumulated as the limit of as-of

Accumulated balance from the base theory is as-of balance with an infinite horizon:

$$B_F^{acc}(k_M) = B_F^{asof}(k_M, +\infty) = \sum_{\omega \in Per(g)} B_F^{turn}(k_M, \omega).$$

### T8.2. Unified picture

The three types of temporal specification form the following hierarchy:

1. **Turnover** $B^{turn}(k_M, \omega)$ — the fundamental object: sum for a single period.
2. **As-of** $B^{asof}(k_M, \omega) = \sum_{\omega' \le \omega} B^{turn}(k_M, \omega')$ — cumulative sum of turnover.
3. **Accumulated** $B^{acc}(k_M) = \sum_{\omega} B^{turn}(k_M, \omega)$ — total sum of turnover across all periods.

Thus, turnover is the fundamental temporal object, while as-of and accumulated are derived.

---

## T9. Temporal operations and base operations

### T9.1. Conversion

Conversion from the base theory works without modification.

If a conversion $F_A \to F_B$ is given with path mapping $\Psi$ and numeric transformation $\Gamma$, then for temporal families, conversion is applied pointwise by period:

$$Conv_{F_A \to F_B}^{turn}(p_B, \omega) = \sum_{\substack{p_A \in PathSpace(F_A),\\ \Psi(p_A) = p_B}} \Gamma_{p_A \to p_B}\bigl(B_{F_A}^{turn}(p_A, \omega)\bigr).$$

### T9.2. Derived composition

Derived composition is also applied pointwise:

$$B_{F_*}^{turn}(p, \omega) = \Phi\bigl(B_{F_1}^{turn}(p, \omega), \dots, B_{F_n}^{turn}(p, \omega)\bigr).$$

### T9.3. Business interpretation

Monthly profit:

$$Profit^{turn}(\text{EE}, \text{2025-03}) = Income^{turn}(\text{EE}, \text{2025-03}) - Expense^{turn}(\text{EE}, \text{2025-03}).$$

Cumulative profit at the end of March:

$$Profit^{asof}(\text{EE}, \text{2025-03}) = Income^{asof}(\text{EE}, \text{2025-03}) - Expense^{asof}(\text{EE}, \text{2025-03}).$$

Both formulas are correct and follow from pointwise application of derived composition.

---

## T10. Path-space-disjointness with temporality

### T10.1. Extended rule

In the base theory, different families within a single domain must not produce intersecting path spaces.

In the temporal extension, a path includes a temporal component, therefore:

- a family with $\Theta = turn(month)$ and a family with $\Theta = turn(day)$ produce different path spaces (paths differ in granularity);
- a family with $\Theta = acc$ and a family with $\Theta = turn(month)$ also produce different path spaces (the former has no temporal component).

### T10.2. Formally

Two families $F_1 = (D, R_1, M_1, \Theta_1)$ and $F_2 = (D, R_2, M_2, \Theta_2)$ have disjoint path spaces if:

$$PathSpace(F_1) \cap PathSpace(F_2) = \varnothing.$$

A sufficient condition: if $\Theta_1 \ne \Theta_2$, then paths are automatically distinguished by the temporal component.

If $\Theta_1 = \Theta_2$, the standard path-space-disjointness rule from the base theory applies.

---

## T11. Materialization and storage

### T11.1. Turnover as the fundamental storage object

Among the three temporal objects, turnover is the fundamental one:

- as-of is computed as the cumulative sum of turnover;
- accumulated is computed as the total sum of turnover.

Therefore, it suffices to materialize turnover, and as-of and accumulated can be computed (or cached as derived).

### T11.2. Incrementality of writes

When a new transaction $e$ arrives:

1. the domain $D$ is determined;
2. for each active family $F = (D, R, M, \Theta)$:
   - check $Scope_R(e) = 1$;
   - compute $Key_M(e)$;
   - if $\Theta = turn(g)$: compute $\omega = \pi_g(\tau(e))$;
   - update $B_F(k_M, \omega)\ {+}{=}\ Val(e)$.
3. if the family has $\Theta = acc$: update $B_F(k_M)\ {+}{=}\ Val(e)$.

Write complexity: $O(k)$, where $k$ is the number of active families in the domain.

### T11.3. Read complexity

- Turnover by key $(k_M, \omega)$: $O(1)$.
- Accumulated by key $k_M$: $O(1)$ (if materialized).
- As-of by key $(k_M, \omega)$: $O(|\omega|)$ if computed from turnover, or $O(1)$ if cached.

---

## T12. Limitations of the temporal extension

The temporal extension deliberately does not include:

1. **Bi-temporal model** (transaction time vs. business time). Only one timestamp per transaction is considered.
2. **Retroactive corrections**. If a transaction retroactively modifies a past period, this is not described as a separate operation—it is an ordinary transaction with the corresponding $\tau(e)$.
3. **Snapshots**. Periodic system state snapshots are an infrastructure operation, not part of the formal theory.
4. **Time-weighted balances**. Time-weighted averages (for example, average balance over a period) require additional machinery and are not included in the current extension.

Each of these directions can be added as a subsequent extension without modifying the current core.

---

## T13. Final schema with temporality

$$\text{Transaction } (e, \tau(e)) \to \text{Domain } D \to \text{Rule } R \to \text{Materialization } M \to \text{Temporal specification } \Theta \to \text{Balance row}$$

where:

- domain isolates additivity;
- rule filters by scope;
- materialization determines the key;
- temporal specification determines how time participates in the key;
- balance row stores the resulting value.

---

## T14. Compatibility with the base core

The temporal extension does not modify the base core:

| Base theory construct | Change in extension |
|---|---|
| Domain | No change |
| Domain disjointness | No change |
| Rule (scope) | No change |
| Materialization (groupBy) | No change |
| Family $F = (D,R,M)$ | Extended to $F = (D,R,M,\Theta)$ |
| Canonical path | Extended with temporal component |
| Additivity with respect to transactions | Preserved |
| Path-space-disjointness | Extended accounting for $\Theta$ |
| Conversion | Applied pointwise by period |
| Derived composition | Applied pointwise by period |
| Roll-up | Extended: spatial and temporal |

The base theory is a special case of the temporal extension when $\Theta = acc$.

---

## T15. Business examples of temporality

### T15.1. Example: GMV by vertical and month

Domain:

- `basis = trx`
- `currency = EUR`

Rule:

- completed GMV events

Materialization:

- `groupBy = (country, vertical)`
- $\Theta = turn(month)$

Transaction stream for Q1 2025:

| date | country | vertical | amount |
|---|---|---|---|
| 2025-01-05 | EE | Food | 200 |
| 2025-01-18 | EE | Food | 350 |
| 2025-01-22 | EE | Grocery | 100 |
| 2025-02-03 | EE | Food | 400 |
| 2025-02-14 | LV | Food | 150 |
| 2025-02-28 | EE | Grocery | 250 |
| 2025-03-10 | EE | Food | 500 |
| 2025-03-15 | LV | Food | 300 |
| 2025-03-20 | LV | Grocery | 175 |

**Result: turnover balance rows**

| path | month | turnover |
|---|---|---|
| trx / EUR / EE / Food | 2025-01 | 550 |
| trx / EUR / EE / Grocery | 2025-01 | 100 |
| trx / EUR / EE / Food | 2025-02 | 400 |
| trx / EUR / LV / Food | 2025-02 | 150 |
| trx / EUR / EE / Grocery | 2025-02 | 250 |
| trx / EUR / EE / Food | 2025-03 | 500 |
| trx / EUR / LV / Food | 2025-03 | 300 |
| trx / EUR / LV / Grocery | 2025-03 | 175 |

**Read:** query `Read(trx / EUR / EE / Food, 2025-02)` returns 400.

---

### T15.2. Example: as-of balance on an accounting account

Domain:

- `basis = trx`
- `currency = EUR`

Rule:

- `account_type = expense`
- `account_subtype = ops_cost`

Materialization:

- `groupBy = (country)`
- $\Theta = asof(month)$

Transaction stream:

| date | country | amount |
|---|---|---|
| 2025-01-10 | EE | 30 000 |
| 2025-01-25 | EE | 20 000 |
| 2025-02-05 | EE | 45 000 |
| 2025-02-20 | EE | 15 000 |
| 2025-03-12 | EE | 40 000 |

**Result: turnover by month**

| country | month | turnover |
|---|---|---|
| EE | 2025-01 | 50 000 |
| EE | 2025-02 | 60 000 |
| EE | 2025-03 | 40 000 |

**Result: as-of balance (cumulative)**

| country | month | as-of |
|---|---|---|
| EE | 2025-01 | 50 000 |
| EE | 2025-02 | 110 000 |
| EE | 2025-03 | 150 000 |

Verification of the turnover and as-of relationship:

- $B^{asof}(\text{EE}, \text{2025-02}) = B^{asof}(\text{EE}, \text{2025-01}) + B^{turn}(\text{EE}, \text{2025-02}) = 50\,000 + 60\,000 = 110\,000$
- $B^{turn}(\text{EE}, \text{2025-03}) = B^{asof}(\text{EE}, \text{2025-03}) - B^{asof}(\text{EE}, \text{2025-02}) = 150\,000 - 110\,000 = 40\,000$

**Result: accumulated balance (without temporality)**

$$B^{acc}(\text{EE}) = 50\,000 + 60\,000 + 40\,000 = 150\,000$$

Accumulated equals as-of for the last known period—this is an expected property.

---

### T15.3. Example: temporal roll-up (day → month → quarter)

Domain:

- `basis = trx`
- `currency = EUR`

Rule:

- completed GMV events, `country = EE`, `vertical = Food`

Materialization:

- `groupBy = ()` (single row, no spatial key)
- $\Theta = turn(day)$

Daily turnover for January 2025 (fragment):

| day | turnover |
|---|---|
| 2025-01-05 | 200 |
| 2025-01-12 | 180 |
| 2025-01-18 | 350 |
| 2025-01-25 | 270 |

**Roll-up to month:**

$$B^{turn}(\text{2025-01}) = 200 + 180 + 350 + 270 = 1\,000$$

Daily turnover for February 2025 (fragment):

| day | turnover |
|---|---|
| 2025-02-03 | 400 |
| 2025-02-14 | 250 |
| 2025-02-22 | 150 |

$$B^{turn}(\text{2025-02}) = 400 + 250 + 150 = 800$$

Daily turnover for March 2025 (fragment):

| day | turnover |
|---|---|
| 2025-03-10 | 500 |
| 2025-03-20 | 300 |

$$B^{turn}(\text{2025-03}) = 500 + 300 = 800$$

**Roll-up to quarter:**

$$B^{turn}(\text{2025-Q1}) = B^{turn}(\text{2025-01}) + B^{turn}(\text{2025-02}) + B^{turn}(\text{2025-03}) = 1\,000 + 800 + 800 = 2\,600$$

This is a chain: $day \to month \to quarter$, each step a standard temporal roll-up.

---

### T15.4. Example: derived composition with temporality

Domain:

- `basis = trx`
- `currency = EUR`

Two families:

**Family 1** — Income by country:

- Rule: `account_type = income`
- Materialization: `groupBy = (country)`, $\Theta = turn(month)$

**Family 2** — Expense by country:

- Rule: `account_type = expense`
- Materialization: `groupBy = (country)`, $\Theta = turn(month)$

Data:

| family | country | month | turnover |
|---|---|---|---|
| Income | EE | 2025-01 | 200 000 |
| Income | EE | 2025-02 | 250 000 |
| Income | EE | 2025-03 | 220 000 |
| Expense | EE | 2025-01 | 150 000 |
| Expense | EE | 2025-02 | 180 000 |
| Expense | EE | 2025-03 | 160 000 |

**Derived family** — Profit by country:

$$Profit^{turn}(\text{EE}, \omega) = Income^{turn}(\text{EE}, \omega) - Expense^{turn}(\text{EE}, \omega)$$

| country | month | profit (turnover) |
|---|---|---|
| EE | 2025-01 | 50 000 |
| EE | 2025-02 | 70 000 |
| EE | 2025-03 | 60 000 |

**Derived as-of** — cumulative profit:

| country | month | profit (as-of) |
|---|---|---|
| EE | 2025-01 | 50 000 |
| EE | 2025-02 | 120 000 |
| EE | 2025-03 | 180 000 |

Verification: derived composition is pointwise by period, and cumulative profit equals the difference of cumulative income and expense:

- $Profit^{asof}(\text{EE}, \text{2025-03}) = Income^{asof}(\text{EE}, \text{2025-03}) - Expense^{asof}(\text{EE}, \text{2025-03})$
- $= (200\,000 + 250\,000 + 220\,000) - (150\,000 + 180\,000 + 160\,000) = 670\,000 - 490\,000 = 180\,000$

---

### T15.5. Example: conversion between granularities with different domains

Domain 1 ($D_1$):

- `basis = trx`, `currency = EUR`

Family $F_1$: GMV by country, $\Theta = turn(month)$

| country | month | turnover (EUR) |
|---|---|---|
| EE | 2025-01 | 10 000 |
| EE | 2025-02 | 12 000 |
| LV | 2025-01 | 8 000 |
| LV | 2025-02 | 9 000 |

Domain 2 ($D_2$):

- `basis = rep`, `currency = USD`

Family $F_2$: GMV by country, $\Theta = turn(month)$

Conversion $F_1 \to F_2$ with exchange rate EUR/USD = 1.08:

- Path mapping: $\Psi$ changes the domain prefix from `trx/EUR` to `rep/USD`
- Numeric transformation: $\Gamma(x) = x \times 1.08$

Result:

| country | month | turnover (USD) |
|---|---|---|
| EE | 2025-01 | 10 800 |
| EE | 2025-02 | 12 960 |
| LV | 2025-01 | 8 640 |
| LV | 2025-02 | 9 720 |

Conversion is applied pointwise by period: each monthly turnover is converted independently.

---

### T15.6. Example: multiple families with different temporal specifications in one domain

Domain:

- `basis = trx`, `currency = EUR`

Within a single domain, three families simultaneously exist for the same scope (`account_type = expense`, `groupBy = (country)`):

| family | $\Theta$ | what it stores |
|---|---|---|
| $F_1$ | $acc$ | current accumulated balance |
| $F_2$ | $turn(month)$ | monthly turnover |
| $F_3$ | $turn(day)$ | daily turnover |

When a transaction $e$ arrives with $\tau(e) = \text{2025-03-15}$, $Val(e) = 1\,000$, $country = \text{EE}$:

- $F_1$: update $B_{F_1}(\text{EE})\ {+}{=}\ 1\,000$
- $F_2$: update $B_{F_2}(\text{EE}, \text{2025-03})\ {+}{=}\ 1\,000$
- $F_3$: update $B_{F_3}(\text{EE}, \text{2025-03-15})\ {+}{=}\ 1\,000$

Path-space-disjointness is satisfied automatically: the paths for $F_1$, $F_2$, $F_3$ are distinguished by the presence and granularity of the temporal component.

Invariants that must hold:

$$B_{F_1}(\text{EE}) = \sum_{\omega} B_{F_2}(\text{EE}, \omega) = \sum_{d} B_{F_3}(\text{EE}, d)$$

$$B_{F_2}(\text{EE}, \text{2025-03}) = \sum_{d \in days(\text{2025-03})} B_{F_3}(\text{EE}, d)$$
