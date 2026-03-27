# Formal Theory of Domains, Rules, Materializations, and Current Balances

## 1. Purpose of the Model

The model describes a system that maintains current balances in a discrete measurement space based on a transaction stream.

The model must provide:

- strict additivity isolation;
- unambiguous transaction assignment to a domain;
- unambiguous balance materialization along canonical paths;
- balance reading at $O(1)$ via complete canonical path;
- ability to configure both accounting balances and application aggregates such as GMV;
- ability to construct transformations and derived balances on top of already defined balance families.

The basic idea of the model is:

1. each transaction has a full canonical path in the overall measurement space;
2. each transaction belongs to exactly one additive domain;
3. within that domain, rules are applied;
4. each rule together with materialization generates a balance family;
5. each balance row is addressed by the full canonical path;
6. the value of a balance row equals the sum of all transaction contributions that mapped to that path.

### Business Interpretation

One and the same economic operation may participate in different balances and reports, but only within a precisely defined class of additivity.

For example, the system may distinguish:

- transaction-basis EUR,
- transaction-basis USD,
- reporting-basis EUR.

These are different sum classes, and they should not mix automatically.
Within one such class, one may maintain:

- accounting balance by account,
- balance by country,
- balance by legal entity,
- GMV by vertical,
- other materialized balances.

---

## 2. Measurement Space

Let a finite set of measurements be given
$$\mathbb D = \{d_1,\dots,d_n\}.$$

For each measurement $d \in \mathbb D$, the set of admissible values is given
$$Val(d).$$

On the set $\mathbb D$, a single global order is fixed
$$d_1 \prec d_2 \prec \dots \prec d_n.$$

This order is used to construct all canonical paths.

### Business Interpretation

$\mathbb D$ is the complete coordinate dictionary of the system. For example:

- `basis`
- `currency`
- `account_type`
- `account_subtype`
- `country`
- `vertical`
- `legal_entity`
- `participant`
- `aging_bucket`

The single order ensures that one and the same balance cannot be addressed in two different ways.

---

## 3. Transaction

A transaction $e$ is a partial function on the measurement space:
$$e : \mathbb D \rightharpoonup \bigcup_{d\in\mathbb D} Val(d).$$

In addition to measurement values, a transaction carries a numerical contribution, given by the function
$$Val(e) \in \mathbb R.$$

At this stage, $Val(e)$ is viewed as an abstract numerical function returning a single number.

### Business Interpretation

A transaction is an elementary accounting event.

Example of an accounting transaction:

- `basis = trx`
- `currency = EUR`
- `account_type = expense`
- `account_subtype = ops_cost`
- `country = EE`
- `legal_entity = Bolt Ops OÜ`
- `Val(e) = 120`

Example of a GMV event:

- `basis = trx`
- `currency = EUR`
- `country = LV`
- `vertical = Food`
- `Val(e) = 45`

The model does not fix in advance what exactly $Val(e)$ represents. It may be:

- signed accounting amount,
- GMV amount,
- fee amount,
- net amount.

---

## 4. Complete Canonical Path of a Transaction

The complete canonical path of a transaction $e$, denoted
$$Path(e),$$
is constructed across all measurements in the system $\mathbb D$ in global order.

For each measurement $d_i$:

- if $e(d_i)$ is defined, the corresponding path segment is included;
- if $e(d_i)$ is not defined, the segment remains empty or absent depending on implementation.

In theory, it suffices to think of $Path(e)$ as the complete ordered description of the transaction across all measurements in the system.

### Business Interpretation

This is the complete address of the transaction in the system.

If a transaction is described as:

- `basis = trx`
- `currency = EUR`
- `account_type = expense`
- `account_subtype = ops_cost`
- `country = EE`
- `vertical = Food`

then its complete path is all these values written in one standard order.

This is not yet a balance or an aggregate. It is the complete coordinate record of the original event, from which further will be extracted:

- domain prefix,
- rule scope,
- materialization key.

---

## 5. Additive Domain

### 5.1. Intuition

An additive domain specifies the maximum class of transactions that may legitimately be summed together.

The domain isolates additivity.

Each transaction must belong to exactly one active domain.

---

### 5.2. Domain as a Canonical Prefix Pattern

Let domain $D$ be defined on an initial segment of measurements
$$(d_1,\dots,d_r), \qquad r \le n.$$

For each measurement $d_i$, the domain specifies the set of admissible values
$$S_i \subseteq Val(d_i).$$

Then the domain is defined as a canonical prefix pattern:
$$D = ((d_1,S_1),\dots,(d_r,S_r)).$$

This pattern is called the domain canonical prefix and is denoted
$$DomPath(D).$$

### Business Interpretation

A domain fixes the class of sum.

For example, one may define domains:

1. `trx + EUR`
$$D_1 = \{ basis = trx,\ currency = EUR \}$$

2. `trx + USD`
$$D_2 = \{ basis = trx,\ currency = USD \}$$

3. `rep + EUR`
$$D_3 = \{ basis = rep,\ currency = EUR \}$$

This means that:

- transaction-basis EUR,
- transaction-basis USD,
- reporting-basis EUR

exist in different domains and do not mix automatically.

---

### 5.3. Transaction Membership in a Domain

A transaction $e$ belongs to domain $D$ if its complete path is consistent with the domain prefix.

Formally:
$$e \in D \iff \forall i=1,\dots,r:\ e(d_i)\text{ is defined and } e(d_i)\in S_i.$$

### Explanation of the Formula

The domain checks only those measurements that it itself specifies.
For each such measurement, the transaction must:

1. have a value;
2. fall into the domain's admissible set.

### Business Interpretation

If a domain requires:

- `basis = trx`
- `currency = EUR`

then a transaction:

- with `basis = trx, currency = EUR` belongs to the domain;
- with `basis = trx, currency = USD` does not;
- with `basis = rep, currency = EUR` does not.

If a domain requires:

- `basis = trx`
- `currency = EUR`
- `country in {EE, LV}`

then a transaction with `country = LT` does not belong to it.

---

### 5.4. Properties of an Active Domain System

#### 5.4.1. Disjointness

For any two distinct active domains $D_1 \ne D_2$:
$$e \in D_1 \Rightarrow e \notin D_2.$$

#### 5.4.2. Completeness

For any served transaction $e$, there exists exactly one active domain $D$ such that
$$e \in D.$$

### Business Interpretation

Active domains must form a correct partition of the transaction stream.

A correct set of domains:

- `trx + EUR`
- `trx + USD`
- `rep + EUR`

An incorrect set of domains:

- `trx + {EUR, USD}`
- `trx + EUR`

because any `trx + EUR` transaction will fall into both domains.

---

## 6. Rule Within a Domain

### 6.1. Intuition

After a transaction enters a domain, rules are applied within that domain.

A rule specifies a narrower business semantics within the domain.

---

### 6.2. Rule Scope

A rule $R$ defines a function
$$Scope_R(e)\in\{0,1\}.$$

A transaction participates in rule $R$ if
$$e\in D \land Scope_R(e)=1.$$

### Business Interpretation

If the domain is all `trx + EUR`, then a rule may select within it:

- only `account_type = income`,
- only `account_type = expense`,
- only `country in {EE, LV}`,
- only `vertical = Food`,
- only `legal_entity = Bolt Ops OÜ`.

The domain fixes the sum class, and the rule specifies which balance or aggregate within that class we wish to maintain.

---

## 7. Materialization

### 7.1. Intuition

Materialization determines the key by which a balance is actually stored and read.

One rule may have one or several materializations.

---

### 7.2. Materialization Key

Let materialization $M$ be defined by an ordered list of measurements
$$GroupBy_M = (g_1,\dots,g_m).$$

Then, if all corresponding transaction values are defined,
$$Key_M(e) = (e(g_1),\dots,e(g_m)).$$

### Business Interpretation

If `groupBy = (country, vertical)`, then one and the same rule materializes different rows for:

- `(EE, Food)`
- `(EE, Grocery)`
- `(LV, Food)`
- `(LV, Grocery)`

If `groupBy = (country)`, then materialization becomes coarser to:

- `EE`
- `LV`
- `LT`

---

### 7.3. Combining Scope and GroupBy

If a measurement is used both in `scope` and in `groupBy`, then in the canonical path it appears once.

In this case:

- `scope` restricts the admissible values;
- `groupBy` makes the measurement an addressable coordinate.

### Business Example

Configuration:

```json
{
  "scope": { "country": ["EE", "LV"] },
  "groupBy": ["vertical", "country"]
}
```
means:
- the balance includes only EE and LV;
- within the balance, the key differs by vertical and country.

That is, country simultaneously:
- restricts the scope,
- and is a coordinate of the key.

---

## 8. Balance Family

### 8.1. Definition

For fixed domain $D$, rule $R$, and materialization $M$, a balance family is defined as
$$F=(D,R,M).$$

This is the set of all balance rows generated by one and the same semantics:

- one domain,
- one scope,
- one materialization rule.

### Business Interpretation

If a rule says:

- `scope: country in {EE, LV}`
- `groupBy: (vertical, country)`

then the family is not one row, but the entire set of rows:

- `(Food, EE)`
- `(Food, LV)`
- `(Grocery, EE)`
- `(Grocery, LV)`
- and so on.

A family is a "balance type," and a row is a specific cell of that type.

---

### 8.2. Balance Row

A balance row is one specific materialized record of family $F$, addressed by one complete canonical path $p$.

---

## 9. Canonical Path of a Balance Row

### 9.1. Intuition

Reading should occur along one complete canonical path that includes all semantic addressing of the balance row.

---

### 9.2. Definition

For family $F=(D,R,M)$ and transaction $e$, the canonical path of the materialized balance row is defined as
$$BalPath_F(e)=Canon\bigl(DomPath(D), Scope_R, Key_M(e)\bigr),$$
where $Canon$ is the operation of canonical path normalization.

---

### 9.3. Requirements for Canonization

The operation $Canon$ must:

1. construct the path in global measurement order;
2. not duplicate measurements if they appear in the domain, scope, and key;
3. preserve:
    - the domain part,
    - scope constraints,
    - key values.

### Business Interpretation

The read path must contain all information that affects the meaning of the balance row.

For example, we must distinguish:

- `trx / EUR / country=EE / vertical=Food`
- `rep / EUR / country=EE / vertical=Food`

even if the suffix `(country=EE, vertical=Food)` is the same.
The distinction is provided by the domain prefix.

---

## 10. Balance of a Family

For family $F=(D,R,M)$, the balance at path $p$ is defined as
$$B_F(p) = \sum_{\substack{e\in E\\ e\in D\\ Scope_R(e)=1\\ BalPath_F(e)=p}} Val(e).$$

### Explanation of the Formula

The sum includes all transactions that:

- belong to the domain,
- satisfy the rule scope,
- under materialization generate the same canonical path.

### Business Interpretation

If you maintain a GMV family by `(country, vertical)`, then the row

$$p = (trx,\ EUR,\ country=EE,\ vertical=Food)$$

contains the sum of all GMV transactions in EE/Food on transaction-basis EUR.

---

## 11. Current Balance

At this stage, only current balance is considered.

That is, only the accumulated sum of all matching transactions is counted. The model does not yet include:

- turnovers by periods;
- daily, monthly, quarterly buckets;
- snapshots;
- balances as of date.

### Business Interpretation

If new transactions arrive today, they simply add to the current balance row. History by periods is not yet materialized separately.

---

## 12. Read Operation

Reading is defined by complete canonical path:
$$Read(p)=B(p).$$

If path $p$ corresponds to an existing materialized row, the value is returned. Otherwise, an error.

### Complexity Requirement

With materialization and indexing in place, reading should execute at
$$O(1).$$

### Business Interpretation

The client should not guess the config. The client must know the complete canonical path.

Examples of read paths:

- `trx / EUR / expense / ops_cost / EE / Bolt Ops OÜ`
- `rep / EUR / GMV / country=LV / vertical=Food`

If such a path is supported by the system, the balance is read directly.

---

## 13. Uniqueness of Paths Within a Domain

### 13.1. Intuition

For reading to be unambiguous, different active families within one domain should not generate overlapping path spaces.

---

### 13.2. Path-space-disjointness

For two different families $F_1=(D,R_1,M_1)$ and $F_2=(D,R_2,M_2)$ within one domain $D$, it must hold that
$$PathSpace(F_1)\cap PathSpace(F_2)=\varnothing.$$

### Business Interpretation

Within one domain, one cannot have two active rules/materializations that could generate the same balance path.

Prohibited example:

Rule 1:
```json
{
  "scope": { "country": ["EE", "LV"] },
  "groupBy": ["vertical", "country"]
}
```

Rule 2:
```json
{
  "scope": { "country": ["EE", "LT"] },
  "groupBy": ["vertical", "country"]
}
```
Both rules could generate path (country=EE, vertical=Food), so they should not be simultaneously active.

---

## 14. Additivity

Additivity is guaranteed within one fixed family $F$.

If $E_1$ and $E_2$ are two sets of transactions, then
$$B_F^{E_1\cup E_2}(p)=B_F^{E_1}(p)+B_F^{E_2}(p).$$

### Business Interpretation

If you have a family "GMV by country and vertical," then it is additive across transactions: you can compute part of the data separately and then combine the results.

This property applies to one family, not to the entire domain automatically.

---

## 15. Structural Properties of Domains

Structural properties, rather than computational operations, are correctly defined over domains.

### 15.1. Equality of Domains

Two domains are equal if their domain templates coincide.

### 15.2. Disjointness of Domains

Domains are disjoint if there exists no transaction belonging to both.

### 15.3. Completeness of a Domain System

A domain system is complete relative to the input stream if any served transaction falls into exactly one domain.

### Business Examples

A correct system:

- `trx + EUR`
- `trx + USD`
- `rep + EUR`

An incorrect system:

- `trx + {EUR,USD}`
- `trx + EUR`

because `trx + EUR` transactions fall into both domains.

---

## 16. Operations Over Families

Computational operations are defined not over domains, but over families.

### 16.1. Conversion

Conversion is a unary operation that transforms one family into another.

Suppose there are families
$$F_A,\quad F_B.$$

Conversion is defined by:

- a path mapping
$$\Psi : PathSpace(F_A)\to PathSpace(F_B),$$
- a numerical transformation rule
$$\Gamma : \mathbb R \to \mathbb R$$
  or more generally $\Gamma_{p_A\to p_B}$.

Then
$$Conv_{F_A\to F_B}(p_B) = \sum_{\substack{p_A\in PathSpace(F_A)\\ \Psi(p_A)=p_B}} \Gamma_{p_A\to p_B}\bigl(B_{F_A}(p_A)\bigr).$$

### Business Interpretation

This is the general mechanism for translating balances.

Examples:

- from detailed balance to coarser;
- from `trx` family to `rep` family if there is a correct transformation rule;
- from one key schema to another.

---

### 16.2. Roll-up as a Special Case of Conversion

Roll-up is a conversion in which:

- the domain does not change;
- the numerical transformation is the identity:
$$\Gamma(x)=x;$$
- the path mapping is many-to-one, collapsing a more detailed path into a coarser one.

### Business Example

If there is a family:

- `GMV by (country, vertical)`

and a family:

- `GMV by (country)`

then
$$GMV(country)=\sum_{vertical} GMV(country, vertical)$$

this is a roll-up and also a special case of conversion.

---

### 16.3. Derived Composition

Derived composition is an operation over multiple families:
$$Der_\Phi(F_1,\dots,F_n)=F_*.$$

At the value level:
$$B_{F_*}(p) = \Phi\bigl(B_{F_1}(p),\dots,B_{F_n}(p)\bigr).$$

### Business Examples

1. Profit:
$$Profit(country)=Income(country)-Expense(country)$$

2. Adjusted balance:
$$Corrected(p)=Base(p)+Adjustment(p)$$

3. Total GMV:
$$TotalGMV = GMV_{Food} + GMV_{Grocery}$$

### Why This Is Not Conversion

If
$$F_1 + F_2 = F_3$$
then $F_3$ depends on two sources, so this is composition, not a unary transformation.

---

## 17. What Is Not Part of the Formal Core

The following are not basic formal operations of the current theory.

### 17.1. Replacement

This is not a mathematical operation, but a policy/versioning matter: which object is considered the active source of truth.

### 17.2. Correction

This is either:

- ordinary addition of new transactions,
- or a special case of derived composition.

Therefore, `replacement` and `correction` are not part of the formal core.

---

## 18. Business Examples

### 18.1. Accounting Balance by Account

Let the domain be:

- `basis = trx`
- `currency = EUR`

Rule:

- `account_type = expense`
- `account_subtype = ops_cost`

Materialization:

- `groupBy = (country, legal_entity)`

Then the family maintains rows such as:

- `trx / EUR / expense / ops_cost / EE / Bolt Ops OÜ`
- `trx / EUR / expense / ops_cost / LV / Bolt Technology OU`

This is an accounting balance by account, refined by analytics.

---

### 18.2. GMV by Countries and Verticals

Let the domain be:

- `basis = trx`
- `currency = EUR`

Rule:

- completed GMV events

Materialization:

- `groupBy = (country, vertical)`

Then the family maintains rows:

- `trx / EUR / country=EE / vertical=Food`
- `trx / EUR / country=LV / vertical=Grocery`

This is a GMV balance family.

---

### 18.3. Limited Scope to the Baltics

Rule:

```json
{
  "scope": { "country": ["EE", "LV"] },
  "groupBy": ["vertical", "country"]
}
```

This means:

- only EE and LV are counted;
- within the family, rows differ by `vertical` and `country`.

There will be no rows for `LT`.

---

### 18.4. Impermissible Rule Overlap

Rule 1:

```json
{
  "scope": { "country": ["EE", "LV"] },
  "groupBy": ["vertical", "country"]
}
```

Rule 2:

```json
{
  "scope": { "country": ["EE", "LT"] },
  "groupBy": ["vertical", "country"]
}
```

Both may generate:

- `(Food, EE)`
- `(Grocery, EE)`

So these rules must not be simultaneously active in one domain.

---

### 18.5. Conversion `trx -> rep`

Suppose there are two families with the same suffix key `(country, vertical)`, but in different domains:

- `trx / EUR / country / vertical`
- `rep / EUR / country / vertical`

If there is a correct rule for transforming values and a path mapping between them, conversion is permissible.

However, if the transition requires data lost during aggregation, conversion is not permissible.

---

### 18.6. Derived Profit

There are families:

- `income_by_country`
- `expense_by_country`

Then the derived family:

$$profit\_by\_country = income\_by\_country - expense\_by\_country$$

This is not a conversion, but a composition of two balances.

---

## 19. What Changes if Domain Disjointness Is Abandoned

The theory above assumes domain disjointness. This provides a very strong invariant:

> each transaction belongs to exactly one class of additivity.

If this assumption is abandoned, the system becomes more flexible, but the theory becomes substantially more complex.

### 19.1. What Appears

If domains are allowed to overlap, one transaction may belong to several domains simultaneously.

Then domains cease to be a partition and become a cover.

### Business Interpretation

This could be useful if one and the same transaction should simultaneously participate in several independent views:

- accounting view,
- reporting view,
- managerial slice,
- GMV view.

### 19.2. What Is Lost

If disjointness is removed, the following strong properties are lost.

#### 19.2.1. Unambiguous Domain Classification

Instead of

$$e \mapsto D$$

we get

$$e \mapsto \{D_1,\dots,D_k\}.$$

#### 19.2.2. Unique Class of Additivity

A transaction no longer resides in one unique sum class. It belongs to multiple semantic representations simultaneously.

#### 19.2.3. Safe Composition by Default

If the same transaction landed:

- in family $F_1$ of domain $D_1$,
- and in family $F_2$ of domain $D_2$,

then operations such as:

- sum,
- derived composition,
- conversion,

may count the same economic mass twice.

That is, a double-counting risk arises.

#### 19.2.4. Ambiguity in Conversion

If a transaction already has native representation in two domains, then converting from one to another no longer necessarily means a true transfer. It may simply be a second representation of already existing mass.

### 19.3. What Remains Correct

Even without disjointness:

- reading by complete canonical path may remain technically unambiguous;
- additivity within one fixed family is preserved.

That is, the local law

$$B_F^{E_1 \cup E_2}(p) = B_F^{E_1}(p) + B_F^{E_2}(p)$$

remains true for one family.

### 19.4. What New Requirements Then Become Necessary

If domains overlap, correctness can no longer be ensured through domain structure alone. It must be shifted to the level of operations over families.

At minimum, one needs to track:

- which original transactions contributed to each family;
- whether the source sets of two families overlap;
- whether composition is permissible under such overlap.

In particular:

#### For Derived Sum

If

$$F_1 + F_2$$

is defined, then either

$$Src(F_1) \cap Src(F_2) = \varnothing,$$

or there must be an explicit rule for correcting overlaps.

#### For Conversion

One must distinguish:

- native target representation,
- converted target representation.

Otherwise, the same mass may appear twice.

#### For Roll-up

Roll-up is safe only within one lineage chain, that is, when the coarser family is derived from a more detailed family representing the same source mass.

### 19.5. Conceptual Change

With domain disjointness, domains are:

- classes of additivity,
- and a partition of transactions.

Without disjointness, domains become more like:

- semantic lenses,
- or views,

rather than unique classes of ownership over a sum.

Then the burden of correctness is shifted from domains to operations over families.

### 19.6. Practical Conclusion

A system with disjoint domains:

- is simpler to reason about;
- has lower double-counting risk;
- simplifies conversion and derived balances.

A system with overlapping domains:

- is more flexible;
- but requires lineage tracking;
- overlap checks;
- conditions for composition permissibility;
- explicit control of semantic duplication.

### 19.7. Summary

For the basic theory core, it is preferable to maintain domain disjointness.

This provides a strong invariant that simplifies:

- membership in domain,
- additivity,
- family construction,
- conversion,
- derived composition,
- semantic reasoning.

The theory of overlapping domains is possible, but should be considered a separate subsequent extension, not part of the basic core.
